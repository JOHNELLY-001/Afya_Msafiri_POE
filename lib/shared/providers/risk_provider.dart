import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config.dart';
import '../../features/risk_assessment/data/models/risk_assessment_result.dart';
import '../../features/risk_assessment/data/repositories/api_risk_repository.dart';
import '../../features/risk_assessment/data/repositories/mock_risk_repository.dart';
import '../../features/risk_assessment/data/repositories/risk_countries_repository.dart';
import '../../features/risk_assessment/domain/repositories/risk_repository.dart';
import 'traveller_provider.dart';

final riskRepositoryProvider = Provider<RiskRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockRiskRepository();
  }
  return ApiRiskRepository(ref.watch(riskCountriesRepositoryProvider));
});

final riskAssessmentProvider =
    FutureProvider.family<RiskAssessmentResult, String>((ref, bookingReference) async {
  final traveller = await ref.watch(travellerByReferenceProvider(bookingReference).future);
  final repository = ref.watch(riskRepositoryProvider);
  return repository.assessTraveller(traveller);
});
