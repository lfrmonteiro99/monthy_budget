import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/coach_insight.dart';
import '../models/purchase_record.dart';
import '../models/subscription_state.dart';
import '../services/ai_coach_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_colors.dart';
import '../utils/calculations.dart';
import '../data/tax/tax_factory.dart';
import '../onboarding/coach_tour.dart';

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
  CoachInsight? _currentInsight;
  List<CoachInsight> _insights = [];
  bool _loading = false;
  String? _error;
  CoachModeResolution? _lastModeResolution;
  late SubscriptionState _subscription;
  late CoachMode _selectedMode;
  String? _coachThreadId;

  bool _tourShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = widget.subscription;
    _selectedMode = _subscription.preferredCoachMode;
    _loadHistory();
    if (widget.showTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_tourShown && mounted) {
          _tourShown = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            buildCoachTour(
              context: context,
              onFinish: () => widget.onTourComplete?.call(),
              onSkip: () => widget.onTourComplete?.call(),
            ).show(context: context);
          });
        }
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    final insights = await _service.loadInsights(widget.householdId);
    if (mounted) setState(() => _insights = insights);
  }

  Future<void> _analyze() async {
    setState(() {
      _loading = true;
      _error = null;
      _currentInsight = null;
    });
    try {
      final creditsBefore = _subscription.aiCredits;
      final modeResult = await _subscriptionService.resolveAndConsumeCoachMode(
        _subscription,
        requestedMode: _selectedMode,
      );
      final nextSubscription = modeResult.state;
      final resolution = modeResult.resolution;
      final creditsAfter = nextSubscription.aiCredits;
      final debitedCredits = (creditsBefore - creditsAfter).clamp(0, 999999);
      final clientAuditId =
          'coach_${DateTime.now().millisecondsSinceEpoch}_${resolution.requestedMode.name}_${resolution.effectiveMode.name}';
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
      final result = await _service.analyze(
        apiKey: widget.apiKey,
        householdId: widget.householdId,
        settings: widget.settings,
        summary: summary,
        purchaseHistory: widget.purchaseHistory,
        coachMode: effectiveMode,
        requestedCoachMode: _selectedMode,
        coachUsedFallback: resolution.usedFallback,
        coachFallbackReason: resolution.reason,
        coachClientAuditId: clientAuditId,
        coachDebitedCredits: debitedCredits,
        coachCreditsBefore: creditsBefore,
        coachCreditsAfter: creditsAfter,
        coachThreadId: _coachThreadId,
        coachContextWindow: _subscription.contextWindowForMode(effectiveMode),
        maxTokens: _maxTokensForMode(effectiveMode),
      );
      if (mounted) {
        setState(() {
          _currentInsight = result.insight;
          _insights = result.history;
          _coachThreadId = result.threadId ?? _coachThreadId;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _maxTokensForMode(CoachMode mode) {
    switch (mode) {
      case CoachMode.eco:
        return 600;
      case CoachMode.plus:
        return 1000;
      case CoachMode.pro:
        return 1400;
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

  Future<void> _deleteInsight(String id) async {
    final updated = await _service.deleteInsight(id, widget.householdId);
    if (mounted) {
      setState(() {
        _insights = updated;
        if (_currentInsight?.id == id) _currentInsight = null;
      });
    }
  }

  Future<void> _clearHistory() async {
    final l10n = S.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.coachClearTitle),
        content: Text(l10n.coachClearContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.clear, style: TextStyle(color: AppColors.error(context))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.clearInsights(widget.householdId);
      if (mounted) setState(() => _insights = []);
    }
  }

  Future<void> _exportCoachMemory() async {
    setState(() => _loading = true);
    try {
      final json = await _service.exportCoachMemoryJson(widget.householdId);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Exportar memoria do Coach'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                json,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: json));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Memoria copiada para a area de transferencia'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Copiar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _clearCoachMemory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar memoria do Coach?'),
        content: const Text(
          'Isto remove memorias, resumos e contexto do chat do Coach para este utilizador.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Limpar',
              style: TextStyle(color: AppColors.error(context)),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await _service.clearCoachMemories(widget.householdId);
      if (!mounted) return;
      setState(() => _coachThreadId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memoria do Coach limpa com sucesso'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary(context)),
            ),
            Text(
              l10n.coachSubtitle,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted(context),
                  letterSpacing: 1.2),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildModeCard(),
          const SizedBox(height: 12),
          if (_lastModeResolution?.usedFallback == true) ...[
            _buildFallbackCard(),
            const SizedBox(height: 12),
          ],
          _buildAnalyzeButton(),
          const SizedBox(height: 16),
          if (_error != null) _buildErrorCard(),
          if (_currentInsight != null) _buildAdviceCard(_currentInsight!),
          _buildHistorySection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final l10n = S.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.auto_awesome, size: 18, color: AppColors.primary(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.coachAnalysisTitle,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context)),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.coachAnalysisDescription,
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary(context), height: 1.5),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: AppColors.success(context), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'IA segura via servidor',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.success(context),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard() {
    final activeResolution = _lastModeResolution;
    final effectiveMode = activeResolution?.effectiveMode ?? _selectedMode;
    final window = _subscription.contextWindowForMode(effectiveMode);
    final usagePct = ((_insights.length / window) * 100).clamp(0, 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
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
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton(
                onPressed: _loading ? null : _exportCoachMemory,
                child: const Text('Exportar memoria'),
              ),
              TextButton(
                onPressed: _loading ? null : _clearCoachMemory,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error(context),
                ),
                child: const Text('Limpar memoria'),
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
            'Memoria ativa: ${effectiveMode.name.toUpperCase()} ($usagePct%)',
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
      label: Text('$label · $subtitle'),
      selected: selected,
      onSelected: _loading ? null : (_) => _setPreferredMode(mode),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.onPrimary(context) : AppColors.textPrimary(context),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning(context).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modo Eco ativo (sem creditos).',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.warning(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Posso nao lembrar conversas anteriores. Restaura memoria para maior continuidade.',
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
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final l10n = S.of(context);
    return SizedBox(
      key: CoachTourKeys.analyzeButton,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _loading ? null : _analyze,
        icon: _loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary(context)),
              )
            : const Icon(Icons.psychology_outlined, size: 20),
        label: Text(
          _loading ? l10n.coachAnalyzing : l10n.coachAnalyzeButton,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary(context),
          disabledBackgroundColor:
              AppColors.primary(context).withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
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
                  fontSize: 13, color: Color(0xFFDC2626), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(CoachInsight insight) {
    final l10n = S.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shimmer(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.infoBackground(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.lightbulb_outline,
                    size: 16, color: AppColors.primary(context)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.coachCustomAnalysis,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context)),
                ),
              ),
              _ScoreBadge(score: insight.stressScore),
            ],
          ),
          Divider(height: 24, color: AppColors.surfaceVariant(context)),
          Text(
            insight.content,
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF334155), height: 1.65),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _loading ? null : _analyze,
            icon: const Icon(Icons.refresh, size: 14),
            label: Text(
              l10n.coachNewAnalysis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary(context),
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    final l10n = S.of(context);
    final history = _currentInsight != null
        ? _insights.where((i) => i.id != _currentInsight!.id).toList()
        : _insights;

    if (history.isEmpty) return const SizedBox();

    return Column(
      key: CoachTourKeys.historyList,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  l10n.coachHistory,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted(context),
                      letterSpacing: 0.8),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.border(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${history.length}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLabel(context)),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _clearHistory,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary(context),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                minimumSize: const Size(48, 40),
              ),
              child: Text(l10n.coachClearAll),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...history.map((insight) => _InsightHistoryCard(
              insight: insight,
              onDelete: () => _deleteInsight(insight.id),
            )),
      ],
    );
  }
}

// -- Widgets ------------------------------------------------------------------

class _ScoreBadge extends StatelessWidget {
  final int score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? AppColors.success(context)
        : score >= 60
            ? AppColors.primary(context)
            : score >= 40
                ? AppColors.warning(context)
                : AppColors.error(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$score/100',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _InsightHistoryCard extends StatefulWidget {
  final CoachInsight insight;
  final VoidCallback onDelete;
  const _InsightHistoryCard({required this.insight, required this.onDelete});

  @override
  State<_InsightHistoryCard> createState() => _InsightHistoryCardState();
}

class _InsightHistoryCardState extends State<_InsightHistoryCard> {
  bool _expanded = false;

  String _formatDate(DateTime dt, S l10n) {
    final months = [
      '', l10n.monthAbbrJan, l10n.monthAbbrFeb, l10n.monthAbbrMar,
      l10n.monthAbbrApr, l10n.monthAbbrMay, l10n.monthAbbrJun,
      l10n.monthAbbrJul, l10n.monthAbbrAug, l10n.monthAbbrSep,
      l10n.monthAbbrOct, l10n.monthAbbrNov, l10n.monthAbbrDec,
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month]} ${dt.year} \u00b7 $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final insight = widget.insight;
    final preview = insight.content.length > 100
        ? '${insight.content.substring(0, 100)}...'
        : insight.content;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatDate(insight.timestamp, l10n),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted(context),
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            _ScoreBadge(score: insight.stressScore),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _expanded ? insight.content : preview,
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textLabel(context),
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: AppColors.textMuted(context),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        button: true,
                        label: l10n.coachDeleteLabel,
                        child: IconButton(
                          onPressed: widget.onDelete,
                          icon: const Icon(Icons.delete_outline, size: 16),
                          color: AppColors.textMuted(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          tooltip: l10n.coachDeleteTooltip,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
