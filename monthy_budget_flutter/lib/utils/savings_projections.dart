import '../models/savings_goal.dart';

class SavingsProjection {
  final double averageMonthlyContribution;
  final double remaining;
  final double monthsToGoal;
  final DateTime? projectedDate;
  final double? requiredMonthlyContribution;
  final bool? onTrack;
  final bool hasData;

  const SavingsProjection({
    this.averageMonthlyContribution = 0,
    this.remaining = 0,
    this.monthsToGoal = 0,
    this.projectedDate,
    this.requiredMonthlyContribution,
    this.onTrack,
    this.hasData = false,
  });
}

SavingsProjection calculateProjection({
  required SavingsGoal goal,
  required List<SavingsContribution> contributions,
  DateTime? now,
}) {
  final date = now ?? DateTime.now();
  final remaining = goal.remaining;

  if (remaining <= 0 || goal.isCompleted) {
    return SavingsProjection(
      remaining: 0,
      hasData: true,
      projectedDate: date,
    );
  }

  // Calculate average monthly contribution
  double avg = 0;
  if (contributions.isNotEmpty) {
    // Try last 3 months first
    final threeMonthsAgo = DateTime(date.year, date.month - 3, date.day);
    final recent = contributions
        .where((c) => c.contributionDate.isAfter(threeMonthsAgo))
        .toList();

    if (recent.length >= 2) {
      // Use last 3 months
      final totalRecent = recent.fold(0.0, (s, c) => s + c.amount);
      avg = totalRecent / 3;
    } else {
      // Fall back to all-time average
      final totalAll = contributions.fold(0.0, (s, c) => s + c.amount);
      final earliest = contributions
          .map((c) => c.contributionDate)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final monthsSpan = date.difference(earliest).inDays / 30.0;
      avg = monthsSpan > 0 ? totalAll / monthsSpan : totalAll;
    }
  }

  if (avg <= 0) {
    // No contribution data — can't project
    double? required;
    bool? track;
    if (goal.deadline != null) {
      final monthsLeft =
          goal.deadline!.difference(date).inDays / 30.0;
      if (monthsLeft > 0) {
        required = remaining / monthsLeft;
      }
    }
    return SavingsProjection(
      averageMonthlyContribution: 0,
      remaining: remaining,
      requiredMonthlyContribution: required,
      onTrack: track,
      hasData: false,
    );
  }

  final monthsToGoal = remaining / avg;
  final projectedDate = DateTime(
    date.year,
    date.month + monthsToGoal.ceil(),
    date.day,
  );

  // Deadline comparison
  double? required;
  bool? track;
  if (goal.deadline != null) {
    final monthsLeft = goal.deadline!.difference(date).inDays / 30.0;
    if (monthsLeft > 0) {
      required = remaining / monthsLeft;
      track = avg >= required;
    } else {
      track = false;
    }
  }

  return SavingsProjection(
    averageMonthlyContribution: avg,
    remaining: remaining,
    monthsToGoal: monthsToGoal,
    projectedDate: projectedDate,
    requiredMonthlyContribution: required,
    onTrack: track,
    hasData: true,
  );
}
