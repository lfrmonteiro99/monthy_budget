import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/notification_preferences.dart';
import '../services/local_config_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final NotificationPreferences preferences;
  final ValueChanged<NotificationPreferences> onSave;

  const NotificationSettingsScreen({
    super.key,
    required this.preferences,
    required this.onSave,
  });

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.preferences;
  }

  Future<void> _ensurePermission() async {
    await NotificationService().requestPermission();
  }

  void _update(NotificationPreferences updated) {
    setState(() => _prefs = updated);
    widget.onSave(updated);
    LocalConfigService().saveNotificationPreferences(updated);
  }

  Future<void> _addCustomReminder() async {
    final result = await _showCustomReminderSheet();
    if (result == null || !mounted) return;
    _update(_prefs.copyWith(
      customReminders: [..._prefs.customReminders, result],
    ));
  }

  Future<void> _deleteCustomReminder(int index) async {
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.notificationCustomDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete,
                style: TextStyle(color: AppColors.error(context))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final updated = List<CustomReminder>.from(_prefs.customReminders)
      ..removeAt(index);
    _update(_prefs.copyWith(customReminders: updated));
  }

  Future<CustomReminder?> _showCustomReminderSheet() async {
    return showModalBottomSheet<CustomReminder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddCustomReminderSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
        backgroundColor: AppColors.surface(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Preferred notification time
          _buildSectionCard(
            children: [
              ListTile(
                leading: Icon(Icons.schedule,
                    color: AppColors.primary(context)),
                title: Text(l10n.notificationPreferredTime,
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600)),
                subtitle: Text(
                  l10n.notificationPreferredTimeDesc,
                  style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 13),
                ),
                trailing: InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: _prefs.preferredHour,
                        minute: _prefs.preferredMinute,
                      ),
                    );
                    if (picked != null) {
                      _update(_prefs.copyWith(
                        preferredHour: picked.hour,
                        preferredMinute: picked.minute,
                      ));
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.borderMuted(context)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_prefs.preferredHour.toString().padLeft(2, '0')}:${_prefs.preferredMinute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daily expense reminder
          _buildSectionCard(
            children: [
              SwitchListTile(
                value: _prefs.dailyExpenseReminder,
                onChanged: (v) {
                  if (v) _ensurePermission();
                  _update(_prefs.copyWith(dailyExpenseReminder: v));
                },
                title: Text(l10n.notifDailyExpenseReminder,
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600)),
                subtitle: Text(
                  l10n.notifDailyExpenseReminderDesc,
                  style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 13),
                ),
                activeThumbColor: AppColors.primary(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bill reminders
          _buildSectionCard(
            children: [
              SwitchListTile(
                value: _prefs.billReminders,
                onChanged: (v) {
                  if (v) _ensurePermission();
                  _update(_prefs.copyWith(billReminders: v));
                },
                title: Text(l10n.notificationBillReminders,
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${l10n.notificationBillReminderDays}: ${_prefs.billReminderDaysBefore}',
                  style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 13),
                ),
                activeThumbColor: AppColors.primary(context),
              ),
              if (_prefs.billReminders) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Text(l10n.notificationBillReminderDays,
                          style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 13)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Slider(
                          value: _prefs.billReminderDaysBefore.toDouble(),
                          min: 1,
                          max: 7,
                          divisions: 6,
                          label: '${_prefs.billReminderDaysBefore}',
                          activeColor: AppColors.primary(context),
                          onChanged: (v) => _update(_prefs.copyWith(
                              billReminderDaysBefore: v.round())),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Budget alerts
          _buildSectionCard(
            children: [
              SwitchListTile(
                value: _prefs.budgetAlerts,
                onChanged: (v) {
                  if (v) _ensurePermission();
                  _update(_prefs.copyWith(budgetAlerts: v));
                },
                title: Text(l10n.notificationBudgetAlerts,
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600)),
                subtitle: Text(
                  l10n.notificationBudgetThreshold(
                      _prefs.budgetAlertThreshold.toString()),
                  style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 13),
                ),
                activeThumbColor: AppColors.primary(context),
              ),
              if (_prefs.budgetAlerts) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Slider(
                    value: _prefs.budgetAlertThreshold.toDouble(),
                    min: 50,
                    max: 100,
                    divisions: 10,
                    label: '${_prefs.budgetAlertThreshold}%',
                    activeColor: AppColors.primary(context),
                    onChanged: (v) => _update(_prefs.copyWith(
                        budgetAlertThreshold: v.round())),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Meal plan reminder
          _buildSectionCard(
            children: [
              SwitchListTile(
                value: _prefs.mealPlanReminders,
                onChanged: (v) {
                  if (v) _ensurePermission();
                  _update(_prefs.copyWith(mealPlanReminders: v));
                },
                title: Text(l10n.notificationMealPlanReminder,
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600)),
                subtitle: Text(
                  l10n.notificationMealPlanReminderDesc,
                  style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 13),
                ),
                activeThumbColor: AppColors.primary(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom reminders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.notificationCustomReminders,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              TextButton.icon(
                onPressed: _addCustomReminder,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.notificationAddCustom),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_prefs.customReminders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.notificationEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textMuted(context), fontSize: 14),
              ),
            )
          else
            ...List.generate(_prefs.customReminders.length, (i) {
              final r = _prefs.customReminders[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight(context),
                      child: Icon(Icons.notifications_outlined,
                          color: AppColors.primary(context), size: 20),
                    ),
                    title: Text(r.title,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context))),
                    subtitle: Text(
                      '${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')} · ${_repeatLabel(r.repeat, l10n)}',
                      style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 13),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: AppColors.error(context)),
                      onPressed: () => _deleteCustomReminder(i),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(children: children),
    );
  }

  String _repeatLabel(ReminderRepeat repeat, S l10n) {
    return switch (repeat) {
      ReminderRepeat.daily => l10n.notificationCustomRepeatDaily,
      ReminderRepeat.weekly => l10n.notificationCustomRepeatWeekly,
      ReminderRepeat.monthly => l10n.notificationCustomRepeatMonthly,
      ReminderRepeat.none => l10n.notificationCustomRepeatNone,
    };
  }
}

class _AddCustomReminderSheet extends StatefulWidget {
  const _AddCustomReminderSheet();

  @override
  State<_AddCustomReminderSheet> createState() =>
      _AddCustomReminderSheetState();
}

class _AddCustomReminderSheetState extends State<_AddCustomReminderSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  ReminderRepeat _repeat = ReminderRepeat.none;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final reminder = CustomReminder(
      id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      hour: _time.hour,
      minute: _time.minute,
      repeat: _repeat,
    );
    Navigator.of(context).pop(reminder);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dragHandle(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.notificationAddCustom,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(l10n.notificationCustomTitle,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.notificationCustomTitle : null,
              ),
              const SizedBox(height: 16),

              // Body
              Text(l10n.notificationCustomBody,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Time
              Text(l10n.notificationCustomTime,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (picked != null && mounted) setState(() => _time = picked);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.borderMuted(context)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 18,
                          color: AppColors.textSecondary(context)),
                      const SizedBox(width: 8),
                      Text(
                        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary(context)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Repeat
              Text(l10n.notificationCustomRepeat,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              SegmentedButton<ReminderRepeat>(
                segments: [
                  ButtonSegment(
                      value: ReminderRepeat.none,
                      label: Text(l10n.notificationCustomRepeatNone,
                          style: const TextStyle(fontSize: 12))),
                  ButtonSegment(
                      value: ReminderRepeat.daily,
                      label: Text(l10n.notificationCustomRepeatDaily,
                          style: const TextStyle(fontSize: 12))),
                  ButtonSegment(
                      value: ReminderRepeat.weekly,
                      label: Text(l10n.notificationCustomRepeatWeekly,
                          style: const TextStyle(fontSize: 12))),
                  ButtonSegment(
                      value: ReminderRepeat.monthly,
                      label: Text(l10n.notificationCustomRepeatMonthly,
                          style: const TextStyle(fontSize: 12))),
                ],
                selected: {_repeat},
                onSelectionChanged: (v) =>
                    setState(() => _repeat = v.first),
              ),
              const SizedBox(height: 24),

              // Save
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: AppColors.onPrimary(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(l10n.save,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
