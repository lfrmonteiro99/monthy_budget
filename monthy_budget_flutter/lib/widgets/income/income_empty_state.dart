import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// First-run empty state for the Income screen.
///
/// Shown when the user has no salaries configured and no extra income
/// sources. Spec mandates: short copy + single CTA, no fake numbers.
class IncomeEmptyState extends StatelessWidget {
  const IncomeEmptyState({
    super.key,
    required this.onAddSource,
  });

  final VoidCallback onAddSource;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.bgSunk(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 28,
                  color: AppColors.ink50(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.incomeEmptyTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  letterSpacing: -0.4,
                  color: AppColors.ink(context),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.incomeEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.ink70(context),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAddSource,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink(context),
                  foregroundColor: AppColors.inkInverse(context),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: Text(l10n.incomeEmptyCta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
