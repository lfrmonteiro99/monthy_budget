# Generated Serialization Migration

Issue: `#638`

This tranche adopts `json_serializable` as the incremental migration path away
from handwritten JSON serialization. Generated `*.g.dart` files are committed so
CI does not need to run `build_runner` for every branch.

## Migrated in this PR

- `lib/models/notification_preferences.dart`
- `lib/models/onboarding_state.dart`
- `lib/models/purchase_record.dart`
- `lib/models/coach_insight.dart`
- `lib/models/expense_snapshot.dart`
- `lib/models/product.dart`
- `lib/models/pantry_item.dart`
- `lib/models/roadmap_entry.dart`
- `lib/models/whats_new_entry.dart`
- `lib/models/command_action.dart`
- `lib/models/planning_export_envelope.dart`
- `lib/models/data_health_status.dart`
- `lib/models/monthly_budget.dart`
- `lib/models/recurring_expense.dart`
- `lib/models/local_dashboard_config.dart`

## Remaining manual serialization candidates

- `lib/models/app_settings.dart`
- `lib/models/grocery_data.dart`
- `lib/models/meal_planner.dart`
- `lib/models/meal_settings.dart`
- `lib/models/shopping_item.dart`
- `lib/models/subscription_state.dart`

## Migration notes

- Preserve existing `toJsonString()` and `fromJsonString()` APIs as thin wrappers
  where external callers already depend on them.
- Keep compatibility helpers for legacy wire formats, enum fallbacks, and field
  defaults before delegating to generated serializers.
- Prefer small follow-up PRs that migrate a coherent cluster of models and
  commit the generated `*.g.dart` outputs together with the source model.
