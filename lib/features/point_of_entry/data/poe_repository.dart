import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/mediator_client.dart';
import '../../../shared/models/point_of_entry.dart';

/// Legitimate PoE list from `GET /poeCenters` on the backend server.
///
/// Response shape (verified live):
/// ```json
/// {"data": [{"id": "ZaDQq...", "name": "Air",
///   "portOfEntries": [{"id": "j7EZ...", "name": "Arusha Airport", ...}]}]}
/// ```
/// The `id`s are DHIS2-style org-unit UIDs (they match the QR payload's
/// `portOfEntry` field), so these are the same duty stations d2touch would
/// resolve as organisation units — fetched here through the mediator, which
/// is the only backend this app talks to. No dummy stations are used
/// anywhere: online renders live data, offline renders the last synced
/// cache, and a device that never synced shows an empty state with retry.
class PoeGroup {
  final String name;
  final List<PointOfEntry> stations;

  const PoeGroup({required this.name, required this.stations});

  Map<String, dynamic> toJson() => {
        'name': name,
        'stations': stations.map((s) => s.toJson()).toList(),
      };

  factory PoeGroup.fromJson(Map<String, dynamic> json) {
    final stations = <PointOfEntry>[];
    final raw = json['stations'] as List? ?? [];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final poe = PointOfEntry.fromJson(
          entry.map((k, v) => MapEntry(k.toString(), v)));
      if (poe.code.isEmpty || poe.name.isEmpty) continue;
      if (stations.any((p) => p.code == poe.code)) continue;
      stations.add(poe);
    }
    return PoeGroup(
      name: json['name']?.toString() ?? 'Stations',
      stations: stations,
    );
  }
}

class PoeRepository {
  PoeRepository(this._dio);
  final Dio _dio;

  /// All border-type groups with their legitimate duty stations, live from
  /// the backend. Throws on network/server errors so callers can fall back
  /// to the offline cache.
  Future<List<PoeGroup>> fetchGrouped() async {
    final response = await _dio.get('/poeCenters');
    final body = mediatorBody(response);
    final groups = body is Map ? body['data'] as List? ?? [] : [];
    final out = <PoeGroup>[];
    for (final group in groups) {
      if (group is! Map) continue;
      final groupName = group['name']?.toString() ?? 'Stations';
      final entries = group['portOfEntries'] as List? ?? [];
      final stations = <PointOfEntry>[];
      for (final entry in entries) {
        if (entry is! Map) continue;
        final id = entry['id']?.toString() ?? '';
        final name = entry['name']?.toString() ?? '';
        if (id.isEmpty || name.isEmpty) continue;
        if (stations.any((p) => p.orgUnitUid == id)) continue;
        stations.add(PointOfEntry(
            code: id, name: name, orgUnitUid: id, borderType: groupName));
      }
      stations.sort((a, b) => a.name.compareTo(b.name));
      if (stations.isNotEmpty) {
        out.add(PoeGroup(name: groupName, stations: stations));
      }
    }
    return out;
  }

  Future<List<PointOfEntry>> fetchAll() async {
    final grouped = await fetchGrouped();
    final all = grouped.expand((g) => g.stations).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return all;
  }
}

/// Offline cache of the last successfully synced legitimate stations, so
/// they stay available without network. Never contains dummy data: empty
/// when the device has never synced.
class PoeCache {
  PoeCache._();
  static const String _key = 'poe_groups_cache_v1';

  static Future<void> save(List<PoeGroup> groups) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = groups.map((g) => g.toJson()).toList();
      await prefs.setString(_key, jsonEncode(json));
    } catch (_) {
      // Cache write failure must never break the live path.
    }
  }

  static Future<List<PoeGroup>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final out = <PoeGroup>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        final group = PoeGroup.fromJson(
            entry.map((k, v) => MapEntry(k.toString(), v)));
        if (group.stations.isNotEmpty) out.add(group);
      }
      return out;
    } catch (_) {
      return [];
    }
  }
}

final poeRepositoryProvider = Provider<PoeRepository>((ref) {
  return PoeRepository(ref.watch(mediatorClientProvider));
});

/// Duty-station list for every consumer: live backend data when online,
/// last synced legitimate stations when offline. Empty (never dummy) when
/// the device has never synced.
final poeListProvider = FutureProvider<List<PointOfEntry>>((ref) async {
  final grouped = await ref.watch(poeGroupsProvider.future);
  return grouped.expand((g) => g.stations).toList();
});

/// Grouped stations (Air / Land / Lake / Sea) for the grouped picker UI.
/// Online: fetches every border-type group + duty station from the backend
/// and refreshes the offline cache. Offline / server error: returns the
/// cached legitimate stations. Never-synced device: empty list (the screen
/// renders an offline empty state with retry — no dummy stations).
final poeGroupsProvider = FutureProvider<List<PoeGroup>>((ref) async {
  try {
    final live = await ref.watch(poeRepositoryProvider).fetchGrouped();
    if (live.isNotEmpty) {
      await PoeCache.save(live);
      return live;
    }
  } catch (_) {
    // Fall through to the offline cache below.
  }
  return PoeCache.load();
});
