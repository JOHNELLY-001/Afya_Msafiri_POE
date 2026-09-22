import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mediator_client.dart';

/// Live flagged-country list from `GET /riskcountries`.
///
/// Response shape (verified live):
/// `{"riskcountries": [{"code": "KE", "name": "Kenya", ...}]}`.
/// Cached in-memory for the app session so risk assessment stays fast
/// and works briefly offline after first load.
class RiskCountriesRepository {
  RiskCountriesRepository(this._dio);
  final Dio _dio;

  List<String>? _cache;

  Future<List<String>> fetchNames({bool refresh = false}) async {
    if (_cache != null && !refresh) return _cache!;
    final response = await _dio.get('/riskcountries');
    final body = mediatorBody(response);
    final list = body is Map
        ? body['riskcountries'] as List? ??
            body['data'] as List? ??
            []
        : [];
    final names = <String>[];
    for (final item in list) {
      final name = item is Map ? item['name']?.toString() : null;
      if (name != null && name.isNotEmpty && !names.contains(name)) {
        names.add(name);
      }
    }
    _cache = names;
    return names;
  }
}

final riskCountriesRepositoryProvider =
    Provider<RiskCountriesRepository>((ref) {
  return RiskCountriesRepository(ref.watch(mediatorClientProvider));
});

final riskCountryNamesProvider = FutureProvider<List<String>>((ref) async {
  try {
    return await ref.watch(riskCountriesRepositoryProvider).fetchNames();
  } catch (_) {
    // Offline fallback mirrors the last known server configuration.
    return const [
      'Kenya',
      'Central African Republic',
      'Liberia',
      'Gabon',
      'Congo (Democratic Republic of the)',
      'Uganda',
      'Nigeria',
      'Congo',
      'South Africa',
      'Ghana',
      "Cote d'Ivoire",
      'Rwanda',
      'Cameroon',
      'Guinea',
      'Morocco',
      'Burundi',
    ];
  }
});
