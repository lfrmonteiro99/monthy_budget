# Changelog

All notable changes to this project will be documented in this file.

## v2026.6.0 - 2026-03-27

### Features

- Explicit `courseType` field on Recipe model (replaces regex-based detection) (#795)
- `isCompleteMeal` field: lunch/dinner mains must have strong protein source (#795)
- 10 new budget-friendly recipes with real protein variety (#795)
- Compact meal card layout: icon buttons, inline star rating, chip details (#808)
- Comprehensive Dart test suite: 7 generation configs, substitution, shopping list, swap, serialization (#795)
- E2E Playwright smoke tests for meal planner (#795)
- Dedicated `meal-planner-validation.yml` CI workflow (#795)

### Bug Fixes

- Fix `sodiumMg` null crash: 10 recipes missing nutrition field, made parser null-safe (#795)
- Always exclude soups/desserts from main course pool (not just multi-course mode) (#795)
- Fix meal generation diversity: relaxed repeat thresholds for constrained pools (#795)
- Replace non-existent `avgKcal` with `overallScore` on nutrition chip (#808, #809)
- Fix dessert/soup categorization false positives (#795)
- Remove unused `_setFeedback` method and duplicate UI buttons (#808)

### CI

- Make Playwright E2E smoke tests non-blocking in flutter-ci (#795)

## v2026.5.0 - 2026-03-25

### Features

- Multi-course meal support: configurable soup/starter (1st course) and dessert (3rd course) per meal (#795)
- New meal settings: "Include soup or starter" and "Include dessert" toggles in wizard and settings
- 8 new dessert recipes added to catalog (Fruta da Época, Mousse de Chocolate, Arroz Doce, etc.)
- 4 new ingredients (fruta_epoca, iogurte, chocolate, gelatina)
- Course-aware recipe swapping: swap soups with soups, desserts with desserts, mains with mains
- Ingredient substitution now shows ALL ingredients (same category first, then others)

### Bug Fixes

- Shopping list now correctly applies ingredient substitutions (was ignoring substitutions)
- Shopping list accounts for extra guests when calculating quantities
- Ingredient substitution targets correct course in multi-course meals

### Improvements

- Multi-course meal UI: compact course rows with inline swap buttons
- Expanded ingredient view shows all courses grouped with headers
- Localization: new strings for all 4 languages (PT, EN, ES, FR)
- Recipe model: added `isSoupOrStarter`, `isDessert`, `inferredCourseType` properties

## v2026.4.0 - 2026-03-16



### Bug Fixes

- Release script minor bump same-month collision (Fixes #622) ([object], [object])


### Other Changes

- Fix meal plan notifications hardcoded to true #614 (Fixes #614) ([object], [object], [object])

- Localize coach mode recommender keywords for PT/EN/ES/FR #616 (Fixes #616) ([object], [object], [object])

- Fix deep links for quick-add, meals, and assistant #615 (Fixes #615) ([object], [object], [object])

