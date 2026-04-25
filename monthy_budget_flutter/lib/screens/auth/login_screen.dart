import 'dart:io';
import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../exceptions/app_exceptions.dart' as app;
import '../../l10n/generated/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const LoginScreen({super.key, required this.onAuthenticated});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  bool _registrationSuccess = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
      _registrationSuccess = false;
    });
    try {
      if (_isLogin) {
        await _auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
        widget.onAuthenticated();
      } else {
        await _auth.signUp(_emailCtrl.text.trim(), _passCtrl.text);
        if (!mounted) return;
        setState(() {
          _registrationSuccess = true;
          _isLogin = true;
          _passCtrl.clear();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object e) {
    final l10n = S.of(context);

    // Unwrap app-level AuthException to inspect the original Supabase error.
    final inner = e is app.AuthException ? (e.originalError ?? e) : e;

    // Network / DNS errors
    if (inner is SocketException ||
        inner.toString().contains('SocketException') ||
        inner.toString().contains('Failed host lookup') ||
        inner.toString().contains('Connection refused') ||
        inner.toString().contains('AuthRetryableFetchException')) {
      return l10n.authErrorNetwork;
    }

    // Supabase auth errors
    if (inner is AuthException) {
      final msg = inner.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid email or password')) {
        return l10n.authErrorInvalidCredentials;
      }
      if (msg.contains('email not confirmed')) {
        return l10n.authErrorEmailNotConfirmed;
      }
      if (msg.contains('rate limit') || msg.contains('too many requests')) {
        return l10n.authErrorTooManyRequests;
      }
    }

    return l10n.authErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    return CalmScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet,
                  size: 64, color: AppColors.primary(context)),
              const SizedBox(height: 8),
              Text(
                S.of(context).appTitle,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _isLogin ? S.of(context).authLogin : S.of(context).authRegister,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary(context)),
              ),
              if (_registrationSuccess) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.success(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success(context).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.mark_email_read_outlined, size: 20, color: AppColors.success(context)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          S.of(context).authRegistrationSuccess,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.success(context),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: S.of(context).authEmail,
                  hintText: S.of(context).authEmailHint,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: S.of(context).authPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => _submit(),
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
                      : Text(_isLogin ? S.of(context).authLoginButton : S.of(context).authRegisterButton),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _isLogin = !_isLogin;
                  _registrationSuccess = false;
                  _error = null;
                }),
                child:
                    Text(_isLogin ? S.of(context).authSwitchToRegister : S.of(context).authSwitchToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
