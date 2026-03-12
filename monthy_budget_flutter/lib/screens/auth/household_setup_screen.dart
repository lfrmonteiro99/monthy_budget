import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/app_settings.dart';
import '../../services/household_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';

class HouseholdSetupScreen extends StatefulWidget {
  final void Function(HouseholdProfile profile) onSetupComplete;
  const HouseholdSetupScreen({super.key, required this.onSetupComplete});

  @override
  State<HouseholdSetupScreen> createState() => _HouseholdSetupScreenState();
}

class _HouseholdSetupScreenState extends State<HouseholdSetupScreen> {
  final _service = HouseholdService();
  final _settingsService = SettingsService();
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
        if (name.isEmpty) throw Exception(S.of(context).householdNameRequired);
        profile = await _service.createHousehold(name);
        // Explicitly write setupWizardCompleted: false so the wizard
        // is guaranteed to appear regardless of what the RPC seeds.
        await _settingsService.save(const AppSettings(), profile.householdId);
      } else {
        profile = await _service.joinHousehold(_codeCtrl.text.trim());
      }
      widget.onSetupComplete(profile);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline,
                  size: 64, color: AppColors.primary(context)),
              const SizedBox(height: 8),
              Text(
                S.of(context).householdSetupTitle,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                      value: true,
                      label: Text(S.of(context).householdCreate),
                      icon: const Icon(Icons.add)),
                  ButtonSegment(
                      value: false,
                      label: Text(S.of(context).householdJoinWithCode),
                      icon: const Icon(Icons.link)),
                ],
                selected: {_creating},
                onSelectionChanged: (s) =>
                    setState(() => _creating = s.first),
              ),
              const SizedBox(height: 20),
              if (_creating)
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: S.of(context).householdNameLabel,
                    hintText: S.of(context).householdNameHint,
                    border: const OutlineInputBorder(),
                  ),
                )
              else
                TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: S.of(context).householdCodeLabel,
                    hintText: S.of(context).householdCodeHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: TextStyle(color: AppColors.error(context), fontSize: 13)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              color: AppColors.onPrimary(context), strokeWidth: 2))
                      : Text(_creating
                          ? S.of(context).householdCreateButton
                          : S.of(context).householdJoinButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
