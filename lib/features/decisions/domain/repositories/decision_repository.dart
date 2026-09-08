import '../../data/models/decision.dart';

abstract class DecisionRepository {
  Future<Decision> submitDecision(Decision decision);
}