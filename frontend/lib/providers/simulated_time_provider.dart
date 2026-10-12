
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/core/services/time_services.dart';

final simulatedTimeProvider = NotifierProvider<SimulatedTimeNotifier, DateTime?>(
    SimulatedTimeNotifier.new);

class SimulatedTimeNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    state = await TimeServices.getSimulatedTime();
  }

  Future<void> setTime(DateTime time) async {
    await TimeServices.saveSimulatedTime(time);
    state = time;
  }
  Future<void> reload() async {
    await _load();
  }

}
