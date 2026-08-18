import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_fr.dart';

void main() {
  late SFr fr;
  setUpAll(() {
    fr = SFr();
  });

  group('app_fr.arb accent fix — Expense Tracker screen (#1229)', () {
    // Bytes that only ever appear when a UTF-8 string got mis-decoded as
    // Latin-1/Windows-1252 and re-encoded — protects against reintroducing
    // mojibake while fixing the missing accents (see #1232).
    final mojibakePattern = RegExp(r'(Ã.|â€.|ââ€)');

    test('expenseTrackerMovementEyebrow shows Activité not Activite', () {
      expect(fr.expenseTrackerMovementEyebrow, 'Activité');
      expect(fr.expenseTrackerMovementEyebrow, isNot(contains('Activite')));
      expect(fr.expenseTrackerMovementEyebrow, isNot(matches(mojibakePattern)));
    });

    test('expenseTrackerExpensesTitle shows Dépenses not Depenses', () {
      expect(fr.expenseTrackerExpensesTitle, 'Dépenses');
      expect(fr.expenseTrackerExpensesTitle, isNot(matches(mojibakePattern)));
    });

    test('expenseTrackerByCategoryEyebrow shows Par Catégorie not Par Categorie', () {
      expect(fr.expenseTrackerByCategoryEyebrow, 'Par Catégorie');
      expect(fr.expenseTrackerByCategoryEyebrow, isNot(matches(mojibakePattern)));
    });

    test('expenseTrackerEmptyBody shows première/dépense/à accented', () {
      expect(
        fr.expenseTrackerEmptyBody,
        'Ajoutez votre première dépense pour commencer à suivre votre budget.',
      );
      expect(fr.expenseTrackerEmptyBody, isNot(matches(mojibakePattern)));
    });

    test('expenseAlertsBudgetSubtitle contains Dépense not Depense, placeholders substituted', () {
      final result = fr.expenseAlertsBudgetSubtitle('520,00 €', '585,60 €');
      expect(result, 'Budget 520,00 € · Dépense 585,60 €');
      expect(result, contains('Dépense'));
      expect(result, isNot(contains('Depense')));
      expect(result, isNot(contains('{budgeted}')));
      expect(result, isNot(contains('{actual}')));
      expect(result, isNot(matches(mojibakePattern)));
    });

    test('expenseRecentEyebrow shows Récents not Recents', () {
      expect(fr.expenseRecentEyebrow, 'Récents');
      expect(fr.expenseRecentEyebrow, isNot(matches(mojibakePattern)));
    });

    test('expenseRecentViewAll shows dépenses accented', () {
      expect(fr.expenseRecentViewAll, 'Voir toutes les dépenses');
      expect(fr.expenseRecentViewAll, isNot(matches(mojibakePattern)));
    });

    test('expenseSearchResultsEyebrow shows Résultats not Resultats', () {
      expect(fr.expenseSearchResultsEyebrow, 'Résultats');
      expect(fr.expenseSearchResultsEyebrow, isNot(matches(mojibakePattern)));
    });

    test('recurringEmptyTitle shows récurrent not recurrent', () {
      expect(fr.recurringEmptyTitle, 'Aucun paiement récurrent');
      expect(fr.recurringEmptyTitle, isNot(matches(mojibakePattern)));
    });

    test('recurringEmptyBody shows générer accented', () {
      expect(
        fr.recurringEmptyBody,
        'Ajoutes-en un pour le générer automatiquement chaque mois.',
      );
      expect(fr.recurringEmptyBody, contains('générer'));
      expect(fr.recurringEmptyBody, isNot(matches(mojibakePattern)));
    });

    test('recurringEyebrow shows RÉCURRENTS uppercase-accented not RECURRENTS', () {
      expect(fr.recurringEyebrow, 'RÉCURRENTS');
      expect(fr.recurringEyebrow, isNot(matches(mojibakePattern)));
    });
  });
}
