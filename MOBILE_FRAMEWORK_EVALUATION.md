# Flutter vs Kotlin Multiplatform: Mobile Framework Evaluation

## Project Context

**App:** Monthly Budget Calculator (Orcamento Mensal)
**Current Stack:** React 19 + TypeScript + Vite 7 + Tailwind CSS 4 + Tauri v2 + Chart.js
**Target:** Native mobile app for Android and iOS

### Current App Features

| Feature | Complexity |
|---------|-----------|
| Portuguese IRS 2026 tax retention tables (3 tables, 12 brackets each) | Medium |
| Social Security (11%) deduction | Low |
| Meal allowance calculation (card vs cash, tax exemptions) | Medium |
| Dual salary support with per-salary settings | Medium |
| Expense tracking with 10 categories | Low |
| Dashboard with 5 chart types (Pie, Bar, Doughnut) | Medium |
| Configurable dashboard (toggle cards/charts) | Low |
| Settings persistence (localStorage / Tauri file backend) | Low |
| PWA support | Already exists |

### Code Metrics

- ~1,200 lines of TypeScript across 8 source files
- Pure calculation logic (~230 lines) with no external API calls
- All data stored locally (no backend server)
- UI is mobile-first with Tailwind responsive classes
- Portuguese locale throughout

---

## Framework Comparison

### 1. Flutter

**Language:** Dart
**Rendering:** Custom Skia/Impeller engine (draws every pixel)
**Release:** Stable since Dec 2018, currently Flutter 3.x

#### Strengths for This Project

- **Charting ecosystem:** `fl_chart` is a mature, highly customizable charting library with Pie, Bar, and Doughnut charts that match the current Chart.js usage. The API is declarative and Flutter-native.
- **Single codebase for Android + iOS:** One Dart codebase produces both platform binaries with identical visual output.
- **Hot reload:** Sub-second UI iteration during development.
- **Widget-based architecture:** Maps well to the current React component structure (Dashboard, Settings, Charts are natural Flutter widgets).
- **Local persistence:** `shared_preferences` for simple key-value or `hive`/`isar` for structured local storage. Both are mature and well-documented.
- **State management:** The current `useState`/`useMemo` pattern translates naturally to Flutter's `StatefulWidget` + `Provider` or `Riverpod`.
- **Web target:** Flutter can also compile to web, providing a path to replace the current React frontend entirely if desired.
- **Material Design 3:** Built-in components that work well for form-heavy UIs like the Settings screen.

#### Weaknesses for This Project

- **Dart language:** The team must learn Dart. While similar to TypeScript/Java, it is a distinct language with its own ecosystem.
- **App size:** Flutter apps have a minimum binary size of ~15-20 MB due to the bundled rendering engine. This is larger than Kotlin native apps.
- **Platform integration:** If future features require deep OS integration (widgets, notifications, background tasks), Flutter requires platform channels with native Kotlin/Swift code.
- **No TypeScript reuse:** The existing calculation logic (~230 lines) cannot be directly reused and must be rewritten in Dart.

#### Estimated Rewrite Scope

| Component | Effort |
|-----------|--------|
| Data models (`types/index.ts`) | Low — Dart classes mirror TS interfaces |
| IRS tables (`irsTables.ts`) | Low — Direct port of constants and lookup logic |
| Calculation logic (`calculations.ts`) | Low — Arithmetic translates 1:1 |
| Settings screen | Medium — Form inputs, accordion sections, state management |
| Dashboard screen | Medium — Layout, summary cards, salary breakdown |
| Charts (5 types) | Medium — `fl_chart` API differs from Chart.js but covers all chart types |
| Persistence layer | Low — `shared_preferences` or `hive` |
| Navigation | Low — Two screens with simple push/pop |

### 2. Kotlin Multiplatform (KMP)

**Language:** Kotlin (shared logic) + Jetpack Compose (Android UI) + SwiftUI (iOS UI)
**Architecture:** Shared business logic in Kotlin, platform-native UI layers
**Release:** Stable for production since Nov 2023

#### Strengths for This Project

- **Native UI per platform:** Jetpack Compose on Android and SwiftUI on iOS provide platform-idiomatic user experiences. Settings screens, form inputs, and navigation follow each platform's conventions.
- **Kotlin is the Android standard:** No additional language to learn for Android developers. Kotlin syntax is also similar to TypeScript.
- **Smaller binary size:** KMP apps produce native binaries without a bundled rendering engine, resulting in smaller app sizes (~5-10 MB).
- **Shared business logic:** The calculation engine (IRS tables, salary calculations, meal allowance) can be written once in Kotlin and shared across Android and iOS. This is the strongest argument for KMP given that calculations are the core domain logic.
- **Platform integration:** Native access to Android/iOS APIs without bridges. Future features like home screen widgets, notifications, or Siri/Google Assistant integration are straightforward.
- **Gradle ecosystem:** Access to the full JVM/Android library ecosystem.

#### Weaknesses for This Project

- **Two UI codebases:** The Settings and Dashboard UI must be written separately in Jetpack Compose (Android) and SwiftUI (iOS). This doubles the UI work.
- **Charting libraries:** The charting ecosystem is split:
  - Android: `Vico`, `MPAndroidChart`, or `YCharts` (Compose-native)
  - iOS: `Charts` (Swift) or `SwiftUI Charts` (iOS 16+)
  - These are different libraries with different APIs, requiring separate chart implementations per platform.
- **iOS development requirements:** Building for iOS requires a Mac with Xcode. The SwiftUI layer needs someone comfortable with Swift.
- **Compose Multiplatform (alternative):** JetBrains offers Compose Multiplatform which shares UI across platforms using Compose, but it is less mature than Flutter for iOS and has a smaller ecosystem.
- **No TypeScript reuse:** Same as Flutter — existing code must be rewritten, though Kotlin syntax is closer to TypeScript than Dart.

#### Estimated Rewrite Scope

| Component | Effort |
|-----------|--------|
| Data models | Low — Kotlin data classes |
| IRS tables + calculations (shared KMP module) | Low — Direct port |
| Android UI (Jetpack Compose) | Medium-High — Full UI implementation |
| iOS UI (SwiftUI) | Medium-High — Full UI implementation |
| Android charts | Medium — Vico or YCharts for Compose |
| iOS charts | Medium — SwiftUI Charts or Swift Charts library |
| Persistence (shared) | Low — KMP `Settings` library or `DataStore` |
| Navigation | Low per platform |

---

## Head-to-Head Comparison

| Criterion | Flutter | KMP | Winner |
|-----------|---------|-----|--------|
| **Code sharing (UI)** | Single UI codebase for both platforms | Separate UI per platform (or Compose Multiplatform, less mature) | Flutter |
| **Code sharing (logic)** | All shared in Dart | Business logic shared in Kotlin; UI separate | Flutter (more sharing) |
| **Charting support** | `fl_chart` covers all 5 chart types with one API | Different chart libraries per platform | Flutter |
| **Native look & feel** | Custom rendering; can mimic but not truly native | Truly native UI per platform | KMP |
| **App binary size** | ~15-20 MB minimum | ~5-10 MB | KMP |
| **Development speed** | Faster (one UI codebase + hot reload) | Slower (two UI codebases) | Flutter |
| **Learning curve** | Learn Dart + Flutter widgets | Kotlin (familiar) + SwiftUI (for iOS) | KMP (if team knows Kotlin) |
| **Platform integration** | Platform channels needed for deep OS features | Direct native API access | KMP |
| **Ecosystem maturity** | Very mature, large community, extensive packages | Rapidly maturing, growing community | Flutter |
| **Long-term maintainability** | One codebase to maintain | Shared logic + two UI codebases | Flutter |
| **Testing** | Widget tests + unit tests in Dart | Shared logic tests in Kotlin + platform UI tests | Tie |
| **CI/CD** | Single pipeline builds both platforms | Needs Mac for iOS builds regardless | Tie |
| **Web target** | Flutter compiles to web (could replace React app) | No web target for UI (Compose Multiplatform has experimental web) | Flutter |
| **Performance** | Excellent (Impeller engine, 60/120fps) | Excellent (native compilation) | Tie |
| **PWA alternative** | Can produce a web app too | Cannot | Flutter |

---

## Recommendation

### Flutter is the recommended choice for this project.

**Rationale:**

1. **This is a UI-heavy app with simple logic.** The calculation engine is ~230 lines of straightforward arithmetic. The real complexity is in the UI: forms, charts, dashboard layout, and settings. Flutter's single-UI-codebase approach means writing this UI once instead of twice.

2. **Charts are a core feature.** Five chart types with tooltips, custom colors, and responsive sizing are central to the dashboard. `fl_chart` provides all of these with a single, well-documented API. With KMP, you would need to implement charts separately for Android and iOS using different libraries.

3. **No backend or deep platform integration.** The app is entirely offline with local persistence. There are no push notifications, background tasks, home screen widgets, or platform-specific features that would favor KMP's native access. If these were needed, KMP's advantage would be more significant.

4. **Development velocity.** A single developer can build, test, and ship for both platforms from one codebase. Hot reload accelerates UI iteration. This matters for a budget calculator that may evolve with annual IRS table updates.

5. **Web consolidation opportunity.** Flutter's web target means the existing React + Vite app could eventually be replaced by the Flutter app compiled to web, unifying all three platforms (Android, iOS, web) under one codebase. This is not possible with KMP.

6. **Component mapping is natural.** The current React component structure (App -> Dashboard/Settings, with Charts as a child) maps directly to Flutter's widget tree. State management patterns (`useState` -> `StatefulWidget`/`Provider`) are conceptually identical.

### When to choose KMP instead

KMP would be the better choice if:
- The app required deep platform integration (home screen widgets, background sync, Siri shortcuts)
- Native platform appearance was a hard requirement (truly native iOS feel with SwiftUI)
- The team already had strong Kotlin + Swift expertise and no Dart experience
- The app were part of a larger native app ecosystem
- Binary size was a critical constraint (e.g., emerging markets with storage-limited devices)

---

## Migration Path (Flutter)

### Phase 1: Core Logic
1. Port data models (`types/index.ts` -> Dart classes)
2. Port IRS tables and constants
3. Port calculation functions with unit tests
4. Port meal allowance logic with unit tests

### Phase 2: Persistence & State
1. Implement local storage with `shared_preferences` or `hive`
2. Set up state management (Provider or Riverpod)
3. Implement settings migration logic

### Phase 3: UI - Settings
1. Build accordion-style settings sections
2. Implement personal info form (marital status, dependents)
3. Implement salary configuration (dual salary, meal allowance toggles)
4. Implement expense list (add/remove/toggle)
5. Implement dashboard configuration toggles

### Phase 4: UI - Dashboard
1. Build header with monthly liquidity display
2. Build summary cards grid
3. Build salary breakdown cards
4. Build expense breakdown list

### Phase 5: Charts
1. Expenses pie chart (`fl_chart` PieChart)
2. Income vs expenses bar chart
3. Deductions doughnut chart
4. Net income comparison bar chart
5. Savings rate gauge/doughnut

### Phase 6: Polish & Release
1. App icon and splash screen
2. Dark mode support (optional)
3. Localization setup (Portuguese)
4. Android and iOS store listings
5. Remove Tauri dependency if Flutter web replaces the current frontend

---

## Appendix: Key Flutter Packages

| Purpose | Package | Notes |
|---------|---------|-------|
| Charts | `fl_chart` | Pie, Bar, Line, Radar, Scatter |
| State management | `riverpod` or `provider` | Closest to React hooks pattern |
| Local storage | `shared_preferences` | Simple key-value (like localStorage) |
| Local storage (structured) | `hive` or `isar` | If more complex data storage is needed |
| Icons | `lucide_icons` | Same icon set currently used |
| Navigation | `go_router` | Declarative routing (overkill for 2 screens; built-in Navigator suffices) |
| Number formatting | `intl` | Locale-aware currency/percentage formatting |
