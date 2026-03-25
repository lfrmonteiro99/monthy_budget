# Changelog

All notable changes to this project will be documented in this file.

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

