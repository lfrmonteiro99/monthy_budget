import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/biometric_service.dart';
import '../../theme/app_colors.dart';

class BiometricLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const BiometricLockScreen({super.key, required this.onUnlocked});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  final _biometricService = BiometricService();
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerAuth());
  }

  Future<void> _triggerAuth() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);

    final l10n = S.of(context);
    final success = await _biometricService.authenticate(
      reason: l10n.biometricReason,
    );

    if (!mounted) return;
    setState(() => _authenticating = false);

    if (success) {
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return CalmScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: AppColors.primary(context),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.biometricPrompt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 32),
              if (_authenticating)
                CircularProgressIndicator(color: AppColors.primary(context))
              else
                FilledButton.icon(
                  onPressed: _triggerAuth,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.biometricRetry),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
