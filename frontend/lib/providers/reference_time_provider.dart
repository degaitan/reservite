
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/providers/simulated_time_provider.dart';

//s'il y a un temps simulé return temps simulé sinon .now()

final referenceTimeProvider = Provider<DateTime>((ref) {
  final simulated = ref.watch(simulatedTimeProvider);
  return simulated ?? DateTime.now();
});