import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/tax/tax_factory.dart';
import '../models/app_settings.dart';
import '../models/purchase_record.dart';
import '../models/subscription_state.dart';
import '../services/ai_coach_service.dart';
import '../services/analytics_service.dart';
import '../services/subscription_service.dart';
import '../utils/calculations.dart';
import '../utils/coach_delimiter_parser.dart';
import '../utils/coach_mode_recommender.dart';
import '../utils/rate_limiter.dart';
import '../constants/app_constants.dart';

/// Extracted business logic for the Coach chat screen.
///
/// Manages message lifecycle, subscription state, delimiter parsing and
/// mode recommendations. The UI layer ([CoachScreen]) observes this
/// controller via [ChangeNotifier] and remains pure presentation.
class CoachChatController extends ChangeNotifier {
  final AiCoachService _service;
  final SubscriptionService _subscriptionService;
  final RateLimiter _rateLimiter;

  CoachChatController({
    AiCoachService? service,
    SubscriptionService? subscriptionService,
    RateLimiter? rateLimiter,
  })  : _service = service ?? AiCoachService(),
        _subscriptionService = subscriptionService ?? SubscriptionService(),
        _rateLimiter = rateLimiter ??
            RateLimiter(minInterval: AppConstants.rateLimitInterval);

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<CoachChatMessage> _messages = [];
  List<CoachChatMessage> get messages => _messages;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  CoachModeResolution? _lastModeResolution;
  CoachModeResolution? get lastModeResolution => _lastModeResolution;

  late SubscriptionState _subscription;
  SubscriptionState get subscription => _subscription;

  late CoachMode _selectedMode;
  CoachMode get selectedMode => _selectedMode;

  String? _lastParsedMicroAction;
  String? get lastParsedMicroAction => _lastParsedMicroAction;

  // Recommendation state
  CoachMode? _pendingRecommendation;
  CoachMode? get pendingRecommendation => _pendingRecommendation;
  bool _showRecommendation = false;
  bool get showRecommendation => _showRecommendation;
  Timer? _recommendationTimer;
  Timer? _recommendationDebounce;

  // Regex for parsing LLM delimiters
  static final _sessionInsightRegex = sessionInsightRegex;
  static final _microActionRegex = microActionRegex;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Must be called once after construction to set initial subscription.
  void init(SubscriptionState subscription) {
    _subscription = subscription;
    _selectedMode = subscription.preferredCoachMode;
  }

  /// Update subscription from outside (e.g. didUpdateWidget).
  void updateSubscription(SubscriptionState subscription) {
    _subscription = subscription;
    _selectedMode = subscription.preferredCoachMode;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Message lifecycle
  // ---------------------------------------------------------------------------

  Future<void> loadConversation(String householdId) async {
    final messages = await _service.loadConversation(householdId);
    _messages = messages;
    notifyListeners();
  }

  Future<void> clearConversation(String householdId) async {
    await _service.clearConversation(householdId);
    _messages = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Send message
  // ---------------------------------------------------------------------------

  /// Attempt rate-limited send. Returns false if rate-limited.
  /// [onSubscriptionChanged] is called when subscription state is mutated
  /// so the parent widget can propagate upward.
  Future<bool> sendMessage({
    required String text,
    required String apiKey,
    required String householdId,
    required AppSettings settings,
    required PurchaseHistory purchaseHistory,
    required void Function(SubscriptionState) onSubscriptionChanged,
  }) async {
    if (text.trim().isEmpty || _loading) return true;

    _loading = true;
    notifyListeners();

    if (!_rateLimiter.tryCall()) {
      _loading = false;
      notifyListeners();
      return false; // rate-limited
    }

    // Increment conversation count on first message of new session
    if (_messages.isEmpty && _subscription.isInEndowmentPeriod) {
      final updated = await _subscriptionService.incrementConversationCount(
        _subscription,
      );
      _setSubscription(updated, onSubscriptionChanged);
    }

    // Dismiss recommendation on send
    _dismissRecommendation();

    final previousMessages = List<CoachChatMessage>.from(_messages);
    final userMessage = CoachChatMessage(
      role: 'user',
      content: text.trim(),
      timestamp: DateTime.now(),
    );

    _error = null;
    _messages = [..._messages, userMessage];
    notifyListeners();

    unawaited(
      AnalyticsService.instance.trackEvent(
        'coach_message_sent',
        properties: {
          'selected_mode': _selectedMode.name,
          'message_length': text.trim().length,
          'had_history': previousMessages.isNotEmpty,
        },
      ),
    );

    try {
      final modeResult = await _subscriptionService.resolveAndConsumeCoachMode(
        _subscription,
        requestedMode: _selectedMode,
      );
      final nextSubscription = modeResult.state;
      final resolution = modeResult.resolution;
      _subscription = nextSubscription;
      _lastModeResolution = resolution;
      onSubscriptionChanged(nextSubscription);

      // Show downgrade transition card on first fallback
      if (resolution.usedFallback && !_subscription.downgradeCardShown) {
        final marked = await _subscriptionService.markDowngradeCardShown(
          _subscription,
        );
        _setSubscription(marked, onSubscriptionChanged);
      }

      final effectiveMode = resolution.effectiveMode;
      final taxSystem = getTaxSystem(settings.country);
      final summary = calculateBudgetSummary(
        settings.salaries,
        settings.personalInfo,
        settings.expenses,
        taxSystem,
      );
      final reply = await _service.sendChatMessage(
        apiKey: apiKey,
        userMessage: text.trim(),
        history: previousMessages,
        contextWindow: _subscription.contextWindowForMode(effectiveMode),
        settings: settings,
        summary: summary,
        purchaseHistory: purchaseHistory,
        maxTokens: maxTokensForMode(effectiveMode),
        effectiveMode: effectiveMode,
        lastMicroAction: _subscription.lastMicroAction,
        lastMicroActionDate: _subscription.lastMicroActionDate,
      );

      // Parse delimiters from reply
      final cleanedReply =
          await _parseAndStoreDelimiters(reply, effectiveMode, onSubscriptionChanged);

      _messages = [
        ..._messages,
        CoachChatMessage(
          role: 'assistant',
          content: cleanedReply,
          timestamp: DateTime.now(),
        ),
      ];
      await _service.saveConversation(householdId, _messages);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }

    return true;
  }

  /// Max tokens per mode tier.
  static int maxTokensForMode(CoachMode mode) {
    switch (mode) {
      case CoachMode.eco:
        return 450;
      case CoachMode.plus:
        return 900;
      case CoachMode.pro:
        return 1200;
    }
  }

  // ---------------------------------------------------------------------------
  // Mode management
  // ---------------------------------------------------------------------------

  Future<void> setPreferredMode(
    CoachMode mode,
    void Function(SubscriptionState) onSubscriptionChanged,
  ) async {
    final updated = await _subscriptionService.setPreferredCoachMode(
      _subscription,
      mode,
    );
    _subscription = updated;
    _selectedMode = mode;
    onSubscriptionChanged(updated);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mode recommendation
  // ---------------------------------------------------------------------------

  void checkRecommendation(String text, {required String locale}) {
    _recommendationDebounce?.cancel();
    if (text.trim().isEmpty) {
      _dismissRecommendation();
      return;
    }
    _recommendationDebounce = Timer(const Duration(milliseconds: 300), () {
      final recommended = recommendMode(text, locale: locale);
      if (recommended.index > _selectedMode.index &&
          _subscription.aiCredits >=
              _subscription.creditCostForMode(recommended)) {
        _pendingRecommendation = recommended;
        _showRecommendation = true;
        notifyListeners();
        _recommendationTimer?.cancel();
        _recommendationTimer =
            Timer(AppConstants.recommendationAutoDismiss, () {
          _dismissRecommendation();
        });
      } else if (recommended == _selectedMode) {
        _pendingRecommendation = null;
        _showRecommendation = false;
        notifyListeners();
      } else {
        _dismissRecommendation();
      }
    });
  }

  Future<void> acceptRecommendation(
    void Function(SubscriptionState) onSubscriptionChanged,
  ) async {
    if (_pendingRecommendation == null) return;
    final mode = _pendingRecommendation!;
    await setPreferredMode(mode, onSubscriptionChanged);
    final updated = await _subscriptionService.trackRecommendation(
      _subscription,
      accepted: true,
    );
    _setSubscription(updated, onSubscriptionChanged);
    _dismissRecommendation();
  }

  Future<void> declineRecommendation(
    void Function(SubscriptionState) onSubscriptionChanged,
  ) async {
    final updated = await _subscriptionService.trackRecommendation(
      _subscription,
      accepted: false,
    );
    _setSubscription(updated, onSubscriptionChanged);
    _dismissRecommendation();
  }

  void _dismissRecommendation() {
    _recommendationTimer?.cancel();
    if (_showRecommendation) {
      _pendingRecommendation = null;
      _showRecommendation = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Micro-action management
  // ---------------------------------------------------------------------------

  Future<void> completeMicroAction(
    void Function(SubscriptionState) onSubscriptionChanged,
  ) async {
    final updated = await _subscriptionService.clearLastMicroAction(
      _subscription,
    );
    _setSubscription(updated, onSubscriptionChanged);
  }

  // ---------------------------------------------------------------------------
  // Delimiter parsing
  // ---------------------------------------------------------------------------

  Future<String> _parseAndStoreDelimiters(
    String reply,
    CoachMode effectiveMode,
    void Function(SubscriptionState) onSubscriptionChanged,
  ) async {
    var cleaned = reply;

    // SESSION_INSIGHT
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
        _setSubscription(updated, onSubscriptionChanged);
      }
      cleaned = cleaned.replaceAll(_sessionInsightRegex, '').trim();
    }

    // MICRO_ACTION (Pro only)
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
          _setSubscription(updated, onSubscriptionChanged);
        }
        cleaned = cleaned.replaceAll(_microActionRegex, '').trim();
      }
    }

    // Track session completed
    final tracked = await _subscriptionService.trackSessionCompleted(
      _subscription,
      effectiveMode,
    );
    _setSubscription(tracked, onSubscriptionChanged);

    return cleaned;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setSubscription(
    SubscriptionState updated,
    void Function(SubscriptionState) onSubscriptionChanged,
  ) {
    _subscription = updated;
    onSubscriptionChanged(updated);
    notifyListeners();
  }

  @override
  void dispose() {
    _recommendationTimer?.cancel();
    _recommendationDebounce?.cancel();
    super.dispose();
  }
}
