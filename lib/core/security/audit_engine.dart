import 'dart:async';
import 'package:flutter/foundation.dart';
import '../security/rules.dart';
import '../security/scoring.dart';
import '../../services/native_channel.dart';

class AuditStage {
  final String id;
  final String nameAr;
  final String nameEn;
  final int order;

  AuditStage(this.id, this.nameAr, this.nameEn, this.order);

  static final List<AuditStage> all = [
    AuditStage('packages', 'الحزم', 'Packages', 1),
    AuditStage('accessibility', 'إمكانية الوصول', 'Accessibility', 2),
    AuditStage('device_admin', 'مسؤولو الجهاز', 'Device Admins', 3),
    AuditStage('notification', 'قارئو الإشعارات', 'Notification Readers', 4),
    AuditStage('keyboard', 'لوحة المفاتيح', 'Keyboards', 5),
    AuditStage('ca_certs', 'شهادات CA', 'CA Certificates', 6),
    AuditStage('root_boot', 'الجذر والإقلاع', 'Root & Boot', 7),
    AuditStage('scoring', 'التقييم والكتابة', 'Scoring', 8),
  ];
}

class AuditProgress {
  final AuditStage stage;
  final int checked;
  final int total;
  final double percent;
  AuditProgress(this.stage, this.checked, this.total, this.percent);
}

class AuditResult {
  final List<Finding> findings;
  final int trustScore;
  final Duration duration;
  final DateTime timestamp;
  final List<String> failedStages;
  AuditResult({required this.findings, required this.trustScore, required this.duration, required this.timestamp, this.failedStages = const []});
}

class AuditEngine {
  final NativeChannel _channel = NativeChannel();
  bool _cancelled = false;

  void cancel() => _cancelled = true;

  Stream<AuditProgress> _progressStream() async* {
    for (var stage in AuditStage.all) {
      if (_cancelled) break;
      yield AuditProgress(stage, 0, 100, (stage.order - 1) / AuditStage.all.length);
    }
  }

  Future<AuditResult> runFullAudit({void Function(AuditProgress)? onProgress}) async {
    _cancelled = false;
    final stopwatch = Stopwatch()..start();
    List<Finding> allFindings = [];
    List<String> failed = [];

    for (var stage in AuditStage.all) {
      if (_cancelled) break;
      try {
        final stageFindings = await _runStage(stage, onProgress).timeout(const Duration(seconds: 12), onTimeout: () {
          failed.add('${stage.nameAr}: انتهى الوقت');
          return <Finding>[];
        });
        allFindings.addAll(stageFindings);
      } catch (e) {
        failed.add('${stage.nameAr}: ${e.toString().substring(0, 60)}');
      } finally {
        onProgress?.call(AuditProgress(stage, 100, 100, stage.order / AuditStage.all.length));
      }
    }

    stopwatch.stop();
    final score = TrustScoreCalculator.calculate(allFindings);
    return AuditResult(findings: allFindings, trustScore: score, duration: stopwatch.elapsed, timestamp: DateTime.now(), failedStages: failed);
  }

  Future<List<Finding>> _runStage(AuditStage stage, void Function(AuditProgress)? onProgress) async {
    await Future.delayed(const Duration(milliseconds: 200));
    switch (stage.id) {
      case 'packages':
        return await _channel.scanPackages(onProgress: (c, t) => onProgress?.call(AuditProgress(stage, c, t, 0.1 + (c / t) * 0.1)));
      case 'accessibility':
        return await _channel.scanAccessibility();
      case 'device_admin':
        return await _channel.scanDeviceAdmins();
      case 'notification':
        return await _channel.scanNotificationListeners();
      case 'keyboard':
        return await _channel.scanKeyboards();
      case 'ca_certs':
        return await _channel.scanCACerts();
      case 'root_boot':
        return await _channel.scanRootAndBoot();
      case 'scoring':
        return [];
      default:
        return [];
    }
  }
}
