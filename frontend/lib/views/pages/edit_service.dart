import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/reservation.dart';
import '../../models/services.dart';
import '../../providers/manager_state_provider.dart';
import '../widgets/time_travel_widget.dart';

class EditServiceScreen extends ConsumerStatefulWidget {
  const EditServiceScreen({super.key});

  @override
  ConsumerState<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends ConsumerState<EditServiceScreen> {
  int? _loadedServiceId;

  int? dayOfWeek;
  int? startHour;
  int? startMinute;
  int? endHour;
  int? endMinute;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(managerStateProvider);
    final notifier = ref.read(managerStateProvider.notifier);
    final theme = Theme.of(context);

    return state.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text(error.toString()),
        ),
      ),
      data: (managerState) {
        final service = managerState.currentService;

        if (service == null) {
          return const Scaffold(
            body: Center(
              child: Text('Aucun service sélectionné.'),
            ),
          );
        }

        _loadInitialValues(service);

        final validationMessage = _getValidationMessage(
          service,
          managerState,
        );

        final canSave = validationMessage == null;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Modifier le service'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                tooltip: 'Enregistrer',
                onPressed: canSave
                    ? () async {
                  try {
                    await notifier.updateCurrentService(
                      dayOfWeek: dayOfWeek!,
                      startTime: _formatTime(
                        startHour!,
                        startMinute!,
                      ),
                      endTime: _formatTime(
                        endHour!,
                        endMinute!,
                      ),
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                }
                    : null,
                icon: const Icon(Icons.save),
              ),
            ],
            elevation: 2,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: const Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: TimeTravelWidget(),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: dayOfWeek,
                      decoration: const InputDecoration(
                        labelText: 'Jour',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Lundi')),
                        DropdownMenuItem(value: 2, child: Text('Mardi')),
                        DropdownMenuItem(value: 3, child: Text('Mercredi')),
                        DropdownMenuItem(value: 4, child: Text('Jeudi')),
                        DropdownMenuItem(value: 5, child: Text('Vendredi')),
                        DropdownMenuItem(value: 6, child: Text('Samedi')),
                        DropdownMenuItem(value: 7, child: Text('Dimanche')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          dayOfWeek = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            initialValue: startHour,
                            decoration: const InputDecoration(
                              labelText: 'Heure de début (heure)',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              for (int h = 0; h < 24; h++)
                                DropdownMenuItem<int?>(
                                  value: h,
                                  child: Text(
                                    '${h.toString().padLeft(2, '0')} h',
                                  ),
                                ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                startHour = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            initialValue: startMinute,
                            decoration: const InputDecoration(
                              labelText: 'Minutes',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem<int?>(
                                value: 0,
                                child: Text('00 min'),
                              ),
                              DropdownMenuItem<int?>(
                                value: 15,
                                child: Text('15 min'),
                              ),
                              DropdownMenuItem<int?>(
                                value: 30,
                                child: Text('30 min'),
                              ),
                              DropdownMenuItem<int?>(
                                value: 45,
                                child: Text('45 min'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                startMinute = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            initialValue: endHour,
                            decoration: const InputDecoration(
                              labelText: 'Heure de fin (heure)',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              for (int h = 0; h < 24; h++)
                                DropdownMenuItem<int?>(
                                  value: h,
                                  child: Text(
                                    '${h.toString().padLeft(2, '0')} h',
                                  ),
                                ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                endHour = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            initialValue: endMinute,
                            decoration: const InputDecoration(
                              labelText: 'Minutes',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem<int?>(
                                value: 0,
                                child: Text('00 min'),
                              ),
                              DropdownMenuItem<int?>(
                                value: 15,
                                child: Text('15 min'),
                              ),
                              DropdownMenuItem<int?>(
                                value: 30,
                                child: Text('30 min'),
                              ),
                              DropdownMenuItem<int?>(
                                value: 45,
                                child: Text('45 min'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                endMinute = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    if (validationMessage != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.red[700],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  validationMessage,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _loadInitialValues(Services service) {
    if (_loadedServiceId == service.id) return;

    final start = _parseTimeParts(service.startTime);
    final end = _parseTimeParts(service.endTime);

    dayOfWeek = service.dayOfWeek;
    startHour = start.hour;
    startMinute = start.minute;
    endHour = end.hour;
    endMinute = end.minute;

    _loadedServiceId = service.id;
  }

  String? _getValidationMessage(
      Services editedService,
      ManagerState managerState,
      ) {
    if (dayOfWeek == null ||
        startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null) {
      return 'Tous les champs doivent être renseignés.';
    }

    final newStart = Duration(
      hours: startHour!,
      minutes: startMinute!,
    );

    final newEnd = Duration(
      hours: endHour!,
      minutes: endMinute!,
    );

    if (newStart >= newEnd) {
      return "L'heure de début doit être avant l'heure de fin.";
    }

    final otherServices = managerState.currentRestaurantServices
        .where((service) => service.id != editedService.id)
        .toList();

    for (final otherService in otherServices) {
      if (otherService.dayOfWeek != dayOfWeek) continue;

      final otherStart = _parseTime(otherService.startTime);
      final otherEnd = _parseTime(otherService.endTime);

      if (_overlaps(newStart, newEnd, otherStart, otherEnd)) {
        return 'Ce service chevauche un autre service existant '
            '(${otherService.startTime.substring(0, 5)} - '
            '${otherService.endTime.substring(0, 5)}).';
      }
    }

    final slotDuration =
        managerState.currentRestaurant?.slotDuration ?? 1;

    final blockingReservations = managerState.reservations.where(
          (reservation) => _reservationBelongsToService(
        reservation,
        editedService,
        slotDuration,
      ),
    );

    for (final reservation in blockingReservations) {
      final reservationStart = Duration(
        hours: reservation.dateTime.hour,
        minutes: reservation.dateTime.minute,
      );

      final reservationEnd =
          reservationStart + Duration(minutes: slotDuration);

      if (dayOfWeek != reservation.dateTime.weekday) {
        return 'Ce service contient déjà des réservations. '
            'Son jour ne peut pas être modifié.';
      }

      if (newStart > reservationStart) {
        return 'Le début du service doit être à '
            '${_formatDuration(reservationStart)} au plus tard, '
            'car une réservation existe déjà à cette heure.';
      }

      if (newEnd < reservationEnd) {
        return 'La fin du service doit être à '
            '${_formatDuration(reservationEnd)} au plus tôt, '
            'car une réservation utilise ce créneau.';
      }
    }

    return null;
  }

  bool _reservationBelongsToService(
      Reservation reservation,
      Services service,
      int slotDuration,
      ) {
    if (reservation.status == 'completed' ||
        reservation.status == 'cancelled') {
      return false;
    }

    if (reservation.dateTime.weekday != service.dayOfWeek) {
      return false;
    }

    final serviceStart = _parseTime(service.startTime);
    final serviceEnd = _parseTime(service.endTime);

    final reservationStart = Duration(
      hours: reservation.dateTime.hour,
      minutes: reservation.dateTime.minute,
    );

    final reservationEnd =
        reservationStart + Duration(minutes: slotDuration);

    return _overlaps(
      reservationStart,
      reservationEnd,
      serviceStart,
      serviceEnd,
    );
  }

  bool _overlaps(
      Duration firstStart,
      Duration firstEnd,
      Duration secondStart,
      Duration secondEnd,
      ) {
    return firstStart < secondEnd && firstEnd > secondStart;
  }

  Duration _parseTime(String value) {
    final parts = value.split(':');

    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
    );
  }

  _HourMinute _parseTimeParts(String value) {
    final parts = value.split(':');

    return _HourMinute(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:00';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';
  }
}

class _HourMinute {
  final int hour;
  final int minute;

  const _HourMinute({
    required this.hour,
    required this.minute,
  });
}