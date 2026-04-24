import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../constants/app_constants.dart';
import '../data/tax/tax_factory.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/purchase_record.dart';
import '../models/subscription_state.dart';
import '../onboarding/coach_tour.dart';
import '../config/revenuecat_config.dart';
import '../services/analytics_service.dart';
import '../services/ai_coach_service.dart';
import '../services/revenuecat_service.dart';
import '../services/subscription_service.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';
import '../utils/coach_delimiter_parser.dart';
import '../utils/coach_mode_recommender.dart';
import '../utils/rate_limiter.dart';
import '../widgets/info_icon_button.dart';
import '../widgets/offline_banner.dart';

class CoachScreen extends StatefulWidget {
  final AppSettings settings;
  final PurchaseHistory purchaseHistory;
  final String apiKey;
  final String householdId;
  final VoidCallback onOpenSettings;
  final SubscriptionState subscription;
  final ValueChanged<SubscriptionState> onSubscriptionChanged;
  final VoidCallback? onRestoreMemory;
  final bool showTour;
  final VoidCallback? onTourComplete;
  final bool isOffline;

  const CoachScreen({
    super.key,
    required this.settings,
    required this.purchaseHistory,
    required this.apiKey,
    required this.householdId,
    required this.onOpenSettings,
    required this.subscription,
    required this.onSubscriptionChanged,
    this.onRestoreMemory,
    this.showTour = false,
    this.onTourComplete,
    this.isOffline = false,
  });

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> with WidgetsBindingObserver {
  final _service = AiCoachService();
  final _subscriptionService = SubscriptionService();
  final _composerController = TextEditingController();
  final _scrollController = ScrollController();

  List<CoachChatMessage> _messages = [];
  bool _loading = false;
  String? _error;
  CoachModeResolution? _lastModeResolution;
  late SubscriptionState _subscription;
  late CoachMode _selectedMode;
  bool _tourShown = false;
  bool _ecoBannerCollapsed = false;
  final _rateLimiter = RateLimiter(minInterval: AppConstants.rateLimitInterval);

  // Welcome card for first-time users
  bool _welcomeCardDismissed = false;

  // Feature #1: Downgrade transition card
  bool _downgradeCardDismissed = false;

  // Feature #2: Endowment Plus banner
  bool _endowmentBannerDismissed = false;

  // Feature #3: Smart mode recommendation
  CoachMode? _pendingRecommendation;
  bool _showRecommendation = false;
  Timer? _recommendationTimer;

  // Debounce timer for _checkRecommendation (#765)
  Timer? _recommendationDebounce;

  // Feature #5: Micro-action follow-up card
  bool _microActionCardDismissed = false;
  // Track last parsed micro-action for inline display
  String? _lastParsedMicroAction;

  // Regex for parsing LLM delimiters (shared from coach_delimiter_parser.dart)
  static final _sessionInsightRegex = sessionInsightRegex;
  static final _microActionRegex = microActionRegex;

  List<String> _quickPrompts(S l10n) => [
    l10n.coachQuickPrompt1,
    l10n.coachQuickPrompt2,
    l10n.coachQuickPrompt3,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = widget.subscription;
    _selectedMode = _subscription.preferredCoachMode;
    _loadConversation();
    if (widget.showTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_tourShown || !mounted) return;
        _tourShown = true;
        Future.delayed(AppConstants.tourStartDelay, () {
          if (!mounted) return;
          buildCoachTour(
            context: context,
            onFinish: () => widget.onTourComplete?.call(),
            onSkip: () => widget.onTourComplete?.call(),
          ).show(context: context);
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant CoachScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subscription != oldWidget.subscription) {
      _subscription = widget.subscription;
      _selectedMode = _subscription.preferredCoachMode;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _composerController.dispose();
    _scrollController.dispose();
    _recommendationTimer?.cancel();
    _recommendationDebounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadConversation();
  }

  Future<void> _loadConversation() async {
    final messages = await _service.loadConversation(widget.householdId);
    if (!mounted) return;
    setState(() => _messages = messages);
    _scrollToBottom();
  }

  void _updateSubscription(SubscriptionState updated) {
    setState(() => _subscription = updated);
    widget.onSubscriptionChanged(updated);
  }

  /// Parse and strip [SESSION_INSIGHT] and [MICRO_ACTION] from LLM reply.
  Future<String> _parseAndStoreDelimiters(
    String reply,
    CoachMode effectiveMode,
  ) async {
    var cleaned = reply;

    // Feature #4: Parse SESSION_INSIGHT
    final insightMatch = _sessionInsightRegex.firstMatch(cleaned);
    if (insightMatch != null) {
      final insight = insightMatch.group(1)?.trim() ?? '';
      final value = insightMatch.group(2)?.trim();
      if (insight.isNotEmpty) {
        final updated = await _subscriptionService.setSessionInsight(
          _subscription,
          insight,
          (value != null && value.isNotEmpty) ? value : null,
        );
        _updateSubscription(updated);
      }
      cleaned = cleaned.replaceAll(_sessionInsightRegex, '').trim();
    }

    // Feature #5: Parse MICRO_ACTION (Pro only)
    _lastParsedMicroAction = null;
    if (effectiveMode == CoachMode.pro) {
      final actionMatch = _microActionRegex.firstMatch(cleaned);
      if (actionMatch != null) {
        final action = actionMatch.group(1)?.trim() ?? '';
        if (action.isNotEmpty) {
          _lastParsedMicroAction = action;
          final updated = await _subscriptionService.setLastMicroAction(
            _subscription,
            action,
          );
          _updateSubscription(updated);
        }
        cleaned = cleaned.replaceAll(_microActionRegex, '').trim();
      }
    }

    // Feature #4: Track session completed
    final tracked = await _subscriptionService.trackSessionCompleted(
      _subscription,
      effectiveMode,
    );
    _updateSubscription(tracked);

    return cleaned;
  }

  Future<void> _sendCurrentMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty || _loading) return;

    // Set loading synchronously BEFORE any async work to prevent
    // double credit deduction from rapid chip taps (#759).
    setState(() => _loading = true);

    if (!_rateLimiter.tryCall()) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).rateLimitMessage),
          behavior: SnackBarBehavior.floating,
          duration: AppConstants.snackBarShort,
        ),
      );
      return;
    }

    // Feature #2: Increment conversation count on first message of new session
    if (_messages.isEmpty && _subscription.isInEndowmentPeriod) {
      final updated = await _subscriptionService.incrementConversationCount(
        _subscription,
      );
      if (!mounted) return;
      _updateSubscription(updated);
    }

    // Feature #3: Dismiss recommendation on send
    _dismissRecommendation();

    final previousMessages = List<CoachChatMessage>.from(_messages);
    final userMessage = CoachChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    _composerController.clear();
    setState(() {
      _error = null;
      _messages = [..._messages, userMessage];
    });
    unawaited(
      AnalyticsService.instance.trackEvent(
        'coach_message_sent',
        properties: {
          'selected_mode': _selectedMode.name,
          'message_length': text.length,
          'had_history': previousMessages.isNotEmpty,
        },
      ),
    );
    _scrollToBottom();

    try {
      final modeResult = await _subscriptionService.resolveAndConsumeCoachMode(
        _subscription,
        requestedMode: _selectedMode,
      );
      final nextSubscription = modeResult.state;
      final resolution = modeResult.resolution;
      if (mounted) {
        setState(() {
          _subscription = nextSubscription;
          _lastModeResolution = resolution;
        });
      }
      widget.onSubscriptionChanged(nextSubscription);

      // Feature #1: Show downgrade transition card on first fallback
      if (resolution.usedFallback && !_subscription.downgradeCardShown) {
        final marked = await _subscriptionService.markDowngradeCardShown(
          _subscription,
        );
        if (!mounted) return;
        _updateSubscription(marked);
        setState(() => _downgradeCardDismissed = false);
      }

      final effectiveMode = resolution.effectiveMode;
      final taxSystem = getTaxSystem(widget.settings.country);
      final summary = calculateBudgetSummary(
        widget.settings.salaries,
        widget.settings.personalInfo,
        widget.settings.expenses,
        taxSystem,
      );
      final reply = await _service.sendChatMessage(
        apiKey: widget.apiKey,
        userMessage: text,
        history: previousMessages,
        contextWindow: _subscription.contextWindowForMode(effectiveMode),
        settings: widget.settings,
        summary: summary,
        purchaseHistory: widget.purchaseHistory,
        maxTokens: _maxTokensForMode(effectiveMode),
        effectiveMode: effectiveMode,
        lastMicroAction: _subscription.lastMicroAction,
        lastMicroActionDate: _subscription.lastMicroActionDate,
      );

      if (!mounted) return;

      // Parse delimiters from reply
      final cleanedReply = await _parseAndStoreDelimiters(reply, effectiveMode);
      if (!mounted) return;

      final updated = [
        ..._messages,
        CoachChatMessage(
          role: 'assistant',
          content: cleanedReply,
          timestamp: DateTime.now(),
        ),
      ];
      setState(() => _messages = updated);
      await _service.saveConversation(widget.householdId, updated);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  int _maxTokensForMode(CoachMode mode) {
    switch (mode) {
      case CoachMode.eco:
        return 450;
      case CoachMode.plus:
        return 900;
      case CoachMode.pro:
        return 1200;
    }
  }

  Future<void> _setPreferredMode(CoachMode mode) async {
    final updated = await _subscriptionService.setPreferredCoachMode(
      _subscription,
      mode,
    );
    if (mounted) {
      setState(() {
        _subscription = updated;
        _selectedMode = mode;
      });
    }
    widget.onSubscriptionChanged(updated);
  }

  Future<void> _clearConversation() async {
    final l10n = S.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.coachClearTitle),
        content: Text(l10n.coachClearContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.clear,
              style: TextStyle(color: AppColors.bad(context)),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.clearConversation(widget.householdId);
      if (mounted) setState(() => _messages = []);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // #767: Guard against callback firing after dispose
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppConstants.animScrollToBottom,
        curve: Curves.easeOut,
      );
    });
  }

  // Feature #3: Handle recommendation (debounced — #765)
  void _checkRecommendation(String text) {
    _recommendationDebounce?.cancel();
    if (text.trim().isEmpty) {
      _dismissRecommendation();
      return;
    }
    _recommendationDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final locale = Localizations.localeOf(context).languageCode;
      final recommended = recommendMode(text, locale: locale);
      if (recommended.index > _selectedMode.index &&
          _subscription.aiCredits >=
              _subscription.creditCostForMode(recommended)) {
        setState(() {
          _pendingRecommendation = recommended;
          _showRecommendation = true;
        });
        _recommendationTimer?.cancel();
        _recommendationTimer = Timer(AppConstants.recommendationAutoDismiss, () {
          if (mounted) _dismissRecommendation();
        });
      } else if (recommended == _selectedMode) {
        setState(() {
          _pendingRecommendation = null;
          _showRecommendation = false;
        });
      } else {
        _dismissRecommendation();
      }
    });
  }

  void _dismissRecommendation() {
    _recommendationTimer?.cancel();
    if (_showRecommendation) {
      setState(() {
        _pendingRecommendation = null;
        _showRecommendation = false;
      });
    }
  }

  Future<void> _acceptRecommendation() async {
    if (_pendingRecommendation == null) return;
    final mode = _pendingRecommendation!;
    // #756: Persist mode via _setPreferredMode instead of transient setState
    await _setPreferredMode(mode);
    final updated = await _subscriptionService.trackRecommendation(
      _subscription,
      accepted: true,
    );
    if (!mounted) return;
    _updateSubscription(updated);
    _dismissRecommendation();
  }

  Future<void> _declineRecommendation() async {
    final updated = await _subscriptionService.trackRecommendation(
      _subscription,
      accepted: false,
    );
    if (!mounted) return;
    _updateSubscription(updated);
    _dismissRecommendation();
  }

  // Feature #5: Micro-action follow-up handlers
  Future<void> _completeMicroAction() async {
    final updated = await _subscriptionService.clearLastMicroAction(
      _subscription,
    );
    if (!mounted) return;
    _updateSubscription(updated);
    setState(() => _microActionCardDismissed = true);
  }

  void _dismissMicroAction() {
    setState(() => _microActionCardDismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return CalmScaffold(
      title: l10n.coachTitle,
      actions: [
        InfoIconButton(title: l10n.coachTitle, body: l10n.infoCoachModes),
        IconButton(
          onPressed: _clearConversation,
          tooltip: l10n.coachClearAll,
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
      ],
      body: Column(
        children: [
          // Subtitle / eyebrow below the app bar — keeps the Calm hierarchy
          // without a headline metric (no CalmHero for chat screens).
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.coachSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.ink70(context),
                ),
              ),
            ),
          ),

          // #754: Offline banner
          if (widget.isOffline)
            OfflineBanner(message: l10n.coachOfflineBanner),

          _buildModeCard(),

          // Feature #1: Downgrade transition card (one-time per depletion)
          if (_lastModeResolution?.usedFallback == true &&
              !_downgradeCardDismissed &&
              _subscription.downgradeCardShown)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildDowngradeTransitionCard(),
            ),

          // Existing fallback card (for subsequent eco messages)
          if (_lastModeResolution?.usedFallback == true &&
              _downgradeCardDismissed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildFallbackCard(),
            ),

          // Feature #2: Endowment Plus banner
          if (_subscription.isInEndowmentPeriod && !_endowmentBannerDismissed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildEndowmentBanner(),
            ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildErrorCard(),
            ),

          Expanded(
            child: Container(
              key: CoachTourKeys.historyList,
              margin: const EdgeInsets.only(top: 8),
              child: _buildMessagesList(),
            ),
          ),

          // Feature #3: Smart mode recommendation widget
          if (_showRecommendation && _pendingRecommendation != null)
            _buildRecommendationWidget(),

          _buildComposer(),
        ],
      ),
    );
  }

  // Feature #1: Downgrade transition card
  Widget _buildDowngradeTransitionCard() {
    final l10n = S.of(context);
    return CalmCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CalmPill(
                label: l10n.coachDowngradeTitle,
                color: AppColors.warn(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCompareColumn(
                  title: l10n.coachCompareWithPlus,
                  items: [
                    (l10n.coachCompareMemory20, true),
                    (l10n.coachCompareDetailedReplies, true),
                    (l10n.coachCompareFinancialContext, true),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompareColumn(
                  title: l10n.coachCompareWithEco,
                  items: [
                    (l10n.coachCompareMemory6, false),
                    (l10n.coachCompareShortReplies, false),
                    (l10n.coachCompareLimitedContext, false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    setState(() => _downgradeCardDismissed = true);
                    _showCreditPacksSheet();
                  },
                  child: Text(S.of(context).coachBuyCredits),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() => _downgradeCardDismissed = true);
                },
                child: Text(S.of(context).coachContinueEco),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompareColumn({
    required String title,
    required List<(String, bool)> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalmEyebrow(title),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Icon(
                    item.$2 ? Icons.check_circle : Icons.cancel,
                    size: 14,
                    color: item.$2
                        ? AppColors.ok(context)
                        : AppColors.bad(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.ink70(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Feature #2: Endowment Plus banner
  Widget _buildEndowmentBanner() {
    final l10n = S.of(context);
    final remaining =
        SubscriptionState.endowmentConversations -
        _subscription.coachConversationCount;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentSoft(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.coachEndowmentBanner(remaining),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.accent(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _endowmentBannerDismissed = true),
            icon: const Icon(Icons.close, size: 16),
            visualDensity: VisualDensity.compact,
            color: AppColors.accent(context),
          ),
        ],
      ),
    );
  }

  // Feature #3: Smart mode recommendation
  Widget _buildRecommendationWidget() {
    final l10n = S.of(context);
    final rec = _pendingRecommendation!;
    final isPro = rec == CoachMode.pro;
    final cost = _subscription.creditCostForMode(rec);
    // Calm restraint: the accent indigo is the single highlight colour.
    // Pro vs Plus differ by label, not by hue.
    final accentColor = AppColors.accent(context);

    final text = isPro
        ? l10n.coachRecommendPro(cost)
        : l10n.coachRecommendPlus(cost);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentSoft(context),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(width: 3, color: accentColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink(context),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton(
                onPressed: _acceptRecommendation,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                ),
                child: Text(
                  S
                      .of(context)
                      .coachUseMode(
                        '${rec.name.substring(0, 1).toUpperCase()}${rec.name.substring(1)}',
                      ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _declineRecommendation,
                child: Text(
                  S
                      .of(context)
                      .coachKeepMode(
                        '${_selectedMode.name.substring(0, 1).toUpperCase()}${_selectedMode.name.substring(1)}',
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Feature #5: Micro-action follow-up card
  Widget _buildInlineMicroActionTag() {
    final action = _lastParsedMicroAction;
    if (action == null) return const SizedBox.shrink();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = screenWidth >= 1200
        ? 840.0
        : screenWidth >= 700
        ? 640.0
        : screenWidth * 0.9;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line(context)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.flag_rounded,
              size: 16,
              color: AppColors.ok(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CalmEyebrow(S.of(context).coachNextStep),
                  const SizedBox(height: 2),
                  Text(
                    action,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.ink(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicroActionCard() {
    final l10n = S.of(context);
    final action = _subscription.lastMicroAction!;
    final date = _subscription.lastMicroActionDate;
    final daysAgo = date != null ? DateTime.now().difference(date).inDays : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CalmCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.ok(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.track_changes,
                        size: 16,
                        color: AppColors.ok(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.coachPendingAction,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink(context),
                        ),
                      ),
                    ],
                  ),
                  if (daysAgo > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        l10n.coachSuggestedDaysAgo(daysAgo),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.ink50(context),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.bgSunk(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.line(context)),
                    ),
                    child: Text(
                      action,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.ink(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _completeMicroAction,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                        ),
                        child: Text(S.of(context).coachAchieved),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _dismissMicroAction,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                        ),
                        child: Text(S.of(context).coachNotYet),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(S l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CalmCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology_alt_rounded,
                  size: 20,
                  color: AppColors.accent(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.coachWelcomeTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink(context),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _welcomeCardDismissed = true),
                  icon: const Icon(Icons.close, size: 16),
                  visualDensity: VisualDensity.compact,
                  color: AppColors.ink50(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.coachWelcomeBody,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.ink70(context),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.toll_outlined,
                  size: 14,
                  color: AppColors.ink50(context),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.coachWelcomeCredits,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.ink50(context),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: AppColors.ink50(context),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.coachWelcomeRateLimit,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.ink50(context),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      final l10n = S.of(context);
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome/onboarding card for new users
              if (!_welcomeCardDismissed) _buildWelcomeCard(l10n),
              // Feature #5: Show micro-action follow-up card
              if (_subscription.lastMicroAction != null &&
                  !_microActionCardDismissed)
                _buildMicroActionCard(),
              CalmEmptyState(
                icon: Icons.chat_bubble_outline,
                title: l10n.coachTitle,
                body: l10n.coachEmptyBody,
              ),
              const SizedBox(height: 20),
              // Prompt suggestion chips — Calm outlined buttons, ink70 text.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _quickPrompts(l10n)
                    .map(
                      (prompt) => OutlinedButton(
                        onPressed: () {
                          _composerController.text = prompt;
                          _sendCurrentMessage();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink70(context),
                          side: BorderSide(color: AppColors.line(context)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(prompt),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 14),
      itemCount: _messages.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_loading && index == _messages.length) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line(context)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft(context),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.psychology_alt_rounded,
                      size: 12,
                      color: AppColors.accent(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const _CoachTypingDots(),
                ],
              ),
            ),
          );
        }
        final message = _messages[index];
        final isLastAssistant =
            message.role == 'assistant' &&
            index == _messages.length - 1 &&
            _lastParsedMicroAction != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MessageBubble(message: message),
            if (isLastAssistant) _buildInlineMicroActionTag(),
          ],
        );
      },
    );
  }

  Widget _buildComposer() {
    final l10n = S.of(context);
    final costNow = _subscription.creditCostForMode(_selectedMode);
    return Container(
      key: CoachTourKeys.analyzeButton,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        border: Border(top: BorderSide(color: AppColors.line(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line(context)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _composerController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendCurrentMessage(),
                    onChanged: _checkRecommendation,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.ink(context),
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.coachComposerHint,
                      hintStyle: TextStyle(
                        color: AppColors.ink50(context),
                        fontSize: 15,
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: (_loading || widget.isOffline)
                      ? null
                      : _sendCurrentMessage,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  costNow == 0
                      ? l10n.coachCostFree
                      : l10n.coachCostCredits(costNow),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink50(context),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InfoIconButton(
                title: l10n.coachTitle,
                body: l10n.infoCoachCredits,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard() {
    final l10n = S.of(context);
    final activeResolution = _lastModeResolution;
    final effectiveMode = activeResolution?.effectiveMode ?? _selectedMode;
    final window = _subscription.contextWindowForMode(effectiveMode);
    final usagePct = ((_messages.length / window) * 100).clamp(0, 100).round();

    return CalmCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CalmEyebrow(l10n.coachMemory),
              const SizedBox(width: 6),
              InfoIconButton(title: l10n.coachTitle, body: l10n.infoCoachModes),
              const Spacer(),
              Text(
                l10n.coachCreditsCount(_subscription.aiCredits),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink70(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _modeChip(CoachMode.eco, 'Eco'),
              _modeChip(CoachMode.plus, 'Plus'),
              _modeChip(CoachMode.pro, 'Pro'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.coachActiveMemory(effectiveMode.name.toUpperCase(), usagePct),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.ink50(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.coachCostPerMessageNote,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.ink50(context),
            ),
          ),
          // Feature #6: Credit cap warning
          if (_subscription.isAtCreditCap)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CalmPill(
                  label: l10n.coachCapWarning,
                  color: AppColors.warn(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _modeChip(CoachMode mode, String label) {
    final selected = _selectedMode == mode;
    final l10n = S.of(context);
    final cost = _subscription.creditCostForMode(mode);
    final subtitle = cost == 0 ? l10n.coachFree : l10n.coachPerMsg(cost);
    return ChoiceChip(
      label: Text('$label - $subtitle'),
      selected: selected,
      onSelected: _loading ? null : (_) => _setPreferredMode(mode),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected
            ? AppColors.accent(context)
            : AppColors.ink(context),
      ),
      selectedColor: AppColors.accentSoft(context),
      backgroundColor: AppColors.bgSunk(context),
      side: BorderSide(
        color: selected ? AppColors.accent(context) : AppColors.line(context),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  Widget _buildFallbackCard() {
    final l10n = S.of(context);
    final compact = _ecoBannerCollapsed;
    return CalmCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CalmPill(
                  label: l10n.coachEcoFallbackTitle,
                  color: AppColors.warn(context),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _ecoBannerCollapsed = !_ecoBannerCollapsed);
                },
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                tooltip: compact ? l10n.coachExpandTip : l10n.coachCollapseTip,
                icon: Icon(
                  compact ? Icons.expand_more : Icons.expand_less,
                  color: AppColors.ink50(context),
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 6),
            Text(
              l10n.coachEcoFallbackBody,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.ink70(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: widget.onRestoreMemory ?? widget.onOpenSettings,
                child: Text(l10n.coachRestoreMemory),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bad(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: AppColors.bad(context), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.bad(context),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() => _error = null);
            },
            child: Icon(Icons.close, size: 16, color: AppColors.bad(context)),
          ),
        ],
      ),
    );
  }

  // Feature #4: Credit packs sheet with ROI card
  void _showCreditPacksSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => _CreditPacksSheet(
        subscription: _subscription,
        onPurchase: (pack) async {
          Navigator.pop(ctx);
          await _purchaseCreditPack(pack);
        },
      ),
    );
  }

  Future<void> _purchaseCreditPack(CreditPack pack) async {
    try {
      if (revenueCatSimulateMode) {
        final updated = await _subscriptionService.addAiCredits(
          _subscription,
          pack.credits,
        );
        _updateSubscription(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).coachCreditsAdded(pack.credits)),
            ),
          );
        }
        return;
      }
      final success = await RevenueCatService.purchaseConsumable(pack.id);
      if (success) {
        final updated = await _subscriptionService.addAiCredits(
          _subscription,
          pack.credits,
        );
        _updateSubscription(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).coachCreditsAdded(pack.credits)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).coachPurchaseError(e.toString())),
          ),
        );
      }
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final CoachChatMessage message;
  const _MessageBubble({required this.message});

  String _formatTime(DateTime value) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = screenWidth >= 1200
        ? (isUser ? 560.0 : 840.0)
        : screenWidth >= 700
        ? (isUser ? 460.0 : 640.0)
        : screenWidth * (isUser ? 0.78 : 0.9);

    // Calm chat palette: user bubbles are accent-filled with bg text
    // (ink-reversed); coach bubbles are card-filled with a hairline border.
    final bubbleColor = isUser
        ? AppColors.accent(context)
        : AppColors.card(context);
    final textColor = isUser
        ? AppColors.bg(context)
        : AppColors.ink(context);
    final labelColor = AppColors.ink50(context);
    final avatarBg = isUser
        ? AppColors.accentSoft(context)
        : AppColors.bgSunk(context);
    final avatarIconColor = isUser
        ? AppColors.accent(context)
        : AppColors.ink70(context);

    return Align(
      alignment: align,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUser)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: avatarBg,
                    child: Icon(
                      Icons.psychology_alt_rounded,
                      size: 12,
                      color: avatarIconColor,
                    ),
                  ),
                if (!isUser) const SizedBox(width: 6),
                Text(
                  isUser
                      ? S.of(context).coachYou
                      : S.of(context).coachAssistant,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
                if (isUser) const SizedBox(width: 6),
                if (isUser)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: avatarBg,
                    child: Icon(
                      Icons.person_rounded,
                      size: 12,
                      color: avatarIconColor,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(14),
              border: isUser
                  ? null
                  : Border.all(color: AppColors.line(context)),
            ),
            child: isUser
                ? SelectableText(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor,
                      height: 1.6,
                    ),
                  )
                : MarkdownBody(
                    data: message.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(fontSize: 15, color: textColor, height: 1.6),
                      strong: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
                      ),
                      listBullet: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        height: 1.6,
                      ),
                      h1: TextStyle(
                        fontSize: 17,
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        height: 1.5,
                      ),
                      h2: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Three-dot typing indicator for streaming coach replies.
/// Renders in `AppColors.ink50(context)` as the Calm streaming rest.
class _CoachTypingDots extends StatefulWidget {
  const _CoachTypingDots();

  @override
  State<_CoachTypingDots> createState() => _CoachTypingDotsState();
}

class _CoachTypingDotsState extends State<_CoachTypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.ink50(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Stagger each dot's phase across the cycle.
            final phase = (_controller.value + i / 3) % 1.0;
            // Eased bounce: peaks around phase=0.5, rests at the edges.
            final t = (1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
            final opacity = 0.3 + 0.7 * t;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _CreditPacksSheet extends StatelessWidget {
  final SubscriptionState subscription;
  final ValueChanged<CreditPack> onPurchase;

  const _CreditPacksSheet({
    required this.subscription,
    required this.onPurchase,
  });

  String _packSessions(BuildContext context, CreditPack pack) {
    final plus = pack.credits ~/ coachModeCreditCost[CoachMode.plus]!;
    final pro = pack.credits ~/ coachModeCreditCost[CoachMode.pro]!;
    return S.of(context).coachPackSessions(plus, pro);
  }

  int _recommendedPackIndex() {
    if (subscription.totalProSessions > subscription.totalPlusSessions) {
      return 2; // 500 credits for heavy Pro users
    }
    return 1; // 150 credits default
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final recommended = _recommendedPackIndex();
    final insight = subscription.lastSessionInsight;
    final insightValue = subscription.lastSessionInsightValue;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  l10n.coachCreditsTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink(context),
                  ),
                ),
                const Spacer(),
                CalmPill(
                  label: l10n.coachCreditsRemaining(subscription.aiCredits),
                  color: AppColors.accent(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ROI insight card
            if (insight != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line(context)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: 20,
                      color: AppColors.accent(context),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: AppColors.ink70(context),
                          ),
                          children: [
                            TextSpan(
                              text: l10n.coachRoiInsightPrefix,
                            ),
                            TextSpan(
                              text: insight,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink(context),
                              ),
                            ),
                            if (insightValue != null &&
                                insightValue.isNotEmpty) ...[
                              TextSpan(text: l10n.coachRoiPotential),
                              TextSpan(
                                text: insightValue,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent(context),
                                ),
                              ),
                            ],
                            TextSpan(
                              text: l10n.coachRoiCost,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Cap warning
            if (subscription.isAtCreditCap) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line(context)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      size: 16,
                      color: AppColors.warn(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.coachCapWarningSheet(
                          SubscriptionState.maxCreditCap,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.ink(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Pack cards
            ...List.generate(creditPacks.length, (i) {
              final pack = creditPacks[i];
              final isRecommended = i == recommended;
              final wasted = subscription.creditsWasted(pack.credits);
              final isDimmed = wasted > pack.credits * 0.5;

              return Opacity(
                opacity: isDimmed ? 0.45 : 1.0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRecommended
                          ? AppColors.accent(context)
                          : AppColors.line(context),
                      width: isRecommended ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: isDimmed ? null : () => onPurchase(pack),
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${pack.credits}',
                          style: CalmText.amount(
                            context,
                            size: 22,
                            weight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l10n.coachCreditsLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink50(context),
                          ),
                        ),
                      ],
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isRecommended)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: CalmPill(
                              label: l10n.coachBestValue,
                              color: AppColors.accent(context),
                            ),
                          ),
                        Text(
                          _packSessions(context, pack),
                          style: TextStyle(
                            fontSize: 12,
                            color: wasted > 0
                                ? AppColors.bad(context)
                                : AppColors.ink70(context),
                          ),
                        ),
                        if (wasted > 0)
                          Text(
                            l10n.coachWastedCredits(wasted),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.bad(context),
                            ),
                          ),
                      ],
                    ),
                    trailing: OutlinedButton(
                      onPressed: isDimmed ? null : () => onPurchase(pack),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.line(context)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        pack.fallbackPrice,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink(context),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Personalized recommendation
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: AppColors.accent(context),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.coachRecommendedPack(creditPacks[recommended].credits),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.ink70(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
