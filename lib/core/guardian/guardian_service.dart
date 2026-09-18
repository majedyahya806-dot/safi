import 'package:workmanager/workmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Silent scan: check if new accessibility/notification listeners appeared
    // If yes, show notification
    // This runs in background isolate
    // For now, log and return
    return Future.value(true);
  });
}

class GuardianService {
  static const String taskName = 'safi_guardian_check';
  final _storage = const FlutterSecureStorage();

  Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  Future<void> enable({required int intervalHours}) async {
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: Duration(hours: intervalHours),
      constraints: Constraints(networkType: NetworkType.not_required, requiresBatteryNotLow: false),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    await _storage.write(key: 'guardian_enabled', value: 'true');
    await _storage.write(key: 'guardian_interval', value: intervalHours.toString());
  }

  Future<void> disable() async {
    await Workmanager().cancelByUniqueName(taskName);
    await _storage.write(key: 'guardian_enabled', value: 'false');
  }

  Future<bool> isEnabled() async {
    final v = await _storage.read(key: 'guardian_enabled');
    return v == 'true';
  }

  Future<int> getInterval() async {
    final v = await _storage.read(key: 'guardian_interval');
    return int.tryParse(v ?? '24') ?? 24;
  }
}
