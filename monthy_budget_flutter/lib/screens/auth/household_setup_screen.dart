import 'package:flutter/material.dart';
import '../../services/household_service.dart';

class HouseholdSetupScreen extends StatefulWidget {
  final void Function(HouseholdProfile profile) onSetupComplete;
  const HouseholdSetupScreen({super.key, required this.onSetupComplete});

  @override
  State<HouseholdSetupScreen> createState() => _HouseholdSetupScreenState();
}

class _HouseholdSetupScreenState extends State<HouseholdSetupScreen> {
  final _service = HouseholdService();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _creating = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final HouseholdProfile profile;
      if (_creating) {
        final name = _nameCtrl.text.trim();
        if (name.isEmpty) throw Exception('Indica o nome do agregado.');
        profile = await _service.createHousehold(name);
      } else {
        profile = await _service.joinHousehold(_codeCtrl.text.trim());
      }
      widget.onSetupComplete(profile);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_outline,
                  size: 64, color: Color(0xFF3B82F6)),
              const SizedBox(height: 8),
              Text(
                'Configurar Agregado',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                      value: true,
                      label: Text('Criar'),
                      icon: Icon(Icons.add)),
                  ButtonSegment(
                      value: false,
                      label: Text('Entrar com código'),
                      icon: Icon(Icons.link)),
                ],
                selected: {_creating},
                onSelectionChanged: (s) =>
                    setState(() => _creating = s.first),
              ),
              const SizedBox(height: 20),
              if (_creating)
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome do agregado',
                    hintText: 'ex: Família Silva',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Código de convite',
                    hintText: 'XXXXXX',
                    border: OutlineInputBorder(),
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_creating
                          ? 'Criar Agregado'
                          : 'Entrar no Agregado'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
