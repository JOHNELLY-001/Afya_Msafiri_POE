import '../../../traveller/data/models/traveller.dart';
import '../../data/models/risk_assessment_result.dart';

abstract class RiskRepository {
  Future<RiskAssessmentResult> assessTraveller(Traveller traveller);
}