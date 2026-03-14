/// Shared test fixtures and factory helpers.
///
/// All helpers produce deterministic data so tests stay reproducible.
library;

import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/budget_summary.dart';
import 'package:monthly_management/models/expense_snapshot.dart';
import 'package:monthly_management/models/purchase_record.dart';
import 'package:monthly_management/models/recurring_expense.dart';
import 'package:monthly_management/models/savings_goal.dart';
import 'package:monthly_management/data/tax/tax_system.dart';

// ─── App Settings Factories ────────────────────────────────

PersonalInfo makePersonalInfo({
  MaritalStatus maritalStatus = MaritalStatus.solteiro,
  int dependentes = 0,
  bool deficiente = false,
}) =>
    PersonalInfo(
      maritalStatus: maritalStatus,
      dependentes: dependentes,
      deficiente: deficiente,
    );

SalaryInfo makeSalary({
  String label = 'Salary 1',
  double grossAmount = 1500,
  bool enabled = true,
  int titulares = 1,
  MealAllowanceType mealAllowanceType = MealAllowanceType.none,
  double mealAllowancePerDay = 0,
  int workingDaysPerMonth = 22,
  SubsidyMode subsidyMode = SubsidyMode.none,
  double otherExemptIncome = 0,
}) =>
    SalaryInfo(
      label: label,
      grossAmount: grossAmount,
      enabled: enabled,
      titulares: titulares,
      mealAllowanceType: mealAllowanceType,
      mealAllowancePerDay: mealAllowancePerDay,
      workingDaysPerMonth: workingDaysPerMonth,
      subsidyMode: subsidyMode,
      otherExemptIncome: otherExemptIncome,
    );

ExpenseItem makeExpense({
  String id = 'exp_1',
  String label = 'Rent',
  double amount = 500,
  String category = 'habitacao',
  bool enabled = true,
  bool isFixed = true,
}) =>
    ExpenseItem(
      id: id,
      label: label,
      amount: amount,
      category: category,
      enabled: enabled,
      isFixed: isFixed,
    );

AppSettings makeSettings({
  PersonalInfo? personalInfo,
  List<SalaryInfo>? salaries,
  List<ExpenseItem>? expenses,
  Country country = Country.pt,
  Map<String, int> stressHistory = const {},
}) =>
    AppSettings(
      personalInfo: personalInfo ?? makePersonalInfo(),
      salaries: salaries ?? [makeSalary()],
      expenses: expenses ?? [makeExpense()],
      country: country,
      stressHistory: stressHistory,
    );

// ─── Expense Factories ─────────────────────────────────────

ActualExpense makeActualExpense({
  String id = 'ae_1',
  String category = 'habitacao',
  double amount = 450,
  DateTime? date,
  String? description,
  String? monthKey,
  String? recurringExpenseId,
  bool isFromRecurring = false,
}) {
  final d = date ?? DateTime(2026, 1, 15);
  return ActualExpense(
    id: id,
    category: category,
    amount: amount,
    date: d,
    description: description,
    monthKey: monthKey ?? '${d.year}-${d.month.toString().padLeft(2, '0')}',
    recurringExpenseId: recurringExpenseId,
    isFromRecurring: isFromRecurring,
  );
}

RecurringExpense makeRecurringExpense({
  String id = 're_1',
  String category = 'habitacao',
  double amount = 500,
  String? description,
  int? dayOfMonth = 1,
  bool isActive = true,
}) =>
    RecurringExpense(
      id: id,
      category: category,
      amount: amount,
      description: description,
      dayOfMonth: dayOfMonth,
      isActive: isActive,
    );

// ─── Savings Factories ─────────────────────────────────────

SavingsGoal makeSavingsGoal({
  String id = '00000000-0000-0000-0000-000000000001',
  String name = 'Emergency Fund',
  double targetAmount = 5000,
  double currentAmount = 1000,
  DateTime? deadline,
  String? color,
  bool isActive = true,
}) =>
    SavingsGoal(
      id: id,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      color: color,
      isActive: isActive,
    );

SavingsContribution makeContribution({
  String id = '00000000-0000-0000-0000-000000000010',
  String goalId = '00000000-0000-0000-0000-000000000001',
  double amount = 200,
  DateTime? contributionDate,
  String? note,
}) =>
    SavingsContribution(
      id: id,
      goalId: goalId,
      amount: amount,
      contributionDate: contributionDate ?? DateTime(2026, 1, 15),
      note: note,
    );

// ─── Purchase Factories ────────────────────────────────────

PurchaseRecord makePurchaseRecord({
  String id = 'pr_1',
  DateTime? date,
  double amount = 45.0,
  int itemCount = 5,
  List<String> items = const [],
  bool isMealPurchase = false,
}) =>
    PurchaseRecord(
      id: id,
      date: date ?? DateTime(2026, 1, 10),
      amount: amount,
      itemCount: itemCount,
      items: items,
      isMealPurchase: isMealPurchase,
    );

PurchaseHistory makePurchaseHistory([List<PurchaseRecord>? records]) =>
    PurchaseHistory(records: records ?? []);

// ─── Budget Summary Factories ──────────────────────────────

BudgetSummary makeBudgetSummary({
  double totalNetWithMeal = 2000,
  double totalExpenses = 1500,
  double netLiquidity = 500,
  double savingsRate = 0.25,
  double totalGross = 2200,
  double totalNet = 1900,
}) =>
    BudgetSummary(
      totalGross: totalGross,
      totalNet: totalNet,
      totalNetWithMeal: totalNetWithMeal,
      totalExpenses: totalExpenses,
      netLiquidity: netLiquidity,
      savingsRate: savingsRate,
    );

// ─── Expense Snapshot Factories ────────────────────────────

ExpenseSnapshot makeExpenseSnapshot({
  String expenseId = 'exp_1',
  String label = 'Rent',
  String category = 'habitacao',
  double amount = 500,
  bool enabled = true,
}) =>
    ExpenseSnapshot(
      expenseId: expenseId,
      label: label,
      category: category,
      amount: amount,
      enabled: enabled,
    );
