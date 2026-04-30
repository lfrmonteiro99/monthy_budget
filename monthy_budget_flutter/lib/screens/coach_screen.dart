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
  bool _composerHasText = false;
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
      CalmSnack.show(
        context,
        S.of(context).rateLimitMessage,
        duration: AppConstants.snackBarShort,
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
      _composerHasText = false;
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
    final confirm = await CalmDialog.confirm(
      context,
      title: l10n.coachClearTitle,
      body: l10n.coachClearContent,
      confirmLabel: l10n.clear,
      cancelLabel: l10n.cancel,
      destructive: true,
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
    final hasText = text.trim().isNotEmpty;
    if (hasText != _composerHasText) {
      setState(() => _composerHasText = hasText);
    }
    _recommendationDebounce?.cancel();
    if (!hasText) {
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
          // Eyebrow subtitle below the AppBar — keeps Calm hierarchy without
          // a hero metric (chat surface).
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
            child: KeyedSubtree(
              key: CoachTourKeys.historyList,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildMessagesList(),
              ),
            ),
          ),

          // Feature #3: Smart mode recommendation widget
          if (_showRecommendation && _pendingRecommendation != null)
            _buildRecommendationWidget(),

          _buildFooter(),
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
    return CalmCard(
      padding: const EdgeInsets.all(10),
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

  // Feature #2: Endowment Plus banner — wrapped in CalmCard for consistent chrome.
  Widget _buildEndowmentBanner() {
    final l10n = S.of(context);
    final remaining =
        SubscriptionState.endowmentConversations -
        _subscription.coachConversationCount;
    return CalmCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

    final text = isPro
        ? l10n.coachRecommendPro(cost)
        : l10n.coachRecommendPlus(cost);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: CalmCard(
        padding: const EdgeInsets.all(12),
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
      ),
    );
  }

  // Feature #5: Inline micro-action tag — Calm card chrome.
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
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CalmCard(
            padding: const EdgeInsets.all(10),
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
            // Action body — quoted with a leading vertical bar via a left
            // padding + Border, no extra Container (keeps audit numbers low).
            Padding(
              padding: const EdgeInsets.only(left: 10),
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
              if (!_welcomeCardDismissed) _buildWelcomeCard(l10n),
              if (_subscription.lastMicroAction != null &&
                  !_microActionCardDismissed)
                _buildMicroActionCard(),
              CalmEmptyState(
                icon: Icons.chat_bubble_outline,
                title: l10n.coachTitle,
                body: l10n.coachEmptyBody,
              ),
              const SizedBox(height: 20),
              // TODO(l10n): extract "Sugestões" eyebrow.
              const CalmEyebrow('SUGESTÕES'),
              const SizedBox(height: 8),
              // Suggestion chips — Calm action pills, scroll horizontal.
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: _quickPrompts(l10n).length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final prompt = _quickPrompts(l10n)[i];
                    return CalmActionPill(
                      label: prompt,
                      onTap: () {
                        _composerController.text = prompt;
                        _sendCurrentMessage();
                      },
                    );
                  },
                ),
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
          // Loading reply — AI bubble shape with 3 dots (per SCREEN_ROLLOUT
          // §16: "3 dots animados na bubble AI. NÃO shimmer.").
          final showAvatar = _messages.isEmpty ||
              _messages.last.role != 'assistant';
          return _ChatBubble(
            isUser: false,
            showAvatar: showAvatar,
            child: const _CoachTypingDots(),
          );
        }
        final message = _messages[index];
        final isUser = message.role == 'user';
        // Avatar only on FIRST message of each turn (per spec).
        final showAvatar = index == 0 ||
            _messages[index - 1].role != message.role;
        final isLastAssistant = !isUser &&
            index == _messages.length - 1 &&
            _lastParsedMicroAction != null;
        return Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _ChatBubble(
              isUser: isUser,
              showAvatar: showAvatar,
              child: _MessageBody(content: message.content, isUser: isUser),
            ),
            if (isLastAssistant) _buildInlineMicroActionTag(),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    final l10n = S.of(context);
    final costNow = _subscription.creditCostForMode(_selectedMode);
    final canSend = _composerHasText && !_loading && !widget.isOffline;
    return SafeArea(
      top: false,
      child: KeyedSubtree(
        key: CoachTourKeys.analyzeButton,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input row — bgSunk pill + ink-fill send button (spec §16 footer).
              Row(
                children: [
                  Expanded(
                    child: _ComposerInputField(
                      controller: _composerController,
                      hint: l10n.coachComposerHint,
                      onChanged: _checkRecommendation,
                      onSubmitted: (_) => _sendCurrentMessage(),
                      enabled: !widget.isOffline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SendButton(
                    enabled: canSend,
                    loading: _loading,
                    onPressed: _sendCurrentMessage,
                  ),
                ],
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
        ),
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

  // System error bubble — center-aligned, accent-bad text + retry per spec §16.
  Widget _buildErrorCard() {
    final l10n = S.of(context);
    return CalmCard(
      padding: const EdgeInsets.all(12),
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
          TextButton(
            onPressed: _sendCurrentMessage,
            child: Text(l10n.retry),
          ),
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
    CalmBottomSheet.show(
      context,
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
          CalmSnack.success(
              context, S.of(context).coachCreditsAdded(pack.credits));
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
          CalmSnack.success(
              context, S.of(context).coachCreditsAdded(pack.credits));
        }
      }
    } catch (e) {
      if (mounted) {
        CalmSnack.error(
            context, S.of(context).coachPurchaseError(e.toString()));
      }
    }
  }
}

/// Asymmetric chat bubble per SCREEN_ROLLOUT §16:
/// - AI: bg `bgSunk`, radius 18 with bottom-left corner 4, padding 14, max 78%,
///   28×28 ink avatar with bg "C" (Fraunces 14). Avatar only when [showAvatar].
/// - User: bg `ink`, text `bg`, radius 18 with bottom-right corner 4. Avatar
///   28×28 with `userInitials` ink50 outline ink20 — also only first of turn.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.isUser,
    required this.showAvatar,
    required this.child,
  });

  final bool isUser;
  final bool showAvatar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = screenWidth * 0.78;
    final bubbleColor = isUser
        ? AppColors.ink(context)
        : AppColors.bgSunk(context);
    final radius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          );

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      // Single Container per bubble — asymmetric corner geometry per spec
      // cannot be expressed via theme-driven CalmCard.
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: radius,
        ),
        child: child,
      ),
    );

    if (!showAvatar) {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: 4,
            left: isUser ? 0 : 36, // align below the AI avatar column
            right: isUser ? 36 : 0,
          ),
          child: bubble,
        ),
      );
    }

    final avatar = _BubbleAvatar(isUser: isUser);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[avatar, const SizedBox(width: 8)],
          Flexible(child: bubble),
          if (isUser) ...[const SizedBox(width: 8), avatar],
        ],
      ),
    );
  }
}

/// 28×28 round avatar — coach uses `CalmAvatarBadge`-equivalent ink fill
/// with Fraunces "C". User mirrors with `userInitials` ink50 outline ink20.
class _BubbleAvatar extends StatelessWidget {
  const _BubbleAvatar({required this.isUser});

  final bool isUser;

  @override
  Widget build(BuildContext context) {
    if (!isUser) {
      // Coach avatar: ink fill, bg-coloured "C" in Fraunces 14.
      return CalmAvatarBadge(initials: 'C', size: 28);
    }
    // User avatar: outline ink20, ink50 initial. No fill — visually distinct.
    return SizedBox(
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: CircleBorder(
            side: BorderSide(color: AppColors.ink20(context)),
          ),
        ),
        child: Center(
          child: Text(
            'U',
            // TODO(l10n): swap "U" for personalInfo.userInitials when available.
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink50(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bubble text body. AI uses Markdown (with inline accent CTA pills allowed
/// via prose), user uses plain selectable text reversed on ink.
class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.content, required this.isUser});

  final String content;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final textColor = isUser ? AppColors.bg(context) : AppColors.ink(context);
    if (isUser) {
      return SelectableText(
        content,
        style: TextStyle(fontSize: 14, color: textColor, height: 1.45),
      );
    }
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(fontSize: 14, color: textColor, height: 1.45),
        strong: TextStyle(
          fontSize: 14,
          color: textColor,
          fontWeight: FontWeight.w700,
          height: 1.45,
        ),
        listBullet: TextStyle(fontSize: 14, color: textColor, height: 1.45),
        h1: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w800,
          height: 1.4,
        ),
        h2: TextStyle(
          fontSize: 15,
          color: textColor,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Composer text-field — bgSunk pill (radius 99), padding 12/18.
class _ComposerInputField extends StatelessWidget {
  const _ComposerInputField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
    required this.enabled,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // Single Container — radius 99 + bgSunk fill is the spec's input chrome.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSunk(context),
        borderRadius: BorderRadius.circular(99),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 4,
        enabled: enabled,
        textInputAction: TextInputAction.send,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: TextStyle(fontSize: 14, color: AppColors.ink(context)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.ink50(context),
            fontSize: 14,
          ),
          isDense: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

/// 36×36 ink-filled send button with arrow_upward 18 bg. Disabled state
/// drops opacity to 0.4 per spec §16.
class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final inkBg = AppColors.ink(context);
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: inkBg,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.bg(context),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.arrow_upward_rounded,
                      size: 18,
                      color: AppColors.bg(context),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three-dot typing indicator for the loading-reply state per SCREEN_ROLLOUT
/// §16 ("3 dots animados, NÃO shimmer"). Stagger 200ms per dot.
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
            final phase = (_controller.value + i / 3) % 1.0;
            final t = (1 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
            final opacity = 0.3 + 0.7 * t;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                Icons.circle,
                size: 6,
                color: color.withValues(alpha: opacity),
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
              CalmCard(
                padding: const EdgeInsets.all(12),
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
                            TextSpan(text: l10n.coachRoiInsightPrefix),
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
                            TextSpan(text: l10n.coachRoiCost),
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
              CalmCard(
                padding: const EdgeInsets.all(10),
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CalmCard(
                    padding: EdgeInsets.zero,
                    onTap: isDimmed ? null : () => onPurchase(pack),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Column(
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
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
                          ),
                          OutlinedButton(
                            onPressed:
                                isDimmed ? null : () => onPurchase(pack),
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
                        ],
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
