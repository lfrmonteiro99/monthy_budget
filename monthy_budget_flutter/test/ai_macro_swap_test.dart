import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';

void main() {
  group('MacroSwapSuggestion', () {
    test('parses from JSON correctly', () {
      final json = {
        'dayIndex': 2,
        'currentRecipeId': 'frango_assado',
        'suggestedRecipeId': 'peixe_grelhado',
        'reason': 'More protein per serving',
      };
      final suggestion = MacroSwapSuggestion.fromJson(json);
      expect(suggestion.dayIndex, 2);
      expect(suggestion.currentRecipeId, 'frango_assado');
      expect(suggestion.suggestedRecipeId, 'peixe_grelhado');
      expect(suggestion.reason, 'More protein per serving');
    });

    test('handles missing reason gracefully', () {
      final json = {
        'dayIndex': 0,
        'currentRecipeId': 'a',
        'suggestedRecipeId': 'b',
      };
      final suggestion = MacroSwapSuggestion.fromJson(json);
      expect(suggestion.dayIndex, 0);
      expect(suggestion.currentRecipeId, 'a');
      expect(suggestion.suggestedRecipeId, 'b');
      expect(suggestion.reason, '');
    });

    test('handles null reason gracefully', () {
      final json = <String, dynamic>{
        'dayIndex': 1,
        'currentRecipeId': 'x',
        'suggestedRecipeId': 'y',
        'reason': null,
      };
      final suggestion = MacroSwapSuggestion.fromJson(json);
      expect(suggestion.reason, '');
    });

    test('parses list of suggestions from JSON array', () {
      final jsonList = [
        {
          'dayIndex': 1,
          'currentRecipeId': 'arroz_pato',
          'suggestedRecipeId': 'salmao_forno',
          'reason': 'Higher omega-3',
        },
        {
          'dayIndex': 5,
          'currentRecipeId': 'massa_bolonhesa',
          'suggestedRecipeId': 'quinoa_legumes',
          'reason': 'More fiber',
        },
      ];
      final suggestions = jsonList
          .map((e) => MacroSwapSuggestion.fromJson(e))
          .toList();
      expect(suggestions.length, 2);
      expect(suggestions[0].dayIndex, 1);
      expect(suggestions[0].suggestedRecipeId, 'salmao_forno');
      expect(suggestions[1].dayIndex, 5);
      expect(suggestions[1].reason, 'More fiber');
    });
  });
}
