import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config.dart';
import '../../features/decisions/data/models/decision.dart';
import '../../features/decisions/data/repositories/api_decision_repository.dart';
import '../../features/decisions/data/repositories/mock_decision_repository.dart';
import '../../features/decisions/domain/repositories/decision_repository.dart';

final decisionRepositoryProvider = Provider<DecisionRepository>((ref) {
  if (AppConfig.useMockData) {
    return MockDecisionRepository();
  }
  return const ApiDecisionRepository();
});

class DecisionController extends AsyncNotifier<Decision?> {
  @override
  Decision? build() => null;

  Future<void> submit(Decision decision) async {
    state = const AsyncLoading();
    final repository = ref.read(decisionRepositoryProvider);
    state = await AsyncValue.guard(() => repository.submitDecision(decision));
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final decisionControllerProvider =
AsyncNotifierProvider<DecisionController, Decision?>(DecisionController.new);