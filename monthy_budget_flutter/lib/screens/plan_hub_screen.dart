import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

class PlanHubScreen extends StatelessWidget {
  final VoidCallback onOpenGrocery;
  final VoidCallback onOpenShoppingList;
  final VoidCallback onOpenMealPlanner;
  final VoidCallback onOpenCoach;

  const PlanHubScreen({
    super.key,
    required this.onOpenGrocery,
    required this.onOpenShoppingList,
    required this.onOpenMealPlanner,
    required this.onOpenCoach,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return CalmScaffold(
      title: l10n.planTitle,
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          _HubCard(
            icon: Icons.shopping_cart_outlined,
            eyebrow: 'SUPERMERCADO', // TODO(l10n): move to ARB (Wave H)
            title: l10n.groceryTitle,
            subtitle: l10n.planGrocerySubtitle,
            onTap: onOpenGrocery,
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.shopping_basket_outlined,
            eyebrow: 'LISTA', // TODO(l10n): move to ARB (Wave H)
            title: l10n.planShoppingList,
            subtitle: l10n.planShoppingSubtitle,
            onTap: onOpenShoppingList,
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.restaurant_outlined,
            eyebrow: 'REFEIÇÕES', // TODO(l10n): move to ARB (Wave H)
            title: l10n.mealPlannerTitle,
            subtitle: l10n.planMealSubtitle,
            onTap: onOpenMealPlanner,
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.psychology_outlined,
            eyebrow: 'IA', // TODO(l10n): move to ARB (Wave H)
            title: l10n.coachTitle,
            subtitle: l10n.coachSubtitle,
            onTap: onOpenCoach,
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CalmCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentSoft(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalmEyebrow(eyebrow),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.ink50(context),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.ink50(context)),
        ],
      ),
    );
  }
}
