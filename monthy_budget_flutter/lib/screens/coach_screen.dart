import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../data/tax/tax_factory.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/purchase_record.dart';
import '../models/subscription_state.dart';
import '../onboarding/coach_tour.dart';
import '../services/ai_coach_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_colors.dart';
import '../utils/calculations.dart';
import '../widgets/info_icon_button.dart';

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

  final List<String> _quickPrompts = const [
    'Onde posso cortar despesas este mes?',
    'Como melhoro a minha poupanca sem perder qualidade de vida?',
    'Ajuda-me a definir um plano para os proximos 30 dias.',
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
        Future.delayed(const Duration(milliseconds: 500), () {
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

  Future<void> _sendCurrentMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty || _loading) return;

    final previousMessages = List<CoachChatMessage>.from(_messages);
    final userMessage = CoachChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    _composerController.clear();
    setState(() {
      _loading = true;
      _error = null;
      _messages = [..._messages, userMessage];
    });
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
      );

      if (!mounted) return;
      final updated = [
        ..._messages,
        CoachChatMessage(
          role: 'assistant',
          content: reply,
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
              style: TextStyle(color: AppColors.error(context)),
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
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        surfaceTintColor: AppColors.surface(context),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.coachTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            Text(
              l10n.coachSubtitle,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted(context),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          InfoIconButton(
            title: l10n.coachTitle,
            body: l10n.infoCoachModes,
          ),
          IconButton(
            onPressed: _clearConversation,
            tooltip: l10n.coachClearAll,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: _buildModeCard(),
            ),
            if (_lastModeResolution?.usedFallback == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: _buildFallbackCard(),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: _buildErrorCard(),
              ),
            Expanded(
              child: Container(
                key: CoachTourKeys.historyList,
                margin: const EdgeInsets.only(top: 8),
                child: _buildMessagesList(),
              ),
            ),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Faz uma pergunta sobre o teu orcamento. '
                'Vou manter o contexto conforme a memoria ativa.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _quickPrompts
                    .map(
                      (prompt) => ActionChip(
                        label: Text(prompt),
                        onPressed: () {
                          _composerController.text = prompt;
                          _sendCurrentMessage();
                        },
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
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
      itemCount: _messages.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_loading && index == _messages.length) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor:
                        AppColors.primary(context).withValues(alpha: 0.2),
                    child: Icon(
                      Icons.psychology_alt_rounded,
                      size: 12,
                      color: AppColors.primary(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final message = _messages[index];
        return _MessageBubble(message: message);
      },
    );
  }

  Widget _buildComposer() {
    final l10n = S.of(context);
    final costNow = _subscription.creditCostForMode(_selectedMode);
    return Container(
      key: CoachTourKeys.analyzeButton,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _composerController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendCurrentMessage(),
                  decoration: InputDecoration(
                    hintText: 'Escreve uma mensagem...',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading ? null : _sendCurrentMessage,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(14),
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
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  costNow == 0
                      ? 'Esta mensagem nao consome creditos (modo Eco).'
                      : 'Esta mensagem vai consumir $costNow creditos. A resposta nao consome creditos.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted(context),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Memoria do Coach',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(width: 6),
              InfoIconButton(
                title: l10n.coachTitle,
                body: l10n.infoCoachModes,
              ),
              const Spacer(),
              Text(
                '${_subscription.aiCredits} creditos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
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
          const SizedBox(height: 8),
          Text(
            'Memoria ativa: ${effectiveMode.name.toUpperCase()} ($usagePct%)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Custo por mensagem enviada. A resposta do coach nao consome creditos.',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeChip(CoachMode mode, String label) {
    final selected = _selectedMode == mode;
    final cost = _subscription.creditCostForMode(mode);
    final subtitle = cost == 0 ? 'Gratis' : '$cost/msg';
    return ChoiceChip(
      label: Text('$label - $subtitle'),
      selected: selected,
      onSelected: _loading ? null : (_) => _setPreferredMode(mode),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color:
            selected ? AppColors.onPrimary(context) : AppColors.textPrimary(context),
      ),
      selectedColor: AppColors.primary(context),
      backgroundColor: AppColors.surfaceVariant(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.border(context)),
      ),
    );
  }

  Widget _buildFallbackCard() {
    final compact = _ecoBannerCollapsed;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warningBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning(context).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Modo Eco ativo (sem creditos).',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning(context),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _ecoBannerCollapsed = !_ecoBannerCollapsed);
                },
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                tooltip: compact ? 'Expandir aviso' : 'Minimizar aviso',
                icon: Icon(
                  compact ? Icons.expand_more : Icons.expand_less,
                  color: AppColors.warning(context),
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 2),
            Text(
              'Podes continuar a conversar, mas com memoria reduzida.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.warning(context),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: widget.onRestoreMemory ?? widget.onOpenSettings,
                child: const Text('Restaurar memoria'),
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
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFDC2626),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
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
    final bubbleColor = isUser
        ? AppColors.primary(context)
        : AppColors.surfaceVariant(context);
    final textColor =
        isUser ? AppColors.onPrimary(context) : AppColors.textPrimary(context);
    final labelColor =
        isUser ? AppColors.textSecondary(context) : AppColors.textMuted(context);
    final avatarBg = isUser
        ? AppColors.primary(context).withValues(alpha: 0.2)
        : AppColors.surfaceVariant(context);
    final avatarIconColor =
        isUser ? AppColors.primary(context) : AppColors.textSecondary(context);

    return Align(
      alignment: align,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                  isUser ? 'Tu' : 'Coach',
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(12),
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
                      p: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        height: 1.6,
                      ),
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
