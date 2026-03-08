import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/household_activity_event.dart';
import '../services/household_activity_service.dart';
import '../theme/app_colors.dart';

class HouseholdActivityScreen extends StatefulWidget {
  final String householdId;
  final HouseholdActivityService? service;

  const HouseholdActivityScreen({
    super.key,
    required this.householdId,
    this.service,
  });

  @override
  State<HouseholdActivityScreen> createState() =>
      _HouseholdActivityScreenState();
}

class _HouseholdActivityScreenState extends State<HouseholdActivityScreen> {
  late final HouseholdActivityService _service;
  ActivityDomain? _selectedDomain;
  List<HouseholdActivityEvent> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? HouseholdActivityService();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final events = _selectedDomain == null
          ? await _service.getRecent(widget.householdId)
          : await _service.getByDomain(
              widget.householdId, _selectedDomain!);
      if (!mounted) return;
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onFilterChanged(ActivityDomain? domain) {
    setState(() => _selectedDomain = domain);
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        surfaceTintColor: AppColors.surface(context),
        title: Text(
          l10n.householdActivityTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(context, l10n),
          Divider(height: 1, color: AppColors.surfaceVariant(context)),
          Expanded(child: _buildBody(context, l10n)),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, S l10n) {
    final labels = {
      null: l10n.householdActivityFilterAll,
      ActivityDomain.shopping: l10n.householdActivityFilterShopping,
      ActivityDomain.meals: l10n.householdActivityFilterMeals,
      ActivityDomain.expenses: l10n.householdActivityFilterExpenses,
      ActivityDomain.pantry: l10n.householdActivityFilterPantry,
      ActivityDomain.settings: l10n.householdActivityFilterSettings,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: labels.entries.map((entry) {
          final isSelected = _selectedDomain == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              key: entry.key == null
                  ? const ValueKey('filter_all')
                  : ValueKey('filter_${entry.key!.name}'),
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) => _onFilterChanged(entry.key),
              selectedColor: AppColors.primary(context).withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary(context),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary(context)
                    : AppColors.textSecondary(context),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, S l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _error!,
            style: TextStyle(color: AppColors.error(context)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history,
                  size: 56, color: AppColors.dragHandle(context)),
              const SizedBox(height: 16),
              Text(
                l10n.householdActivityEmpty,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLabel(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.householdActivityEmptyMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final grouped = _groupByRecency(_events);
    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: grouped.length,
        itemBuilder: (_, i) {
          final section = grouped[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (i > 0) const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  section.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted(context),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              ...section.events.map((e) => _buildEventTile(context, e)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, HouseholdActivityEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _domainIcon(event.domain),
            size: 20,
            color: AppColors.primary(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.readableSummary(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(event.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _domainIcon(ActivityDomain domain) {
    switch (domain) {
      case ActivityDomain.shopping:
        return Icons.shopping_basket_outlined;
      case ActivityDomain.meals:
        return Icons.restaurant_outlined;
      case ActivityDomain.expenses:
        return Icons.receipt_long_outlined;
      case ActivityDomain.pantry:
        return Icons.kitchen_outlined;
      case ActivityDomain.settings:
        return Icons.settings_outlined;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final l10n = S.of(context);
    if (diff.inMinutes < 1) return l10n.householdActivityJustNow;
    if (diff.inMinutes < 60) {
      return l10n.householdActivityMinutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return l10n.householdActivityHoursAgo(diff.inHours);
    }
    return l10n.householdActivityDaysAgo(diff.inDays);
  }

  List<_EventSection> _groupByRecency(List<HouseholdActivityEvent> events) {
    final l10n = S.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final todayEvents = <HouseholdActivityEvent>[];
    final yesterdayEvents = <HouseholdActivityEvent>[];
    final thisWeekEvents = <HouseholdActivityEvent>[];
    final olderEvents = <HouseholdActivityEvent>[];

    for (final e in events) {
      final eventDate = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      if (eventDate == today) {
        todayEvents.add(e);
      } else if (eventDate == yesterday) {
        yesterdayEvents.add(e);
      } else if (eventDate.isAfter(weekAgo)) {
        thisWeekEvents.add(e);
      } else {
        olderEvents.add(e);
      }
    }

    final sections = <_EventSection>[];
    if (todayEvents.isNotEmpty) {
      sections.add(_EventSection(l10n.householdActivityToday, todayEvents));
    }
    if (yesterdayEvents.isNotEmpty) {
      sections.add(
          _EventSection(l10n.householdActivityYesterday, yesterdayEvents));
    }
    if (thisWeekEvents.isNotEmpty) {
      sections.add(
          _EventSection(l10n.householdActivityThisWeek, thisWeekEvents));
    }
    if (olderEvents.isNotEmpty) {
      sections.add(_EventSection(l10n.householdActivityOlder, olderEvents));
    }
    return sections;
  }
}

class _EventSection {
  final String label;
  final List<HouseholdActivityEvent> events;
  const _EventSection(this.label, this.events);
}
