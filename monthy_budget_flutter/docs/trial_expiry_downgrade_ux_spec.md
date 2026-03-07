# Trial Expiry Downgrade UX Specification

## Context

When the 14-day free trial expires, users are downgraded from full premium access to the free tier. During trial, they may have created data that exceeds free-tier limits:

- **Expense categories**: Max 8 active on free tier (user may have 10+)
- **Savings goals**: Max 1 active on free tier (user may have multiple)
- **Premium features**: AI Coach, Meal Planner, Export, Bill Reminders, Expense Trends, etc. become inaccessible

**Core principle**: Never delete user data. Deactivate excess items and make reactivation/management easy.

---

## 1. First-Time Downgrade Notification

### Format: Bottom Sheet (not dialog, not full-screen)

**Rationale**: A dialog feels too abrupt and blocking. A full-screen paywall is too aggressive for what should be an informational moment. A bottom sheet strikes the right balance: it commands attention, allows the user to see the app behind it (reassuring them nothing is gone), and can be dismissed with a swipe.

### Trigger

Show **once**, the first time the app is opened after `isTrialActive` transitions from `true` to `false` and `tier == SubscriptionTier.free`. Track with a new boolean `trialEndNoticeSeen` in `SharedPreferences`.

### Implementation: `TrialExpiredBottomSheet`

**File**: `lib/widgets/trial_expired_bottom_sheet.dart`

```
┌─────────────────────────────────────────┐
│            ─── (drag handle) ───        │
│                                         │
│   [info_outline icon]                   │
│   Your free trial has ended             │  ← 18px, w700, textPrimary
│                                         │
│   Your data is safe. We've adjusted     │  ← 13px, textSecondary
│   some limits for the free plan:        │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │ ● 8 of 12 categories active    │   │  ← warning background
│   │   7 categories paused           │   │
│   │ ● 1 of 4 savings goals active  │   │
│   │   3 savings goals paused        │   │
│   └─────────────────────────────────┘   │
│                                         │
│   Premium features like AI Coach,       │  ← 12px, textMuted
│   Meal Planner, and Export are now      │
│   available with a subscription.        │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │        Upgrade to Pro           │   │  ← Primary button (AppColors.primary)
│   └─────────────────────────────────┘   │
│   ┌─────────────────────────────────┐   │
│   │     Manage My Categories        │   │  ← Outlined/secondary button
│   └─────────────────────────────────┘   │
│        Continue with Free Plan          │  ← TextButton, textSecondary
│                                         │
└─────────────────────────────────────────┘
```

### Behavioral Details

- **DraggableScrollableSheet**: `initialChildSize: 0.55`, `minChildSize: 0.3`, `maxChildSize: 0.8`
- **Dismiss**: Swipe down or tap "Continue with Free Plan". Both mark `trialEndNoticeSeen = true`.
- **"Upgrade to Pro"**: Navigates to `PaywallScreen` (existing).
- **"Manage My Categories"**: Navigates to Settings screen with `initialSection: 'expenses'` (existing pattern), where the user can choose which 8 categories to keep active.
- **Conditional content**: Only show the affected-items box if the user actually exceeded limits. If the user had 8 or fewer categories AND 1 or fewer savings goals, simplify the message to just mention premium features becoming unavailable and skip the "Manage" button entirely.
- **Icon**: `Icons.info_outline` in `AppColors.primary(context)`, not warning/error. The tone is informational, not alarming.

### Copy Guidelines

- Use "paused" instead of "deactivated" or "disabled" -- it implies temporary and reversible.
- Emphasize "Your data is safe" immediately -- this is the user's primary anxiety.
- Avoid urgency language. No exclamation marks. No "Don't lose your data!" fear tactics.

---

## 2. Inline Indicators for Deactivated Items

### 2a. Categories List (in Settings Screen)

Categories are `ExpenseItem` objects in `AppSettings.expenses`. They already have an `enabled` field. The settings screen already renders them in an expandable section.

**Active categories** (first 8, or user-selected 8): Render as they currently do -- no changes.

**Paused categories** (beyond the limit): Render in a separate sub-group below active categories, with the following visual treatment:

```
── Active Categories (8 of 12) ─────────

  [normal expense item row]
  [normal expense item row]
  [normal expense item row]
  [normal expense item row]
  [normal expense item row]

── Paused Categories ───────────────────   ← textMuted, 11px, uppercase tracking

  ┌─────────────────────────────────────┐
  │ [lock_outline 16px]  Vodafone       │  ← textMuted color, 0.5 opacity on amount
  │                      €45.00         │
  │                         [toggle OFF]│  ← Switch widget, disabled state
  └─────────────────────────────────────┘
```

**Visual treatment for paused items**:
- Name text: `AppColors.textMuted(context)` (instead of `textPrimary`)
- Amount text: `AppColors.textMuted(context)` with `alpha: 0.5`
- Leading icon: `Icons.lock_outline` (size 16) in `AppColors.textMuted(context)`, replacing the category color dot
- A `Switch` widget in the OFF state. Tapping it triggers the "attempt to activate beyond limit" flow (see section 3).
- The entire row has reduced opacity is NOT recommended (accessibility issue). Instead, use the muted color treatment above.

**Section header**: Show a count — "Active Categories (8 of 12)" — making the limit tangible.

**No badge on the Settings nav item**. The settings icon in the bottom nav / more screen should NOT have a persistent badge. This would be too aggressive and create upgrade-spam anxiety.

### 2b. Savings Goals List

The `SavingsGoalsScreen` already renders `_GoalCard` widgets and already shows "Inactive" text for `!goal.isActive` items. Enhance this with:

**Active goal** (the 1 allowed): Renders as-is, no changes.

**Paused goals**: Rendered below active goals with visual treatment:

```
  ┌─────────────────────────────────────┐
  │ [lock_outline]  Emergency Fund      │  ← name in textMuted
  │ ████████░░░░░░░░  €500 / €2,000    │  ← progress bar in textMuted/border color
  │ 25%                                 │
  │ Paused — Free plan allows 1 goal   │  ← 11px, italic, textMuted
  │                      [PRO] badge    │  ← small chip/badge
  └─────────────────────────────────────┘
```

**Visual treatment for paused savings goals**:
- Goal name: `AppColors.textMuted(context)` instead of `textPrimary`
- Progress bar: Use `AppColors.border(context)` for the filled portion (instead of the goal color), making it visually "desaturated"
- Color dot: Replace with `Icons.lock_outline` (size 12, `AppColors.textMuted`)
- Replace the existing "Inactive" italic text with: "Paused — Free plan allows 1 goal" (more informative)
- Add a small `PRO` chip badge (8px font, `AppColors.primary` background, white text, `BorderRadius.circular(4)`) in the top-right area of the card, next to the popup menu
- Tapping the card should still open the detail view (read-only for contributions), but the "Contribute" FAB should be hidden/disabled with a tooltip "Upgrade to add contributions to paused goals"
- The popup menu "Set Active" action should trigger the limit-exceeded flow (section 3)

### 2c. Sorting Order

Both lists should sort: **active items first, then paused items**. Within each group, maintain the user's existing order (by creation date or previous sort order). This ensures the user always sees their functional data first.

---

## 3. Attempt to Activate Beyond Limit

### Trigger

User taps the toggle/switch on a paused category, or selects "Set Active" on a paused savings goal, while already at the free-tier limit (8 categories or 1 savings goal active).

### Format: Dialog (AlertDialog)

**Rationale**: This is a blocking action that needs a decision. A snackbar would be too transient and might be missed. A dialog is the right choice here because the user took an explicit action and needs to understand why it cannot be completed.

### Layout

```
┌─────────────────────────────────────────┐
│                                         │
│   Category limit reached                │  ← title, 16px, w700
│                                         │
│   The free plan allows 8 active         │  ← 14px, textSecondary
│   categories. To activate "Vodafone",   │
│   deactivate another category first,    │
│   or upgrade to Pro for unlimited       │
│   categories.                           │
│                                         │
│              ┌──────────────┐           │
│              │ Upgrade to Pro│           │  ← ElevatedButton, primary
│              └──────────────┘           │
│              ┌──────────────┐           │
│              │   Swap Active │           │  ← OutlinedButton
│              └──────────────┘           │
│                   Close                 │  ← TextButton
│                                         │
└─────────────────────────────────────────┘
```

### Actions

- **"Upgrade to Pro"**: Navigate to `PaywallScreen` with `blockedFeature: PremiumFeature.unlimitedCategories` (or `unlimitedSavingsGoals`).
- **"Swap Active"**: Dismiss the dialog and scroll to / highlight the active items list, enabling the user to deactivate one before activating another. For categories, this means opening the settings expenses section. For savings goals, this stays on the current screen.
- **"Close"**: Dismiss, no action.

### Savings Goal Variant

Same dialog structure but with copy:

> **Savings goal limit reached**
>
> The free plan allows 1 active savings goal. To activate "[Goal Name]", deactivate your current active goal first, or upgrade to Pro for unlimited goals.

The "Swap Active" button label becomes "Choose Active Goal" and it should present a simple selection bottom sheet listing all goals with radio-button-style selection (only one can be active).

---

## 4. Attempt to Create New Items Beyond Limit

### Should this differ from #3?

**Yes, slightly.** The message changes because the user is trying to *create* rather than *activate*, but the flow is nearly identical.

### For Categories (Create New Expense Item)

When the user taps "Add Expense" in settings and they already have 8 active categories:

**Format**: Same AlertDialog pattern as #3.

```
┌─────────────────────────────────────────┐
│                                         │
│   Category limit reached                │
│                                         │
│   You have 8 active categories, the     │
│   maximum for the free plan. To add a   │
│   new category, deactivate an existing  │
│   one first, or upgrade to Pro.         │
│                                         │
│              ┌──────────────┐           │
│              │ Upgrade to Pro│           │
│              └──────────────┘           │
│              ┌──────────────┐           │
│              │Manage Categories│         │
│              └──────────────┘           │
│                   Close                 │
│                                         │
└─────────────────────────────────────────┘
```

**Key difference from #3**: The user is NOT blocked from creating the item if they have fewer than 8 active but may have many total (active + paused). The limit is on *active* items, not total items. So the check is: `activeCategories.length >= 8`. If the user has 3 active and 7 paused, they CAN create a new one (it becomes active, bringing them to 4).

However, if they are at the limit of 8 active, they must either:
1. Deactivate one first, then create the new one (it will be active by default)
2. Create the new one as paused (offer this as an option): "Create as Paused" -- allowing them to save the data without it counting against the limit

Revised dialog:

```
│              ┌──────────────┐           │
│              │ Upgrade to Pro│           │  ← Primary
│              └──────────────┘           │
│              ┌──────────────┐           │
│              │Create as Paused│          │  ← Outlined -- allows creation, just paused
│              └──────────────┘           │
│                   Cancel                │  ← TextButton
```

**Rationale for "Create as Paused"**: Never block data entry. The user's intent to organize their finances should be respected even on the free tier. They can always swap later.

### For Savings Goals (Create New Goal)

Same pattern. When `activeGoals.length >= 1`:

> **Savings goal limit reached**
>
> The free plan allows 1 active savings goal. You can still create this goal — it will be saved as paused until you upgrade or deactivate your current active goal.

Buttons: "Upgrade to Pro" | "Create as Paused" | "Cancel"

### FAB Behavior

The FAB on `SavingsGoalsScreen` should NOT be hidden or disabled. Always let the user tap it. The limit dialog appears only after they fill out the form and tap save (not before). This avoids pre-emptive blocking which feels more restrictive than it needs to be.

---

## 5. Persistent Awareness

### Recommendation: Contextual only, not persistent

**No permanent badge on settings.** No persistent banner on the dashboard. These create a nagging feeling that damages user satisfaction without meaningfully driving upgrades.

### Where to show contextual awareness:

#### 5a. Dashboard Savings Card

The existing `SavingsGoalCard` widget on the dashboard should show a subtle note when paused goals exist:

```
  ┌─────────────────────────────────────┐
  │  Savings Goals                      │
  │  Emergency Fund        ████░░ 25%   │
  │                                     │
  │  +3 paused goals                    │  ← 11px, textMuted, tappable
  │                     View All →      │
  └─────────────────────────────────────┘
```

The "+3 paused goals" text is tappable and navigates to the savings goals screen. It uses `AppColors.textMuted` and does NOT use warning colors or lock icons — just a factual count.

#### 5b. Settings Expenses Section Header

When the expenses section is expanded, show the limit in the section header:

```
  Expenses  (8/8 active)                    ← "8/8" in textMuted
```

If under the limit: `(3/8 active)` -- still show it, so the user always knows the constraint exists. Only show this count on the free tier.

#### 5c. "More" / Profile Screen

If the app has a "More" or profile screen where subscription status is shown (the existing `onOpenSubscription` callback suggests this), display:

```
  ┌─────────────────────────────────────┐
  │  Free Plan                          │
  │  8 categories • 1 savings goal      │  ← textSecondary
  │  7 items paused                     │  ← textMuted, only if >0 paused
  │                    Upgrade →        │
  └─────────────────────────────────────┘
```

This is informational, not pushy. The "7 items paused" line only appears when there are actually paused items.

---

## 6. Automatic Deactivation Logic

### When Trial Expires

The deactivation should happen in the service layer, not the UI. Add a method to a new or existing service:

**File**: `lib/services/downgrade_service.dart`

```dart
class DowngradeService {
  static const maxFreeCategories = 8;
  static const maxFreeSavingsGoals = 1;

  /// Called once when trial expires. Returns true if any items were paused.
  Future<bool> applyFreeTierLimits({
    required AppSettings settings,
    required List<SavingsGoal> goals,
    required ValueChanged<AppSettings> onSaveSettings,
    required ValueChanged<List<SavingsGoal>> onSaveGoals,
    required String householdId,
  }) async {
    bool changed = false;

    // Categories: keep first N enabled ones, pause the rest
    final expenses = List<ExpenseItem>.from(settings.expenses);
    int activeCount = 0;
    for (int i = 0; i < expenses.length; i++) {
      if (expenses[i].enabled) {
        activeCount++;
        if (activeCount > maxFreeCategories) {
          expenses[i] = expenses[i].copyWith(enabled: false);
          changed = true;
        }
      }
    }
    if (changed) {
      onSaveSettings(settings.copyWith(expenses: expenses));
    }

    // Savings goals: keep first active one, pause the rest
    final activeGoals = goals.where((g) => g.isActive).toList();
    if (activeGoals.length > maxFreeSavingsGoals) {
      for (int i = maxFreeSavingsGoals; i < activeGoals.length; i++) {
        activeGoals[i] = activeGoals[i].copyWith(isActive: false);
        changed = true;
      }
      // Rebuild full list preserving already-inactive goals
      // ...save via SavingsGoalService
    }

    return changed;
  }
}
```

### Selection Priority

When auto-deactivating, keep the **first N items in their existing order**. This is deterministic and predictable. The first-time bottom sheet (section 1) then gives the user the option to "Manage My Categories" to swap if they prefer different ones active.

---

## 7. State Tracking Additions

### New fields in `SharedPreferences` (via `SubscriptionService` or a new key):

| Key | Type | Purpose |
|-----|------|---------|
| `trial_end_notice_seen` | `bool` | Tracks whether the first-time bottom sheet has been shown |
| `downgrade_applied` | `bool` | Tracks whether `applyFreeTierLimits` has run for this trial expiry |

### New computed properties on `SubscriptionState`:

```dart
/// Whether the user just transitioned from trial to free (needs downgrade handling).
bool get justDowngraded => trialUsed && tier == SubscriptionTier.free;
```

---

## 8. Edge Cases

### User upgrades then downgrades again (subscription cancellation)

The same flow applies. `downgrade_applied` should be reset when tier changes to premium, so it re-triggers on the next downgrade. The bottom sheet copy should adapt slightly:

> "Your subscription has ended" instead of "Your free trial has ended"

### User had fewer items than the limit during trial

If the user only had 3 categories and 1 savings goal, the bottom sheet should be simpler — just mention premium features becoming unavailable, skip the affected-items box, and omit the "Manage" button. Only show "Upgrade to Pro" and "Continue with Free Plan".

### User is offline when trial expires

The deactivation logic runs locally (it modifies `AppSettings` and local `SavingsGoal` state). No network required. The bottom sheet shows on next app open regardless of connectivity.

### User deletes items to get under the limit

If the user proactively deletes categories/goals to stay under the limit before trial expiry, the deactivation logic should detect this (`activeCount <= maxFreeCategories`, i.e. 8) and skip deactivation. The bottom sheet would then only mention premium features.

---

## 9. Accessibility Considerations

- All lock icons have semantic labels: `Semantics(label: 'Paused - requires Pro subscription')`
- Color is never the only indicator of paused state — text labels ("Paused") always accompany visual dimming
- Dialog buttons follow platform conventions (dismiss at bottom, primary action prominent)
- Bottom sheet is swipe-dismissable for motor accessibility
- Contrast ratios for `textMuted` on `surface` meet WCAG AA (verified against `AppColors` values)

---

## 10. Implementation Order

1. **`DowngradeService`** — deactivation logic (testable in isolation)
2. **`trial_expired_bottom_sheet.dart`** — first-time notification widget
3. **Inline indicators** — modify `_GoalCard` and settings expense rows
4. **Limit-exceeded dialogs** — reusable dialog builder for both categories and goals
5. **Contextual awareness** — dashboard card annotation, section header counts
6. **Integration** — wire into `main.dart` app startup flow, check `justDowngraded` state

---

## 11. What NOT to Build

- **No countdown timer post-expiry** ("Your trial expired 3 days ago!") — this adds anxiety without value
- **No feature-by-feature lock screen** — one bottom sheet covers everything
- **No "grace period"** — the trial is the grace period. Clean transition.
- **No data deletion prompts** — never suggest the user delete their paused items
- **No push notifications about expiry** — the in-app bottom sheet on next open is sufficient
- **No red/error colors for the downgrade notice** — use `AppColors.primary` and `textSecondary`. This is informational, not an error.
