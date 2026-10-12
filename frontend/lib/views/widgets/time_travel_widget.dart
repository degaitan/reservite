
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/core/services/time_services.dart';
import 'package:prbd_2526_a03/providers/reference_time_provider.dart';
import 'package:prbd_2526_a03/providers/simulated_time_provider.dart';

class TimeTravelWidget extends ConsumerWidget{
  const TimeTravelWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referenceTime = ref.watch(referenceTimeProvider);

    return  Tooltip(
      message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
      child: InkWell(
        onTap: () => _pickTime(context, ref),
        child: Text(
          DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(referenceTime),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[400],
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final currentTime = ref.read(referenceTimeProvider);

    final date = await showDatePicker(
      context: context,
      initialDate: currentTime,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );
    
    if(date==null) return;
    if(!context.mounted) return ;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
    );
    if (time == null) return;
    
    final newTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    await ref.read(simulatedTimeProvider.notifier).setTime(newTime);
  }
}