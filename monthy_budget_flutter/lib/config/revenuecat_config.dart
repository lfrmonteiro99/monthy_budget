// RevenueCat configuration.

const revenueCatApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY',
  defaultValue: '',
);

const revenueCatDebugLogsEnabled = false;

/// The single entitlement that unlocks all Pro features.
const revenueCatEntitlementId = 'Gestão Mensal Pro';

/// Product identifiers configured in RevenueCat / Google Play.
const revenueCatProductMonthly = 'monthly';
const revenueCatProductYearly = 'yearly';

/// Consumable product identifiers for AI Coach credit packs.
const revenueCatCreditProducts = ['credits_50', 'credits_150', 'credits_500'];

/// When `true`, all purchase/restore calls are simulated locally (no SDK
/// interaction). Derived from whether an API key is present so that dev/CI
/// builds without REVENUECAT_API_KEY never call the real RevenueCat SDK
/// (which would crash with InvalidCredentialsError).
const revenueCatSimulateMode = revenueCatApiKey.isEmpty;
