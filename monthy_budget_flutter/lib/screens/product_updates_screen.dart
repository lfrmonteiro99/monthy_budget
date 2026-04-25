import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

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
    return CalmScaffold(
      title: l10n.productUpdatesTitle,
      body: Column(
        children: [
          TabBar(
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
          Expanded(
            child: _loading
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
          ),
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
        child: CalmEmptyState(
          icon: Icons.inbox_outlined,
          title: l10n.noUpdatesYet,
          body: '',
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
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
        child: CalmEmptyState(
          icon: Icons.explore_outlined,
          title: l10n.noRoadmapItems,
          body: '',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
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
