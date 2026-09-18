import 'dart:io';
import 'package:flutter/services.dart';
import '../core/security/rules.dart';
import '../core/security/scoring.dart';

class NativeChannel {
  static const _channel = MethodChannel('sa.safi.audit');

  Future<List<Finding>> scanPackages({void Function(int, int)? onProgress}) async {
    try {
      final result = await _channel.invokeMethod('scanPackages');
      return _parseFindings(result);
    } on MissingPluginException {
      return _mockScanPackages(onProgress);
    } catch (e) {
      return _mockScanPackages(onProgress);
    }
  }

  Future<List<Finding>> scanAccessibility() async {
    try {
      final result = await _channel.invokeMethod('scanAccessibility');
      return _parseFindings(result);
    } catch (_) {
      return [];
    }
  }

  Future<List<Finding>> scanDeviceAdmins() async {
    try {
      final result = await _channel.invokeMethod('scanDeviceAdmins');
      return _parseFindings(result);
    } catch (_) {
      return [];
    }
  }

  Future<List<Finding>> scanNotificationListeners() async {
    try {
      final result = await _channel.invokeMethod('scanNotificationListeners');
      return _parseFindings(result);
    } catch (_) {
      return [];
    }
  }

  Future<List<Finding>> scanKeyboards() async {
    try {
      final result = await _channel.invokeMethod('scanKeyboards');
      return _parseFindings(result);
    } catch (_) {
      return [];
    }
  }

  Future<List<Finding>> scanCACerts() async {
    try {
      final result = await _channel.invokeMethod('scanCACerts');
      return _parseFindings(result);
    } catch (_) {
      return [];
    }
  }

  Future<List<Finding>> scanRootAndBoot() async {
    try {
      final result = await _channel.invokeMethod('scanRootAndBoot');
      return _parseFindings(result);
    } catch (_) {
      return _mockRootCheck();
    }
  }

  List<Finding> _parseFindings(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) {
        final map = Map<String, dynamic>.from(e);
        return Finding(
          id: map['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
          ruleId: map['ruleId'] ?? 'UNKNOWN',
          packageName: map['packageName'] ?? 'unknown',
          appName: map['appName'] ?? map['packageName'] ?? 'unknown',
          version: map['version'] ?? '1.0',
          installedAt: DateTime.tryParse(map['installedAt'] ?? '') ?? DateTime.now(),
          severity: _severityFromString(map['severity']),
          category: _categoryFromString(map['category']),
          evidence: map['evidence'] ?? '',
        );
      }).toList();
    }
    return [];
  }

  Severity _severityFromString(String? s) {
    switch (s) {
      case 'critical': return Severity.critical;
      case 'high': return Severity.high;
      case 'medium': return Severity.medium;
      default: return Severity.unknown;
    }
  }

  RuleCategory _categoryFromString(String? s) {
    switch (s) {
      case 'watcher': return RuleCategory.watcher;
      case 'permission': return RuleCategory.permission;
      case 'deviceControl': return RuleCategory.deviceControl;
      case 'network': return RuleCategory.network;
      case 'environment': return RuleCategory.environment;
      case 'appSource': return RuleCategory.appSource;
      case 'hiddenApp': return RuleCategory.hiddenApp;
      case 'session': return RuleCategory.session;
      case 'phishing': return RuleCategory.phishing;
      default: return RuleCategory.appSource;
    }
  }

  // Mock for emulator/dev
  Future<List<Finding>> _mockScanPackages(void Function(int, int)? onProgress) async {
    final mockPackages = [
      {'pkg': 'com.hidden.spyapp', 'name': 'System Update', 'rule': 'APP_HIDDEN_NO_LAUNCHER'},
      {'pkg': 'com.example.vpnfree', 'name': 'Free VPN Super', 'rule': 'NET_VPN_UNSPECIFIED'},
    ];
    List<Finding> findings = [];
    for (int i = 0; i < 120; i++) {
      if (i % 10 == 0) {
        onProgress?.call(i, 120);
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }
    // Simulate 2 findings on mock
    if (Platform.isAndroid) {
      // real device will use native
    } else {
      findings.add(Finding(
        id: 'mock-1',
        ruleId: 'APP_HIDDEN_NO_LAUNCHER',
        packageName: 'com.hidden.spyapp',
        appName: 'System Update',
        version: '2.1',
        installedAt: DateTime.now().subtract(const Duration(days: 2)),
        severity: Severity.critical,
        category: RuleCategory.hiddenApp,
        evidence: 'No launcher activity',
      ));
    }
    onProgress?.call(120, 120);
    return findings;
  }

  List<Finding> _mockRootCheck() {
    return [];
  }

  Future<bool> openSystemSettings(String action) async {
    try {
      await _channel.invokeMethod('openSettings', {'action': action});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final res = await _channel.invokeMethod('getInstalledApps');
      return (res as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
