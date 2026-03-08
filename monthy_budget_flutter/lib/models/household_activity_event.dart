/// Domain categories for household activity events.
enum ActivityDomain { shopping, meals, expenses, pantry, settings }

/// Action types for household activity events.
enum ActivityAction { added, removed, swapped, updated, checked, unchecked }

/// A lightweight event recording a household member's action.
class HouseholdActivityEvent {
  final String id;
  final String householdId;
  final String actorUserId;
  final String actorDisplayName;
  final ActivityDomain domain;
  final ActivityAction action;
  final String subjectId;
  final String subjectLabel;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const HouseholdActivityEvent({
    required this.id,
    required this.householdId,
    required this.actorUserId,
    required this.actorDisplayName,
    required this.domain,
    required this.action,
    required this.subjectId,
    required this.subjectLabel,
    this.metadata = const {},
    required this.createdAt,
  });

  factory HouseholdActivityEvent.fromSupabase(Map<String, dynamic> row) {
    return HouseholdActivityEvent(
      id: row['id'] as String,
      householdId: row['household_id'] as String,
      actorUserId: row['actor_user_id'] as String,
      actorDisplayName: row['actor_display_name'] as String,
      domain: ActivityDomain.values.firstWhere(
        (d) => d.name == row['domain'],
        orElse: () => ActivityDomain.shopping,
      ),
      action: ActivityAction.values.firstWhere(
        (a) => a.name == row['action'],
        orElse: () => ActivityAction.added,
      ),
      subjectId: row['subject_id'] as String? ?? '',
      subjectLabel: row['subject_label'] as String? ?? '',
      metadata: row['metadata'] is Map<String, dynamic>
          ? row['metadata'] as Map<String, dynamic>
          : const {},
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() => {
        'household_id': householdId,
        'actor_user_id': actorUserId,
        'actor_display_name': actorDisplayName,
        'domain': domain.name,
        'action': action.name,
        'subject_id': subjectId,
        'subject_label': subjectLabel,
        'metadata': metadata,
      };

  /// Returns a human-readable summary, e.g. "Added Milk by Maria".
  String readableSummary() {
    final actionLabel = _actionVerb(action);
    return '$actionLabel $subjectLabel by $actorDisplayName';
  }

  /// Returns an inline attribution string, e.g. "Added by Maria".
  String inlineAttribution() {
    final actionLabel = _actionVerb(action);
    return '$actionLabel by $actorDisplayName';
  }

  static String _actionVerb(ActivityAction action) {
    switch (action) {
      case ActivityAction.added:
        return 'Added';
      case ActivityAction.removed:
        return 'Removed';
      case ActivityAction.swapped:
        return 'Swapped';
      case ActivityAction.updated:
        return 'Updated';
      case ActivityAction.checked:
        return 'Checked';
      case ActivityAction.unchecked:
        return 'Unchecked';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HouseholdActivityEvent &&
          id == other.id &&
          householdId == other.householdId;

  @override
  int get hashCode => Object.hash(id, householdId);
}
