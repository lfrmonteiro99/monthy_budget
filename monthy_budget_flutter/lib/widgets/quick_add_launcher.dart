import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../navigation/app_route.dart';
import '../theme/app_colors.dart';

/// Single-action FAB that directly triggers Add Expense.
/// Replaces the previous speed-dial with 5 options to reduce choice paralysis.
/// Other actions are now accessible directly from the navigation:
/// - Shopping List: Plan & Shop tab (1 tap)
/// - Meals: Plan & Shop tab > Meals sub-tab (2 taps)
/// - Command Chat: dedicated FAB (always visible)
/// - Scan Receipt: available from expense tracker and shopping list screens
class QuickAddLauncher extends StatelessWidget {
  final void Function(AppRoute route) onAction;

  const QuickAddLauncher({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return FloatingActionButton(
      heroTag: 'quick_add_launcher',
      onPressed: () => onAction(const AppRoute.addExpense()),
      backgroundColor: AppColors.primary(context),
      tooltip: l10n.quickAddExpense,
      child: Icon(Icons.add, color: AppColors.onPrimary(context)),
    );
  }
}
