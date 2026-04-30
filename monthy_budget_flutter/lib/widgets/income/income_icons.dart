import 'package:flutter/material.dart';

/// Maps a category key (free-text on `IncomeSource.category`) to a Material
/// icon. Defaults to `Icons.account_balance_wallet_outlined` when unknown,
/// matching the `wallet` default on the model.
IconData incomeCategoryIcon(String key) {
  switch (key.toLowerCase()) {
    case 'home':
    case 'rent':
    case 'rendas':
      return Icons.home_outlined;
    case 'sparkle':
    case 'freelance':
    case 'gig':
      return Icons.auto_awesome_outlined;
    case 'pie':
    case 'interest':
    case 'juros':
      return Icons.pie_chart_outline;
    case 'chart':
    case 'investment':
    case 'investimento':
      return Icons.show_chart_outlined;
    case 'gift':
    case 'bonus':
      return Icons.card_giftcard_outlined;
    case 'wallet':
    case 'salary':
    case 'salario':
    default:
      return Icons.account_balance_wallet_outlined;
  }
}
