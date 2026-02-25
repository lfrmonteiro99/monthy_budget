import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/coach_insight.dart';
import '../models/purchase_record.dart';
import '../services/ai_coach_service.dart';
import '../utils/calculations.dart';

class CoachScreen extends StatefulWidget {
  final AppSettings settings;
  final PurchaseHistory purchaseHistory;
  final String apiKey;
  final VoidCallback onOpenSettings;

  const CoachScreen({
    super.key,
    required this.settings,
    required this.purchaseHistory,
    required this.apiKey,
    required this.onOpenSettings,
  });

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _service = AiCoachService();
  CoachInsight? _currentInsight;
  List<CoachInsight> _insights = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final insights = await _service.loadInsights();
    if (mounted) setState(() => _insights = insights);
  }

  Future<void> _analyze() async {
    if (widget.apiKey.isEmpty) {
      setState(() => _error =
          'Adiciona a tua OpenAI API key nas Definições para usar esta funcionalidade.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _currentInsight = null;
    });
    try {
      final summary = calculateBudgetSummary(
        widget.settings.salaries,
        widget.settings.personalInfo,
        widget.settings.expenses,
      );
      final result = await _service.analyze(
        apiKey: widget.apiKey,
        settings: widget.settings,
        summary: summary,
        purchaseHistory: widget.purchaseHistory,
      );
      if (mounted) {
        setState(() {
          _currentInsight = result.insight;
          _insights = result.history;
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

  Future<void> _deleteInsight(String id) async {
    final updated = await _service.deleteInsight(id);
    if (mounted) {
      setState(() {
        _insights = updated;
        if (_currentInsight?.id == id) _currentInsight = null;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Text('Tens a certeza que queres apagar todas as análises guardadas?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.clearInsights();
      if (mounted) setState(() => _insights = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coach Financeiro',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            Text(
              'IA · GPT-4o mini',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Análise financeira em 3 partes',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Posicionamento geral · Factores críticos do Índice de Tranquilidade · Oportunidade imediata. '
                  'Baseado nos teus dados reais de orçamento, despesas e histórico de compras.',
                  style:
                      TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
                ),
                if (widget.apiKey.isEmpty) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: widget.onOpenSettings,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings_outlined,
                            size: 14, color: Color(0xFF3B82F6)),
                        SizedBox(width: 4),
                        Text(
                          'Configurar API key nas Definições',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B82F6)),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: Color(0xFF10B981), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'API key configurada',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _loading ? null : _analyze,
        icon: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.psychology_outlined, size: 20),
        label: Text(
          _loading ? 'A analisar...' : 'Analisar o meu orçamento',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          disabledBackgroundColor:
              const Color(0xFF3B82F6).withValues(alpha: 0.5),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.04),
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
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lightbulb_outline,
                    size: 16, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Análise personalizada',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B)),
                ),
              ),
              _ScoreBadge(score: insight.stressScore),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          Text(
            insight.content,
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF334155), height: 1.65),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.refresh, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _loading ? null : _analyze,
                child: const Text(
                  'Gerar nova análise',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    // Show previous insights (skip the current one, already shown above)
    final history = _currentInsight != null
        ? _insights.where((i) => i.id != _currentInsight!.id).toList()
        : _insights;

    if (history.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'HISTÓRICO',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.8),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${history.length}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _clearHistory,
              child: const Text(
                'Limpar tudo',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500),
              ),
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

// ── Widgets ──────────────────────────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  final int score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? const Color(0xFF10B981)
        : score >= 60
            ? const Color(0xFF3B82F6)
            : score >= 40
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF4444);
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

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month]} ${dt.year} · $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.insight;
    final preview = insight.content.length > 100
        ? '${insight.content.substring(0, 100)}…'
        : insight.content;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                              _formatDate(insight.timestamp),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            _ScoreBadge(score: insight.stressScore),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _expanded ? insight.content : preview,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
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
                        color: const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: const Icon(Icons.delete_outline,
                            size: 16, color: Color(0xFFCBD5E1)),
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
