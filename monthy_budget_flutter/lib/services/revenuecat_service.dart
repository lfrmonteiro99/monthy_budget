import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../config/revenuecat_config.dart';
import '../models/subscription_state.dart';

/// Wraps the RevenueCat SDK for purchase, restore, paywall, and entitlement
/// checks.
///
/// All methods are no-ops when [revenueCatSimulateMode] is `true`, allowing
/// the app to run without a configured RevenueCat project.
class RevenueCatService {
  static bool _initialized = false;

  // ── Lifecycle ──────────────────────────────────────────────────────

  /// Configure the SDK. Call once in `main()`.
  static Future<void> initialize() async {
    if (revenueCatSimulateMode) return;
    if (_initialized) return;

    await Purchases.setLogLevel(
      revenueCatDebugLogsEnabled ? LogLevel.debug : LogLevel.info,
    );
    final config = PurchasesConfiguration(revenueCatApiKey);
    await Purchases.configure(config);
    _initialized = true;
  }

  /// Identify the user so purchases are tied to their account.
  static Future<void> login(String? userId) async {
    if (revenueCatSimulateMode || !_initialized) return;
    if (userId == null || userId.isEmpty) return;
    await Purchases.logIn(userId);
  }

  /// Reset to anonymous user (e.g. on sign-out).
  static Future<void> logout() async {
    if (revenueCatSimulateMode || !_initialized) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCat logout error: $e');
    }
  }

  // ── Entitlements → tier ────────────────────────────────────────────

  /// Read the user's current tier from RevenueCat entitlements.
  ///
  /// The single entitlement "Gestão Mensal Pro" maps to [SubscriptionTier.family]
  /// (the highest tier) so all features are unlocked when subscribed.
  static Future<SubscriptionTier> getCurrentTier() async {
    if (revenueCatSimulateMode || !_initialized) {
      return SubscriptionTier.free;
    }
    try {
      final info = await Purchases.getCustomerInfo();
      return _tierFromCustomerInfo(info);
    } catch (e) {
      debugPrint('RevenueCat getCurrentTier error: $e');
      return SubscriptionTier.free;
    }
  }

  static SubscriptionTier _tierFromCustomerInfo(CustomerInfo info) {
    if (info.entitlements.active.containsKey(revenueCatEntitlementId)) {
      // Single entitlement unlocks everything → map to highest tier.
      return SubscriptionTier.family;
    }
    return SubscriptionTier.free;
  }

  // ── Offerings ──────────────────────────────────────────────────────

  /// Fetch available offerings (packages with real store prices).
  /// Returns `null` in simulate mode or on error.
  static Future<Offerings?> getOfferings() async {
    if (revenueCatSimulateMode || !_initialized) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCat getOfferings error: $e');
      return null;
    }
  }

  // ── RevenueCat Paywall ─────────────────────────────────────────────

  /// Present the RevenueCat-hosted paywall.
  ///
  /// Uses [RevenueCatUI.presentPaywallIfNeeded] which only shows the paywall
  /// if the user doesn't already have the entitlement.
  ///
  /// Returns the [PaywallResult] indicating what happened, or `null` if in
  /// simulate mode or not initialized.
  static Future<PaywallResult?> presentPaywall() async {
    if (revenueCatSimulateMode || !_initialized) return null;
    try {
      return await RevenueCatUI.presentPaywallIfNeeded(
        revenueCatEntitlementId,
      );
    } catch (e) {
      debugPrint('RevenueCat presentPaywall error: $e');
      return null;
    }
  }

  // ── Customer Center ────────────────────────────────────────────────

  /// Present the RevenueCat Customer Center for subscription management.
  ///
  /// Allows users to manage, cancel, or change their subscription without
  /// custom UI. No-op in simulate mode.
  static Future<void> presentCustomerCenter() async {
    if (revenueCatSimulateMode || !_initialized) {
      debugPrint('Customer Center not available in simulate mode');
      return;
    }
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('RevenueCat presentCustomerCenter error: $e');
    }
  }

  // ── Purchase & Restore ─────────────────────────────────────────────

  /// Execute a purchase and return the resulting tier.
  ///
  /// Throws [PlatformException] on cancellation or error — callers should
  /// catch and handle `userCancelledError` separately.
  static Future<SubscriptionTier> purchase(Package package) async {
    final customerInfo = await Purchases.purchasePackage(package);
    return _tierFromCustomerInfo(customerInfo);
  }

  /// Restore previous purchases and return the resulting tier.
  static Future<SubscriptionTier> restorePurchases() async {
    if (revenueCatSimulateMode || !_initialized) {
      return SubscriptionTier.free;
    }
    try {
      final info = await Purchases.restorePurchases();
      return _tierFromCustomerInfo(info);
    } catch (e) {
      debugPrint('RevenueCat restorePurchases error: $e');
      return SubscriptionTier.free;
    }
  }
}
