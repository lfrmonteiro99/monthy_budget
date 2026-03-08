import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/quick_action_service.dart';
import '../theme/app_colors.dart';

/// A speed-dial style launcher that exposes the four quick actions
/// from the dashboard or top-level shell.
class QuickAddLauncher extends StatefulWidget {
  final void Function(QuickAction action) onAction;

  const QuickAddLauncher({super.key, required this.onAction});

  @override
  State<QuickAddLauncher> createState() => _QuickAddLauncherState();
}

class _QuickAddLauncherState extends State<QuickAddLauncher>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _select(QuickAction action) {
    _toggle();
    widget.onAction(action);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final items = [
      _QuickItem(
        icon: Icons.receipt_long,
        label: l10n.quickAddExpense,
        action: QuickAction.addExpense,
      ),
      _QuickItem(
        icon: Icons.shopping_basket,
        label: l10n.quickAddShopping,
        action: QuickAction.addShopping,
      ),
      _QuickItem(
        icon: Icons.restaurant,
        label: l10n.quickOpenMeals,
        action: QuickAction.openMeals,
      ),
      _QuickItem(
        icon: Icons.chat,
        label: l10n.quickOpenAssistant,
        action: QuickAction.openAssistant,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open)
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _QuickActionChip(
                    icon: item.icon,
                    label: item.label,
                    onTap: () => _select(item.action),
                  ),
                );
              }).toList(),
            ),
          ),
        FloatingActionButton(
          heroTag: 'quick_add_launcher',
          onPressed: _toggle,
          backgroundColor: AppColors.primary(context),
          tooltip: l10n.quickAddTooltip,
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _open ? Icons.close : Icons.bolt,
              color: AppColors.onPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final QuickAction action;

  const _QuickItem({
    required this.icon,
    required this.label,
    required this.action,
  });
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      color: AppColors.surface(context),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary(context)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
