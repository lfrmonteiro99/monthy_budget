import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/meal_planner.dart';
import 'package:orcamento_mensal/models/app_settings.dart';
import 'package:orcamento_mensal/services/meal_planner_service.dart';

void main() {
  final service = MealPlannerService();

  final testIngredients = [
    Ingredient(
      id: 'frango',
      name: 'Frango',
      category: IngredientCategory.proteina,
      unit: 'kg',
      avgPricePerUnit: 3.50,
      minPurchaseQty: 1.0,
    ),
    Ingredient(
      id: 'batata',
      name: 'Batata',
      category: IngredientCategory.vegetal,
      unit: 'kg',
      avgPricePerUnit: 0.60,
      minPurchaseQty: 1.5,
    ),
  ];

  final testRecipes = [
    Recipe(
      id: 'frango_assado',
      name: 'Frango Assado',
      proteinId: 'frango',
      type: RecipeType.carne,
      complexity: 1,
      prepMinutes: 15,
      servings: 4,
      ingredients: [
        RecipeIngredient(ingredientId: 'frango', quantity: 1.0),
        RecipeIngredient(ingredientId: 'batata', quantity: 0.6),
      ],
    ),
  ];

  final iMap = {for (final i in testIngredients) i.id: i};

  group('recipeCost', () {
    test('calculates base cost correctly for 4 people', () {
      final cost = service.recipeCost(testRecipes[0], 4, iMap);
      // frango: 1.0 * 3.50 = 3.50
      // batata: 0.6 * 0.60 = 0.36
      // total = 3.86
      expect(cost, closeTo(3.86, 0.01));
    });

    test('scales proportionally for more people', () {
      final cost4 = service.recipeCost(testRecipes[0], 4, iMap);
      final cost8 = service.recipeCost(testRecipes[0], 8, iMap);
      expect(cost8, closeTo(cost4 * 2, 0.01));
    });

    test('returns 0 for recipe with no ingredients', () {
      final empty = Recipe(
        id: 'empty',
        name: 'Empty',
        proteinId: 'frango',
        type: RecipeType.carne,
        complexity: 1,
        prepMinutes: 5,
        servings: 4,
        ingredients: [],
      );
      expect(service.recipeCost(empty, 4, iMap), 0.0);
    });
  });

  group('nPessoas', () {
    test('sums enabled salary titulares plus dependentes', () {
      final settings = AppSettings(
        salaries: const [
          SalaryInfo(label: 'S1', enabled: true, titulares: 1),
          SalaryInfo(label: 'S2', enabled: true, titulares: 1),
          SalaryInfo(label: 'S3', enabled: false, titulares: 1),
        ],
        personalInfo: const PersonalInfo(dependentes: 2),
      );
      expect(service.nPessoas(settings), 4);
    });

    test('disabled salaries do not count', () {
      final settings = AppSettings(
        salaries: const [
          SalaryInfo(label: 'S1', enabled: false, titulares: 2),
        ],
        personalInfo: const PersonalInfo(dependentes: 1),
      );
      expect(service.nPessoas(settings), 1);
    });
  });

  group('monthlyFoodBudget', () {
    test('sums only enabled alimentacao expenses', () {
      final settings = AppSettings(
        expenses: const [
          ExpenseItem(
            id: 'food',
            label: 'Comida',
            amount: 200,
            category: ExpenseCategory.alimentacao,
          ),
          ExpenseItem(
            id: 'food2',
            label: 'Extra',
            amount: 50,
            category: ExpenseCategory.alimentacao,
            enabled: false,
          ),
          ExpenseItem(
            id: 'rent',
            label: 'Renda',
            amount: 700,
            category: ExpenseCategory.habitacao,
          ),
        ],
      );
      expect(service.monthlyFoodBudget(settings), 200.0);
    });

    test('returns 0 when no alimentacao expenses exist', () {
      final settings = AppSettings(
        expenses: const [
          ExpenseItem(id: 'rent', label: 'Renda', amount: 700, category: ExpenseCategory.habitacao),
        ],
      );
      expect(service.monthlyFoodBudget(settings), 0.0);
    });
  });
}
