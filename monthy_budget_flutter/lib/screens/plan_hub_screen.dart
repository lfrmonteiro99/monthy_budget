import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        surfaceTintColor: AppColors.surface(context),
        title: Text(
          'Plan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HubCard(
            icon: Icons.shopping_cart_outlined,
            title: l10n.groceryTitle,
            subtitle: 'Browse products and prices',
            onTap: onOpenGrocery,
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.shopping_basket_outlined,
            title: 'Shopping List',
            subtitle: 'Review and finalize purchases',
            onTap: onOpenShoppingList,
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.restaurant_outlined,
            title: l10n.mealPlannerTitle,
            subtitle: 'Generate affordable weekly plans',
            onTap: onOpenMealPlanner,
          ),
          const SizedBox(height: 12),
          _HubCard(
            icon: Icons.psychology_outlined,
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
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary(context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
            ],
          ),
        ),
      ),
    );
  }
}
