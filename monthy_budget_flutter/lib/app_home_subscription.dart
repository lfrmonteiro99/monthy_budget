part of 'main.dart';

/// Subscription, paywall and downgrade methods for [_AppHomeState].
extension _AppHomeSubscription on _AppHomeState {
  /// Check if the user needs downgrade handling (trial expired or subscription cancelled).
  Future<void> _checkDowngrade() async {
    if (!_subscription.justDowngraded) return;

    // Apply free-tier limits if not already done
    final alreadyApplied = await _subscriptionService.isDowngradeApplied();
    if (!alreadyApplied) {
      await _downgradeService.applyFreeTierLimits(
        settings: _settings,
        goals: _savingsGoals,
        onSaveSettings: _saveSettings,
        householdId: widget.householdId,
        savingsGoalService: _savingsGoalService,
      );
      await _subscriptionService.markDowngradeApplied();
      // Reload goals after deactivation
      await _loadSavingsGoals();
    }

    // Show the trial-expired bottom sheet once
    final noticeSeen = await _subscriptionService.isTrialEndNoticeSeen();
    if (!noticeSeen && mounted) {
      // Wait for the next frame so the UI is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final action = await showTrialExpiredBottomSheet(
          context: context,
          expenses: _settings.expenses,
          savingsGoals: _savingsGoals,
        );
        await _subscriptionService.markTrialEndNoticeSeen();
        if (!mounted) return;
        if (action == TrialExpiredAction.upgrade) {
          _openPaywall();
        } else if (action == TrialExpiredAction.manageCategories) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _buildSettingsScreen(initialSection: 'expenses'),
            ),
          );
        }
      });
    }
  }

  /// Login to RevenueCat and sync the remote subscription tier.
  Future<void> _syncRevenueCat() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      await RevenueCatService.login(user?.id);
      final remoteTier = await RevenueCatService.getCurrentTier();
      final updated = await _subscriptionService.syncFromRemoteTier(
          _subscription, remoteTier);
      if (mounted && updated != _subscription) {
        setState(() => _subscription = updated);
      }
    } catch (e) {
      debugPrint('RevenueCat sync error: $e');
    }
  }

  /// Track that a feature was explored during trial.
  void _trackFeature(String featureKey) async {
    final updated =
        await _subscriptionService.markFeatureExplored(_subscription, featureKey);
    if (mounted) setState(() => _subscription = updated);
  }

  /// Open the paywall — tries RevenueCat's hosted paywall first, falls back
  /// to the custom PaywallScreen (e.g. in simulate mode).
  void _openPaywall({PremiumFeature? blockedFeature}) async {
    // Try the RevenueCat-hosted paywall first.
    final result = await RevenueCatService.presentPaywall();
    if (result != null) {
      // RC paywall was shown. Sync tier regardless of outcome — the user
      // may have purchased, restored, or dismissed.
      await _syncRevenueCat();
      return;
    }

    // Fallback: custom paywall (simulate mode or RC not configured).
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(
          subscription: _subscription,
          blockedFeature: blockedFeature,
          onSelectTier: (tier) async {
            final updated =
                await _subscriptionService.upgradeTo(_subscription, tier);
            if (tier != SubscriptionTier.free) {
              await _subscriptionService.resetDowngradeTracking();
            }
            if (mounted) {
              setState(() => _subscription = updated);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tier == SubscriptionTier.free
                      ? 'Continuing with Free plan'
                      : 'Upgraded to Pro — thank you!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onPurchaseComplete: (tier) async {
            final updated =
                await _subscriptionService.upgradeTo(_subscription, tier);
            await _subscriptionService.resetDowngradeTracking();
            if (mounted) {
              setState(() => _subscription = updated);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Upgraded to Pro — thank you!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onRestoreComplete: (tier) async {
            final updated = await _subscriptionService.syncFromRemoteTier(
                _subscription, tier);
            if (mounted) {
              setState(() => _subscription = updated);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tier == SubscriptionTier.free
                      ? 'No previous purchases found'
                      : 'Restored Pro subscription!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  /// Open the RevenueCat Customer Center for subscription management.
  void _openCustomerCenter() async {
    await RevenueCatService.presentCustomerCenter();
    // Sync after Customer Center closes — user may have changed subscription.
    await _syncRevenueCat();
  }

  /// Check if a feature is accessible; if not, show paywall.
  bool _gateFeature(PremiumFeature feature) {
    if (_subscription.canAccess(feature)) return true;
    _openPaywall(blockedFeature: feature);
    return false;
  }

  /// Navigate to a feature from the discovery card.
  void _navigateToFeature(String featureKey) {
    _trackFeature(featureKey);
    switch (featureKey) {
      case 'ai_coach':
        _openCoach();
        break;
      case 'meal_planner':
        _openMealPlanner();
        break;
      case 'expense_tracker':
        setState(() => _currentIndex = 1);
        break;
      case 'savings_goals':
        _openSavingsGoals();
        break;
      case 'shopping_list':
        _openShoppingList();
        break;
      case 'grocery_browser':
        _openGrocery();
        break;
      case 'export':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
        );
        break;
      case 'tax_simulator':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
        );
        break;
      default:
        setState(() => _currentIndex = 0);
    }
  }
}
