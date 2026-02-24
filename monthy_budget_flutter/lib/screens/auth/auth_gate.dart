import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/household_service.dart';
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

  void _loadProfile() {
    if (_loadingProfile) return;
    _loadingProfile = true;
    _householdService.getProfile().then((p) {
      if (mounted) {
        setState(() {
          _profile = p;
          _loadingProfile = false;
        });
      }
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
          _profile = null;
          return LoginScreen(onAuthenticated: _loadProfile);
        }

        // Authenticated but profile not loaded yet
        if (_profile == null && !_loadingProfile) {
          _loadProfile();
          return const _Loading();
        }

        if (_loadingProfile) {
          return const _Loading();
        }

        // Authenticated but no household → Setup
        if (_profile == null) {
          return HouseholdSetupScreen(
            onSetupComplete: (profile) => setState(() => _profile = profile),
          );
        }

        // Fully ready
        return widget.appBuilder(_profile!);
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
