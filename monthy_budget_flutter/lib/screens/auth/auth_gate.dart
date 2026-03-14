import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/biometric_service.dart';
import '../../services/household_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/branded_loading.dart';
import 'biometric_lock_screen.dart';
import 'login_screen.dart';
import 'household_setup_screen.dart';

class AuthGate extends StatefulWidget {
  final Widget Function(HouseholdProfile profile) appBuilder;
  const AuthGate({super.key, required this.appBuilder});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _householdService = HouseholdService();
  HouseholdProfile? _profile;
  bool _loadingProfile = false;
  bool _profileFetched = false; // true once getProfile() has completed
  String? _profileError; // non-null when getProfile() failed

  void _loadProfile() {
    if (_loadingProfile || _profileFetched) return;
    _loadingProfile = true;
    _profileError = null;
    _householdService.getProfile().then((p) {
      if (mounted) {
        setState(() {
          _profile = p;
          _loadingProfile = false;
          _profileFetched = true;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
          _profileFetched = true;
          _profileError = e.toString();
        });
      }
    });
  }

  void _reset() {
    _profile = null;
    _loadingProfile = false;
    _profileFetched = false;
    _profileError = null;
  }

  void _retryProfile() {
    setState(() {
      _profileFetched = false;
      _profileError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        // Not authenticated → Login
        if (session == null) {
          _reset();
          return LoginScreen(onAuthenticated: _loadProfile);
        }

        // Authenticated but profile not fetched yet → fetch + show spinner
        if (!_profileFetched) {
          _loadProfile();
          return const _Loading();
        }

        // Profile fetch failed → show error with retry
        if (_profileError != null) {
          return _ErrorScreen(
            error: _profileError!,
            onRetry: _retryProfile,
            onSignOut: () => Supabase.instance.client.auth.signOut(),
          );
        }

        // Profile fetched but no household → Setup
        if (_profile == null) {
          return HouseholdSetupScreen(
            onSetupComplete: (profile) => setState(() => _profile = profile),
          );
        }

        // Fully ready — wrap with biometric gate
        return _BiometricGate(
          child: widget.appBuilder(_profile!),
        );
      },
    );
  }
}

/// Wraps the authenticated app content.  On [AppLifecycleState.resumed],
/// if biometric lock is enabled, shows the lock screen overlay.
/// Does NOT lock on first build (initial session restore).
class _BiometricGate extends StatefulWidget {
  final Widget child;
  const _BiometricGate({required this.child});

  @override
  State<_BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<_BiometricGate>
    with WidgetsBindingObserver {
  final _biometricService = BiometricService();
  bool _locked = false;
  bool _didFirstBuild = false;
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Mark first build complete after the frame so we skip locking on
    // initial session restore.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _didFirstBuild = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wasPaused = true;
    }
    if (state == AppLifecycleState.resumed && _didFirstBuild && _wasPaused) {
      _wasPaused = false;
      _checkAndLock();
    }
  }

  Future<void> _checkAndLock() async {
    final enabled = await _biometricService.isEnabled();
    if (enabled && mounted) {
      setState(() => _locked = true);
    }
  }

  void _unlock() {
    if (mounted) {
      setState(() => _locked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return BiometricLockScreen(onUnlocked: _unlock);
    }
    return widget.child;
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const BrandedLoading();
  }
}

class _ErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  const _ErrorScreen({
    required this.error,
    required this.onRetry,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 56, color: AppColors.error(context)),
              const SizedBox(height: 16),
              Text(
                S.of(context).authConnectionError,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(S.of(context).authRetry),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onSignOut,
                child: Text(S.of(context).authSignOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
