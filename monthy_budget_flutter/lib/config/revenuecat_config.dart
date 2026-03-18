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
/// interaction). Set to `false` once the RevenueCat project is fully
/// configured with products and offerings.
const revenueCatSimulateMode = false;
