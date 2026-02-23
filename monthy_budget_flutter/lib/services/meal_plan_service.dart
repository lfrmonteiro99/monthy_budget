import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_plan.dart';

const _planKey = 'meal_plan';
const _shoppingListKey = 'shopping_lists';

class MealPlanService {
  Future<MealPlan?> loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_planKey);
    if (raw == null) return null;
    try {
      return MealPlan.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePlan(MealPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_planKey, plan.toJsonString());
  }

  Future<void> deletePlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_planKey);
  }

  Future<Map<int, ShoppingList>> loadShoppingLists() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_shoppingListKey);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((key, value) =>
          MapEntry(int.parse(key), ShoppingList.fromJsonString(jsonEncode(value))));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveShoppingLists(Map<int, ShoppingList> lists) async {
    final prefs = await SharedPreferences.getInstance();
    final map = lists.map((key, value) =>
        MapEntry(key.toString(), jsonDecode(value.toJsonString())));
    await prefs.setString(_shoppingListKey, jsonEncode(map));
  }

  Future<void> saveShoppingList(int semana, ShoppingList list) async {
    final all = await loadShoppingLists();
    all[semana] = list;
    await saveShoppingLists(all);
  }
}
