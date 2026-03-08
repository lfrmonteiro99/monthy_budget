import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/roadmap_entry.dart';
import '../models/whats_new_entry.dart';

class ProductUpdatesService {
  static const _lastSeenVersionKey = 'product_updates_last_seen_version';
  static const _dismissedEntriesKey = 'product_updates_dismissed_entries';

  /// Loads What's New entries from the bundled asset.
  Future<List<WhatsNewEntry>> loadWhatsNew() async {
    final raw = await rootBundle.loadString('assets/whats_new.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => WhatsNewEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Loads roadmap entries from the bundled asset.
  Future<List<RoadmapEntry>> loadRoadmap() async {
    final raw = await rootBundle.loadString('assets/roadmap.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => RoadmapEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns the last version the user has acknowledged.
  Future<String?> getLastSeenVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSeenVersionKey);
  }

  /// Persists the version the user has now seen.
  Future<void> setLastSeenVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenVersionKey, version);
  }

  /// Returns set of entry IDs the user has dismissed.
  Future<Set<String>> getDismissedEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_dismissedEntriesKey);
    return raw?.toSet() ?? {};
  }

  /// Adds an entry ID to the dismissed set.
  Future<void> dismissEntry(String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_dismissedEntriesKey) ?? [];
    if (!current.contains(entryId)) {
      current.add(entryId);
      await prefs.setStringList(_dismissedEntriesKey, current);
    }
  }

  /// Returns true if the installed app version has unseen What's New entries.
  ///
  /// [installedVersion] is the current app version (e.g. "2026.3.5").
  /// Compares against the last version the user acknowledged.
  Future<bool> hasUnseenUpdates(String installedVersion) async {
    final lastSeen = await getLastSeenVersion();
    if (lastSeen == null) return true;
    return compareVersions(installedVersion, lastSeen) > 0;
  }

  /// Returns What's New entries that are newer than the last seen version.
  Future<List<WhatsNewEntry>> getUnseenEntries() async {
    final lastSeen = await getLastSeenVersion();
    final all = await loadWhatsNew();
    if (lastSeen == null) return all;
    return all
        .where((e) => compareVersions(e.version, lastSeen) > 0)
        .toList();
  }

  /// Compares two CalVer version strings (e.g. "2026.3.5" vs "2026.3.4").
  /// Returns positive if a > b, negative if a < b, 0 if equal.
  static int compareVersions(String a, String b) {
    final partsA = a.split('.').map(int.parse).toList();
    final partsB = b.split('.').map(int.parse).toList();
    final len = partsA.length > partsB.length ? partsA.length : partsB.length;
    for (var i = 0; i < len; i++) {
      final va = i < partsA.length ? partsA[i] : 0;
      final vb = i < partsB.length ? partsB[i] : 0;
      if (va != vb) return va - vb;
    }
    return 0;
  }
}
