import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/roadmap_entry.dart';
import '../models/whats_new_entry.dart';
import '../services/product_updates_service.dart';
import '../theme/app_colors.dart';
import '../widgets/roadmap_lane_section.dart';
import '../widgets/whats_new_card.dart';

class ProductUpdatesScreen extends StatefulWidget {
  final void Function(String featureKey)? onFeatureNavigate;

  const ProductUpdatesScreen({super.key, this.onFeatureNavigate});

  @override
  State<ProductUpdatesScreen> createState() => _ProductUpdatesScreenState();
}

class _ProductUpdatesScreenState extends State<ProductUpdatesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _service = ProductUpdatesService();

  List<WhatsNewEntry> _whatsNew = [];
  List<RoadmapEntry> _roadmap = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final whatsNew = await _service.loadWhatsNew();
    final roadmap = await _service.loadRoadmap();
    if (!mounted) return;
    setState(() {
      _whatsNew = whatsNew;
      _roadmap = roadmap;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          l10n.productUpdatesTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary(context),
          unselectedLabelColor: AppColors.textMuted(context),
          indicatorColor: AppColors.primary(context),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: l10n.whatsNewTab),
            Tab(text: l10n.roadmapTab),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _WhatsNewTab(
                  entries: _whatsNew,
                  onFeatureNavigate: widget.onFeatureNavigate,
                ),
                _RoadmapTab(entries: _roadmap),
              ],
            ),
    );
  }
}

class _WhatsNewTab extends StatelessWidget {
  final List<WhatsNewEntry> entries;
  final void Function(String featureKey)? onFeatureNavigate;

  const _WhatsNewTab({required this.entries, this.onFeatureNavigate});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    if (entries.isEmpty) {
      return Center(
        child: Text(
          l10n.noUpdatesYet,
          style: TextStyle(color: AppColors.textMuted(context)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return WhatsNewCard(
          entry: entry,
          onFeatureTap: entry.featureKey != null && onFeatureNavigate != null
              ? () => onFeatureNavigate!(entry.featureKey!)
              : null,
        );
      },
    );
  }
}

class _RoadmapTab extends StatelessWidget {
  final List<RoadmapEntry> entries;

  const _RoadmapTab({required this.entries});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final now = entries.where((e) => e.lane == RoadmapLane.now).toList();
    final next = entries.where((e) => e.lane == RoadmapLane.next).toList();
    final later = entries.where((e) => e.lane == RoadmapLane.later).toList();

    if (entries.isEmpty) {
      return Center(
        child: Text(
          l10n.noRoadmapItems,
          style: TextStyle(color: AppColors.textMuted(context)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        RoadmapLaneSection(
          title: l10n.roadmapNow,
          icon: Icons.bolt_outlined,
          entries: now,
        ),
        RoadmapLaneSection(
          title: l10n.roadmapNext,
          icon: Icons.schedule_outlined,
          entries: next,
        ),
        RoadmapLaneSection(
          title: l10n.roadmapLater,
          icon: Icons.explore_outlined,
          entries: later,
        ),
      ],
    );
  }
}
