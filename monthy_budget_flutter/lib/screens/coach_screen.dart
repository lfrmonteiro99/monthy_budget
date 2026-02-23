import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/grocery_data.dart';
import '../services/ai_coach_service.dart';
import '../utils/calculations.dart';

class CoachScreen extends StatefulWidget {
  final AppSettings settings;
  final GroceryData groceryData;
  final String apiKey;
  final VoidCallback onOpenSettings;

  const CoachScreen({
    super.key,
    required this.settings,
    required this.groceryData,
    required this.apiKey,
    required this.onOpenSettings,
  });

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _service = AiCoachService();
  String? _advice;
  bool _loading = false;
  String? _error;

  Future<void> _analyze() async {
    if (widget.apiKey.isEmpty) {
      setState(() => _error = 'Adiciona a tua OpenAI API key nas Definições para usar esta funcionalidade.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _advice = null;
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
        groceryData: widget.groceryData,
      );
      setState(() => _advice = result);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            Text(
              'IA · GPT-4o mini',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), letterSpacing: 1.2),
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
          if (_advice != null) _buildAdviceCard(),
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
                  'Análise inteligente do teu orçamento',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'O GPT-4o mini analisa os teus dados reais de orçamento e preços de supermercado para gerar conselhos personalizados.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
                ),
                if (widget.apiKey.isEmpty) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: widget.onOpenSettings,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings_outlined, size: 14, color: Color(0xFF3B82F6)),
                        SizedBox(width: 4),
                        Text(
                          'Configurar API key nas Definições',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
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
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'API key configurada',
                        style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
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
          disabledBackgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard() {
    return Container(
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
                child: const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Conselhos personalizados',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          Text(
            _advice!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF334155),
              height: 1.65,
            ),
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
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
