class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String? color;
  final bool isActive;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.color,
    this.isActive = true,
  })  : assert(targetAmount >= 0, 'targetAmount must be non-negative'),
        assert(currentAmount >= 0, 'currentAmount must be non-negative');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsGoal &&
          id == other.id &&
          name == other.name &&
          targetAmount == other.targetAmount &&
          currentAmount == other.currentAmount &&
          deadline == other.deadline &&
          color == other.color &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(
        id, name, targetAmount, currentAmount,
        deadline, color, isActive,
      );

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;

  double get remaining => (targetAmount - currentAmount).clamp(0, targetAmount);

  bool get isCompleted => currentAmount >= targetAmount;

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? color,
    bool? isActive,
    bool clearDeadline = false,
    bool clearColor = false,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      color: clearColor ? null : (color ?? this.color),
      isActive: isActive ?? this.isActive,
    );
  }

  factory SavingsGoal.fromSupabase(Map<String, dynamic> map) {
    final rawTarget = (map['target_amount'] as num).toDouble();
    final rawCurrent = (map['current_amount'] as num?)?.toDouble() ?? 0;
    return SavingsGoal(
      id: map['id'] as String,
      name: map['name'] as String,
      targetAmount: rawTarget < 0 ? 0 : rawTarget,
      currentAmount: rawCurrent < 0 ? 0 : rawCurrent,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      color: map['color'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toSupabase(String householdId) => {
        'id': id,
        'household_id': householdId,
        'name': name,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'deadline': deadline != null
            ? '${deadline!.year}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}'
            : null,
        'color': color,
        'is_active': isActive,
      };
}

class SavingsContribution {
  final String id;
  final String goalId;
  final double amount;
  final DateTime contributionDate;
  final String? note;

  SavingsContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.contributionDate,
    this.note,
  }) : assert(amount >= 0, 'amount must be non-negative');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsContribution &&
          id == other.id &&
          goalId == other.goalId &&
          amount == other.amount &&
          contributionDate == other.contributionDate &&
          note == other.note;

  @override
  int get hashCode =>
      Object.hash(id, goalId, amount, contributionDate, note);

  factory SavingsContribution.fromSupabase(Map<String, dynamic> map) {
    final rawAmount = (map['amount'] as num).toDouble();
    return SavingsContribution(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      amount: rawAmount < 0 ? 0 : rawAmount,
      contributionDate:
          DateTime.parse(map['contribution_date'] as String),
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toSupabase(String householdId) => {
        'id': id,
        'household_id': householdId,
        'goal_id': goalId,
        'amount': amount,
        'contribution_date':
            '${contributionDate.year}-${contributionDate.month.toString().padLeft(2, '0')}-${contributionDate.day.toString().padLeft(2, '0')}',
        'note': note,
      };
}
