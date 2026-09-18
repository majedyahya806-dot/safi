import 'dart:math';
import 'rules.dart';

enum FindingStatus { open, acknowledged }

class Finding {
  final String id;
  final String ruleId;
  final String packageName;
  final String appName;
  final String version;
  final DateTime installedAt;
  final Severity severity;
  final RuleCategory category;
  final FindingStatus status;
  final String evidence;

  Finding({
    required this.id,
    required this.ruleId,
    required this.packageName,
    required this.appName,
    required this.version,
    required this.installedAt,
    required this.severity,
    required this.category,
    this.status = FindingStatus.open,
    this.evidence = '',
  });

  double get weight {
    final rule = SafiRules.byId(ruleId);
    if (rule == null) return 5;
    return rule.weight * (status == FindingStatus.acknowledged ? 0.6 : 1.0);
  }
}

class TrustScoreCalculator {
  static int calculate(List<Finding> findings) {
    if (findings.isEmpty) return 92;
    double raw = findings.fold(0.0, (sum, f) => sum + f.weight);
    double score = 100 * (1 - exp(-raw / 100));
    int trust = (100 - score).round();
    return trust.clamp(0, 100);
  }

  static String level(int score) {
    if (score >= 70) return 'آمن';
    if (score >= 40) return 'انتبه';
    return 'خطر';
  }

  static Map<String, int> counts(List<Finding> findings) {
    final open = findings.where((f) => f.status == FindingStatus.open).toList();
    return {
      'critical': open.where((f) => f.severity == Severity.critical).length,
      'high': open.where((f) => f.severity == Severity.high).length,
      'medium': open.where((f) => f.severity == Severity.medium).length,
      'unknown': open.where((f) => f.severity == Severity.unknown).length,
    };
  }
}
