# Bill Due Dates & Reminders — Implementation Plan

## Goal

Add **optional** due-day tracking to budget expense items (`ExpenseItem` in `AppSettings`) and surface upcoming bills on the Dashboard. Provide a **separate, opt-in** notification toggle so users who set a due day on an expense can receive reminders ahead of the due date. Everything is non-mandatory: the due-day field is optional, and reminders are off by default behind a Settings toggle.

### Key Principles

- `dueDay` is **nullable** — never required. Expenses without a due day behave exactly as before.
- Notifications are **opt-in** — a new toggle in `NotificationSettingsScreen` controls reminders for budget-expense due dates (separate from the existing `billReminders` toggle which covers `RecurringExpense` items).
- Only expenses that have `dueDay` filled **and** the toggle enabled get scheduled notifications.
- The Dashboard shows a "Bills Due Soon" card listing expenses due within the next 7 days (purely visual — no notification dependency).

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│  ExpenseItem  (model)                                   │
│  + dueDay: int?          ← NEW optional field (1–31)    │
├─────────────────────────────────────────────────────────┤
│  AppSettings  (serialization)                           │
│  toJson / fromJson updated to persist dueDay            │
├─────────────────────────────────────────────────────────┤
│  NotificationPreferences  (model)                       │
│  + expenseDueReminders: bool           ← NEW toggle     │
│  + expenseDueReminderDaysBefore: int   ← NEW slider     │
├─────────────────────────────────────────────────────────┤
│  NotificationService                                    │
│  + _scheduleExpenseDueReminders()      ← NEW method     │
│  refreshAllSchedules() updated with new param           │
├─────────────────────────────────────────────────────────┤
│  DashboardScreen                                        │
│  + _buildBillsDueSoonCard()            ← NEW widget     │
├─────────────────────────────────────────────────────────┤
│  LocalDashboardConfig                                   │
│  + showBillsDueSoon: bool              ← NEW toggle     │
├─────────────────────────────────────────────────────────┤
│  NotificationSettingsScreen                             │
│  + Expense due reminders section       ← NEW UI section │
├─────────────────────────────────────────────────────────┤
│  SettingsScreen                                         │
│  + Due day picker per expense          ← NEW UI field   │
├─────────────────────────────────────────────────────────┤
│  i18n  (4 ARB files)                                    │
│  + ~15 new keys                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 1. Model Changes

### 1.1 `ExpenseItem` — `lib/models/app_settings.dart`

Add an optional `dueDay` field (1–31, nullable):

```dart
class ExpenseItem {
  final String id;
  final String label;
  final double amount;
  final ExpenseCategory category;
  final bool enabled;
  final bool isFixed;
  final int? dueDay; // ← NEW — day of month (1-31), null = not set

  const ExpenseItem({
    required this.id,
    this.label = '',
    this.amount = 0,
    this.category = ExpenseCategory.outros,
    this.enabled = true,
    this.isFixed = true,
    this.dueDay, // ← NEW
  });

  ExpenseItem copyWith({
    String? id,
    String? label,
    double? amount,
    ExpenseCategory? category,
    bool? enabled,
    bool? isFixed,
    int? dueDay,          // ← NEW
    bool clearDueDay = false, // ← sentinel to allow setting null
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      label: label ?? this.label,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      isFixed: isFixed ?? this.isFixed,
      dueDay: clearDueDay ? null : (dueDay ?? this.dueDay), // ← NEW
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'amount': amount,
        'category': category.name,
        'enabled': enabled,
        'isFixed': isFixed,
        if (dueDay != null) 'dueDay': dueDay, // ← NEW — omit if null
      };

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
        id: json['id'] ?? 'expense_${DateTime.now().millisecondsSinceEpoch}',
        label: json['label'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        category: ExpenseCategory.fromJson(json['category'] ?? 'outros'),
        enabled: json['enabled'] ?? true,
        isFixed: json['isFixed'] ?? true,
        dueDay: json['dueDay'] as int?, // ← NEW — null if absent
      );
}
```

**Backwards compatibility**: Existing serialized data without `dueDay` key → `null`. No migration needed.

### 1.2 `NotificationPreferences` — `lib/models/notification_preferences.dart`

Add two new fields for expense-due-day reminders (separate from existing `billReminders` which handle `RecurringExpense`):

```dart
class NotificationPreferences {
  final bool billReminders;               // existing — for RecurringExpense
  final int billReminderDaysBefore;       // existing
  final bool expenseDueReminders;         // ← NEW — for ExpenseItem dueDay
  final int expenseDueReminderDaysBefore; // ← NEW — default 1
  final bool budgetAlerts;
  final int budgetAlertThreshold;
  final bool mealPlanReminders;
  final List<CustomReminder> customReminders;

  const NotificationPreferences({
    this.billReminders = false,
    this.billReminderDaysBefore = 1,
    this.expenseDueReminders = false,         // ← NEW, off by default
    this.expenseDueReminderDaysBefore = 1,    // ← NEW
    this.budgetAlerts = false,
    this.budgetAlertThreshold = 80,
    this.mealPlanReminders = false,
    this.customReminders = const [],
  });
  // ... update copyWith, toJsonString, fromJsonString accordingly
}
```

**Serialization keys**: `expenseDueReminders`, `expenseDueReminderDaysBefore`. Missing keys default to `false` / `1`.

### 1.3 `LocalDashboardConfig` — `lib/models/local_dashboard_config.dart`

Add visibility toggle for the new Dashboard card:

```dart
class LocalDashboardConfig {
  // ... existing fields ...
  final bool showBillsDueSoon; // ← NEW, default true

  const LocalDashboardConfig({
    // ... existing ...
    this.showBillsDueSoon = true, // ← NEW
  });
  // ... update copyWith, toJson, fromJson accordingly
}
```

---

## 2. Dashboard UI — "Bills Due Soon" Card

### 2.1 Location

Insert the card in `DashboardScreen.build()` **after** the Month Review card and **before** the Summary Cards. This gives it high visibility since upcoming bills are time-sensitive.

```dart
// In DashboardScreen build(), inside the hasData section:
if (dashboardConfig.showBillsDueSoon) ...[
  _buildBillsDueSoonCard(context, l10n),
  const SizedBox(height: 16),
],
```

### 2.2 Data Logic

Create a helper that filters and sorts upcoming bills:

```dart
/// Returns expenses with dueDay set, due within the next [windowDays] days.
/// Each entry is a tuple of (ExpenseItem, daysUntilDue).
List<(ExpenseItem, int)> _getUpcomingBills(List<ExpenseItem> expenses, {int windowDays = 7}) {
  final now = DateTime.now();
  final results = <(ExpenseItem, int)>[];

  for (final expense in expenses) {
    if (!expense.enabled || expense.dueDay == null) continue;

    final dueDay = expense.dueDay!.clamp(1, 28);
    var dueDate = DateTime(now.year, now.month, dueDay);

    // If already past this month, look at next month
    if (dueDate.isBefore(DateTime(now.year, now.month, now.day))) {
      dueDate = DateTime(now.year, now.month + 1, dueDay);
    }

    final daysUntil = dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (daysUntil >= 0 && daysUntil <= windowDays) {
      results.add((expense, daysUntil));
    }
  }

  results.sort((a, b) => a.$2.compareTo(b.$2));
  return results;
}
```

### 2.3 Widget Design

```dart
Widget _buildBillsDueSoonCard(BuildContext context, S l10n) {
  final upcoming = _getUpcomingBills(settings.expenses);
  if (upcoming.isEmpty) return const SizedBox.shrink();

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(context)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 16, color: AppColors.warning(context)),
            const SizedBox(width: 8),
            Text(
              l10n.billsDueSoonTitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary(context),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...upcoming.map((entry) {
          final (expense, daysUntil) = entry;
          final isToday = daysUntil == 0;
          final isTomorrow = daysUntil == 1;
          final label = isToday
              ? l10n.billDueToday
              : isTomorrow
                  ? l10n.billDueTomorrow
                  : l10n.billDueInDays(daysUntil);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Category color dot
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: _categoryColor(expense.category),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    expense.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                Text(
                  formatCurrency(expense.amount),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.errorBackground(context)
                        : AppColors.warningBackground(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? AppColors.error(context)
                          : AppColors.warning(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}
```

### 2.4 DashboardScreen Constructor

No new constructor parameters needed — the card reads from `widget.settings.expenses` which is already available.

---

## 3. Settings UI — Due Day Picker

### 3.1 Location in Settings Screen

In `lib/screens/settings_screen.dart`, inside the per-expense card (after the Fixed/Variable chips and amount field), add an optional due-day picker:

```dart
// After the isFixed toggle row and the amount TextField:
Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Row(
    children: [
      Icon(Icons.calendar_today, size: 14,
          color: AppColors.textMuted(context)),
      const SizedBox(width: 8),
      Text(l10n.expenseDueDay,
          style: TextStyle(fontSize: 12,
              color: AppColors.textSecondary(context))),
      const Spacer(),
      if (expense.dueDay != null)
        IconButton(
          icon: Icon(Icons.clear, size: 16,
              color: AppColors.textMuted(context)),
          onPressed: () => _updateExpense(
            expense.id, (e) => e.copyWith(clearDueDay: true)),
          tooltip: l10n.expenseDueDayClear,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
        ),
      const SizedBox(width: 4),
      SizedBox(
        width: 72,
        child: DropdownButtonFormField<int?>(
          value: expense.dueDay,
          decoration: InputDecoration(
            hintText: l10n.expenseDueDayHint, // "None"
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
            isDense: true,
          ),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(l10n.expenseDueDayNone,
                  style: const TextStyle(fontSize: 12)),
            ),
            ...List.generate(28, (i) => DropdownMenuItem<int?>(
              value: i + 1,
              child: Text('${i + 1}',
                  style: const TextStyle(fontSize: 12)),
            )),
          ],
          onChanged: (v) => _updateExpense(
            expense.id,
            (e) => v == null
                ? e.copyWith(clearDueDay: true)
                : e.copyWith(dueDay: v),
          ),
        ),
      ),
    ],
  ),
),
```

> **Note**: Day values are clamped to 1–28 to avoid month-length issues (same approach used in `RecurringExpense`).

---

## 4. Notification Settings UI

### 4.1 New Section in `NotificationSettingsScreen`

Add a new card section **after** the existing "Bill reminders" card and **before** the "Budget alerts" card. This keeps all bill-related settings together while being clearly separate.

```dart
// NEW section — Expense due date reminders
_buildSectionCard(
  children: [
    SwitchListTile(
      value: _prefs.expenseDueReminders,
      onChanged: (v) {
        if (v) _ensurePermission();
        _update(_prefs.copyWith(expenseDueReminders: v));
      },
      title: Text(l10n.notificationExpenseDueReminders,
          style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600)),
      subtitle: Text(
        l10n.notificationExpenseDueRemindersDesc,
        style: TextStyle(
            color: AppColors.textSecondary(context), fontSize: 13),
      ),
      activeThumbColor: AppColors.primary(context),
    ),
    if (_prefs.expenseDueReminders) ...[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            Text(l10n.notificationBillReminderDays,
                style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13)),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                value: _prefs.expenseDueReminderDaysBefore.toDouble(),
                min: 1,
                max: 7,
                divisions: 6,
                label: '${_prefs.expenseDueReminderDaysBefore}',
                activeColor: AppColors.primary(context),
                onChanged: (v) => _update(_prefs.copyWith(
                    expenseDueReminderDaysBefore: v.round())),
              ),
            ),
          ],
        ),
      ),
    ],
  ],
),
const SizedBox(height: 12),
```

### 4.2 Explanation of Two Bill Sections

| Setting | Data Source | Purpose |
|---------|-----------|---------|
| **Bill reminders** (existing) | `RecurringExpense.dayOfMonth` | Reminders for recurring expenses tracked in the Recurring Expenses screen |
| **Expense due reminders** (new) | `ExpenseItem.dueDay` | Reminders for budget line items configured in Settings |

Both are independently toggleable. A user might use one, both, or neither.

---

## 5. Notifications — Service Integration

### 5.1 `NotificationService` Changes — `lib/services/notification_service.dart`

#### New ID range

```dart
static const _expenseDueBaseId = 4000; // ← NEW range (after _customBaseId = 3000)
```

#### Updated `refreshAllSchedules` signature

```dart
Future<void> refreshAllSchedules({
  required NotificationPreferences prefs,
  required List<RecurringExpense> recurringExpenses,
  required List<ExpenseItem> budgetExpenses, // ← NEW parameter
  required double budgetUsagePercent,
  required bool hasMealPlan,
}) async {
  await cancelAll();

  // Existing: recurring expense bill reminders
  if (prefs.billReminders) {
    await _scheduleBillReminders(
      recurringExpenses: recurringExpenses,
      daysBefore: prefs.billReminderDaysBefore,
    );
  }

  // NEW: budget expense due-day reminders
  if (prefs.expenseDueReminders) {
    await _scheduleExpenseDueReminders(
      expenses: budgetExpenses,
      daysBefore: prefs.expenseDueReminderDaysBefore,
    );
  }

  // ... rest unchanged (budgetAlerts, mealPlanReminders, customReminders)
}
```

#### New `_scheduleExpenseDueReminders` method

```dart
Future<void> _scheduleExpenseDueReminders({
  required List<ExpenseItem> expenses,
  required int daysBefore,
}) async {
  final withDueDay = expenses
      .where((e) => e.enabled && e.dueDay != null)
      .toList();

  for (int i = 0; i < withDueDay.length; i++) {
    final expense = withDueDay[i];
    final now = DateTime.now();
    final dueDay = expense.dueDay!.clamp(1, 28);
    var dueDate = DateTime(now.year, now.month, dueDay);

    // If due date already passed this month, schedule for next month
    if (dueDate.isBefore(now)) {
      dueDate = DateTime(now.year, now.month + 1, dueDay);
    }

    final reminderDate = dueDate.subtract(Duration(days: daysBefore));

    if (reminderDate.isAfter(now)) {
      try {
        await _plugin.zonedSchedule(
          _expenseDueBaseId + i,
          expense.label.isNotEmpty ? expense.label : expense.category.label,
          '${expense.amount.toStringAsFixed(2)} due in $daysBefore days',
          tz.TZDateTime.from(reminderDate, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (e) {
        debugPrint('Failed to schedule expense due reminder: $e');
      }
    }
  }
}
```

### 5.2 Caller Update — `lib/main.dart`

Update the `_openNotificationSettings` callback and any other call sites that invoke `refreshAllSchedules`:

```dart
NotificationService().refreshAllSchedules(
  prefs: prefs,
  recurringExpenses: _recurringExpenses,
  budgetExpenses: _settings.expenses,  // ← NEW
  budgetUsagePercent: 0,
  hasMealPlan: true,
);
```

### 5.3 Re-schedule on Settings Save

When the user saves `AppSettings` (modifying expenses / due days), also refresh notification schedules if expense-due reminders are enabled:

```dart
void _saveSettings(AppSettings updated) {
  setState(() => _settings = updated);
  _settingsService.save(updated);

  // Refresh notifications if expense due reminders are active
  if (_notificationPrefs.expenseDueReminders) {
    NotificationService().refreshAllSchedules(
      prefs: _notificationPrefs,
      recurringExpenses: _recurringExpenses,
      budgetExpenses: updated.expenses,
      budgetUsagePercent: 0,
      hasMealPlan: true,
    );
  }
}
```

---

## 6. Internationalization (i18n)

### 6.1 New Keys

Add to all 4 ARB files (`app_en.arb`, `app_pt.arb`, `app_es.arb`, `app_fr.arb`):

| Key | English (app_en.arb) | Purpose |
|-----|---------------------|---------|
| `billsDueSoonTitle` | `"BILLS DUE SOON"` | Dashboard card header |
| `billDueToday` | `"Today"` | Badge when daysUntil == 0 |
| `billDueTomorrow` | `"Tomorrow"` | Badge when daysUntil == 1 |
| `billDueInDays` | `"In {days} days"` | Badge for 2+ days. Param: `days` (int) |
| `expenseDueDay` | `"Due day"` | Label in Settings expense card |
| `expenseDueDayHint` | `"Day"` | Dropdown hint |
| `expenseDueDayNone` | `"None"` | Dropdown option for no due day |
| `expenseDueDayClear` | `"Clear due day"` | Tooltip for clear button |
| `notificationExpenseDueReminders` | `"Expense due date reminders"` | Toggle title |
| `notificationExpenseDueRemindersDesc` | `"Get notified before budget expenses are due"` | Toggle subtitle |
| `dashboardBillsDueSoon` | `"Bills Due Soon"` | Dashboard config toggle label |
| `noBillsDueSoon` | `"No bills due in the next 7 days"` | Empty state (if card is always shown) |

### 6.2 ARB Entry Format (English example)

```json
"billsDueSoonTitle": "BILLS DUE SOON",
"billDueToday": "Today",
"billDueTomorrow": "Tomorrow",
"billDueInDays": "In {days} days",
"@billDueInDays": {
  "placeholders": {
    "days": { "type": "int" }
  }
},
"expenseDueDay": "Due day",
"expenseDueDayHint": "Day",
"expenseDueDayNone": "None",
"expenseDueDayClear": "Clear due day",
"notificationExpenseDueReminders": "Expense due date reminders",
"notificationExpenseDueRemindersDesc": "Get notified before budget expenses are due",
"dashboardBillsDueSoon": "Bills Due Soon",
"noBillsDueSoon": "No bills due in the next 7 days"
```

After adding keys, run:
```bash
flutter gen-l10n
```

---

## 7. Files Involved

### Files to Modify

| File | Change |
|------|--------|
| `lib/models/app_settings.dart` | Add `dueDay` field to `ExpenseItem` + `copyWith` sentinel + JSON |
| `lib/models/notification_preferences.dart` | Add `expenseDueReminders` + `expenseDueReminderDaysBefore` |
| `lib/models/local_dashboard_config.dart` | Add `showBillsDueSoon` toggle |
| `lib/services/notification_service.dart` | Add `_expenseDueBaseId`, `_scheduleExpenseDueReminders()`, update `refreshAllSchedules()` signature |
| `lib/services/local_config_service.dart` | No changes needed (config is already generic JSON) |
| `lib/screens/dashboard_screen.dart` | Add `_getUpcomingBills()` helper + `_buildBillsDueSoonCard()` widget |
| `lib/screens/settings_screen.dart` | Add due-day dropdown picker per expense item |
| `lib/screens/notification_settings_screen.dart` | Add expense-due reminders toggle section |
| `lib/main.dart` | Pass `budgetExpenses` to `refreshAllSchedules()`, re-schedule on settings save |
| `lib/l10n/app_en.arb` | Add ~12 new i18n keys |
| `lib/l10n/app_pt.arb` | Add ~12 new i18n keys (Portuguese translations) |
| `lib/l10n/app_es.arb` | Add ~12 new i18n keys (Spanish translations) |
| `lib/l10n/app_fr.arb` | Add ~12 new i18n keys (French translations) |

### Files to Create

None — all changes fit within existing files.

### Generated Files (auto-updated by `flutter gen-l10n`)

| File |
|------|
| `lib/l10n/generated/app_localizations.dart` |
| `lib/l10n/generated/app_localizations_en.dart` |
| `lib/l10n/generated/app_localizations_pt.dart` |
| `lib/l10n/generated/app_localizations_es.dart` |
| `lib/l10n/generated/app_localizations_fr.dart` |

---

## 8. Implementation Order

Recommended sequence to minimize broken states:

| Step | Task | Risk |
|------|------|------|
| 1 | **Model**: Add `dueDay` to `ExpenseItem` with JSON support | Low — nullable field, backwards-compatible |
| 2 | **Model**: Add `expenseDueReminders` fields to `NotificationPreferences` | Low — defaults to `false` |
| 3 | **Model**: Add `showBillsDueSoon` to `LocalDashboardConfig` | Low — defaults to `true` |
| 4 | **Settings UI**: Add due-day dropdown in `SettingsScreen` expense cards | Medium — UI change, test on various screen sizes |
| 5 | **Dashboard**: Add `_buildBillsDueSoonCard()` and helper | Medium — pure display, no side effects |
| 6 | **Notification Settings UI**: Add expense-due reminders toggle section | Low — new section in existing screen |
| 7 | **NotificationService**: Add `_scheduleExpenseDueReminders()` and update `refreshAllSchedules()` | Medium — scheduling logic, test edge cases |
| 8 | **main.dart**: Wire up the new parameter and re-schedule on settings save | Low — plumbing |
| 9 | **i18n**: Add all keys to 4 ARB files, run `flutter gen-l10n` | Low — mechanical |
| 10 | **Test**: Verify end-to-end on device | — |

---

## 9. Edge Cases & Considerations

### Due Day Clamping
Days are clamped to 1–28 (same as `RecurringExpense`) to avoid issues with months that have fewer than 31 days. The dropdown in Settings only shows values 1–28.

### Month Boundaries
The "Bills Due Soon" logic looks ahead across month boundaries. If today is March 29 and a bill is due on the 3rd, it correctly shows "due in 5 days" (April 3).

### Empty State
If no expenses have `dueDay` set, the "Bills Due Soon" card is hidden entirely (`SizedBox.shrink()`). The Dashboard config toggle `showBillsDueSoon` only takes effect when there are upcoming bills to show.

### Notification ID Collisions
The new `_expenseDueBaseId = 4000` is well-separated from existing ranges (`_billBaseId = 1000`, `_budgetAlertId = 2000`, `_mealPlanId = 2001`, `_customBaseId = 3000`). Supports up to 999 budget expenses (4000–4999).

### Notification Refresh Triggers
Notifications are refreshed when:
1. User toggles `expenseDueReminders` in Notification Settings (via `onSave` callback)
2. User modifies `dueDay` on an expense in Settings (via `_saveSettings` in main.dart)

### Backwards Compatibility
- Existing `ExpenseItem` JSON without `dueDay` → `null` (no due day)
- Existing `NotificationPreferences` JSON without new keys → `false` / `1` (reminders off)
- Existing `LocalDashboardConfig` JSON without `showBillsDueSoon` → `true` (visible by default)
- No data migration required
