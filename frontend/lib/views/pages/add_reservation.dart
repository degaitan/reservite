import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a03/core/services/reservation_services.dart';
import 'package:prbd_2526_a03/models/no_slots_reason.dart';
import 'package:prbd_2526_a03/providers/reference_time_provider.dart';
import 'package:prbd_2526_a03/views/widgets/time_travel_widget.dart';

import '../../core/tools/debounce.dart';
import '../../providers/client_state_provider.dart';


class NewReservationScreen extends ConsumerStatefulWidget {
  final int? resaId;
  const NewReservationScreen({super.key, this.resaId});


  @override
  ConsumerState<NewReservationScreen> createState() => _NewReservationScreen();
}

class _NewReservationScreen extends ConsumerState<NewReservationScreen> {
  DateTime? selectedDate;
  int numberOfGuests = 2;
  DateTime? selectedSlot;
  bool? canFitTable;
  final _guestDebounce = Debouncer(delay: const Duration(milliseconds: 500));

  final _specialRequestController = TextEditingController();

  bool get isEdit => widget.resaId != null;

  int? _restaurantId;
  String _restaurantName = '';

  @override
  void dispose() {
    _specialRequestController.dispose();
    _guestDebounce.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {


      final notifier = ref.read(clientStateProvider.notifier);
      //pré-remplissage des fields à l'ouverture de la page en mode edit

      if(isEdit){
        await notifier.loadReservationDetails(widget.resaId!);
        final details = ref.read(clientStateProvider).value?.currentReservationDetails?.value;
        if(details == null) return;

        setState(() {
          selectedDate = DateTime(details.dateTime.year, details.dateTime.month, details.dateTime.day);
          selectedSlot = details.dateTime;
          numberOfGuests = details.numberOfGuests;
          _specialRequestController.text = details.specialRequests ?? '';
        });

        if(details.restoId != null){
          //on appelle la methode en dehors du setstate car setstate se charge des champs locaux, loadslotsperday met a jour le state du provider donc non local
          final day = DateTime(details.dateTime.year, details.dateTime.month, details.dateTime.day);
          notifier.loadSlotsPerDay(details.restoId!, day, numberOfGuests, widget.resaId);

          _restaurantId = details.restoId;
          _restaurantName = details.restoName;
        }


      } else {
        //si on crée, rien a prefill, pas de resaId
        final restaurant = ref.read(clientStateProvider).value?.currentRestaurant;
        if(restaurant!=null){
          notifier.loadFirstAvailableSlots(restaurant.id, numberOfGuests);
          _restaurantId = restaurant.id;
          _restaurantName = restaurant.name;
        }


      }


    });
  }


  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(clientStateProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
            isEdit ? 'Modifier la réservation' : 'Nouvelle réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {},
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: TimeTravelWidget(),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: asyncState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur: $e')),
            data: (clientState) {
              return Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEdit ? 'Modifier la réservation'
                      : (clientState.currentRestaurant?.name ?? ''),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _pickDate(clientState),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Date'),
                                          Text(
                                            selectedDate != null
                                                ? DateFormat(
                                                'EEEE d/MM/yyyy', 'fr_FR')
                                                .format(selectedDate!)
                                                : (clientState.availableSlots
                                                ?.isNotEmpty == true
                                                ? DateFormat(
                                                'EEEE d/MM/yyyy', 'fr_FR')
                                                .format(
                                                clientState.availableSlots!
                                                    .first)
                                                : 'Choisir une date'),
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => _shiftDay(clientState, -1),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _shiftDay(clientState, 1),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    const Divider(),
                    if(clientState.availableSlots == null)
                      const SizedBox.shrink()
                    else
                      if (clientState.availableSlots!.isEmpty &&
                          (clientState.noSlotsError == NoSlotsReason.closed
                              || clientState.noSlotsError ==
                                  NoSlotsReason.alreadyBookedService))
                        _warningBox(clientState.noSlotsError!)
                      else
                        ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Créneaux disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: (clientState.availableSlots ?? [])
                                .map((slot) =>
                                InkWell(
                                  onTap: () async {
                                  setState(() => selectedSlot = slot);
                                  final check =
                                  await ReservationServices.checkCapacity(_restaurantId!, numberOfGuests, slot, widget.resaId);
                                  setState(()=>canFitTable = check);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: _slotCard(slot, theme),
                                  )
                            ).toList(),

                          )
                        ],
                    const SizedBox(height: 24),
                    if (selectedSlot != null && canFitTable == false)
                      _warningBox(NoSlotsReason.noCapacity),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Nombre de convives'),
                      subtitle: Text(numberOfGuests.toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            //setState force le reload de la page
                            onPressed: numberOfGuests > 1
                                ? () => _onGuestChanged(clientState, -1)
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: numberOfGuests < 10
                                ? () => _onGuestChanged(clientState, 1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _specialRequestController,
                      decoration: const InputDecoration(
                        labelText: 'Demandes spéciales (optionnel)',
                        border: OutlineInputBorder(),
                        hintText: 'Allergies, préférences...',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        //si on ne vérifie pas le empty le length vaut 0 et cela déclenche l'erreur
                        if(value!=null && value.isNotEmpty && value.length<10){
                          return "Les demandes spéciales doivent contenir au moins 10 caractères";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: (selectedSlot != null && canFitTable == true)
                          ? () => isEdit ? _saveChanges(clientState) : _createReservation(clientState)
                           : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.add),
                      label:  Text(isEdit ? 'Modifier la réservation' : 'Créer la réservation'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _slotCard(DateTime slot, ThemeData theme) {
    final isSelected = selectedSlot == slot;
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          DateFormat('HH:mm').format(slot),
          style: TextStyle(
            color: isSelected ? Colors.blue : theme.colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(ClientState clientState) async {
    final restaurant = _restaurantId;
    if (restaurant == null) return;


    final referenceTime = ref.read(referenceTimeProvider);
    /*si y a une selected date sinon si il y a des availableSlots, on affiche la date du premier slot(situation initiale
    si l'user n'a pas changé de date)*/
    final initial = selectedDate ??
        (clientState.availableSlots?.isNotEmpty == true ?
        clientState.availableSlots!.first : referenceTime);


    /*
    ici initialDate date qui s 'affiche a l'ouverture du calendrie doit être
    comprise entre first(premieredate selectionnable) et last date mais ca pose probleme pour les resa dans le passe
    donc on garde la plus ancienne des deux, soit le temps de reference soit le temps de la resa
     */
    final earliest = initial.isBefore(referenceTime) ? initial : referenceTime;

    final selected = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: earliest,
        lastDate: referenceTime.add(const Duration(days: 100))
    );

    if (selected != null) {
      setState(() {
        selectedDate = selected;
        selectedSlot = null;
        canFitTable = null;
      });

      ref.read(clientStateProvider.notifier).loadSlotsPerDay(
          restaurant, selected, numberOfGuests, widget.resaId);
    }
  }

  void _shiftDay(ClientState clientState, int delta) {
    final restaurant = _restaurantId;
    if (restaurant == null) return;

    final referenceTime = ref.read(referenceTimeProvider);

    final base = selectedDate
        ?? (clientState.availableSlots?.isNotEmpty == true
            ? DateTime(clientState.availableSlots!.first.year,
            clientState.availableSlots!.first.month,
            clientState.availableSlots!.first.day)
            : referenceTime);

    final newDate = DateTime(base.year, base.month, base.day + delta);

    setState(() {
      selectedDate = newDate;
      selectedSlot = null;
      canFitTable = null;
    });
    ref.read(clientStateProvider.notifier)
        .loadSlotsPerDay(restaurant, newDate, numberOfGuests, widget.resaId);
  }

  Widget _warningBox(NoSlotsReason reason) {
    String message;
    switch (reason) {
      case NoSlotsReason.closed:
        message = 'Le restaurant est fermé ce jour-là.';
        break;
      case NoSlotsReason.alreadyBookedService:
        message =
        'Vous avez déjà une réservation pour tous les services de ce jour.';
        break;
      case NoSlotsReason.noCapacity:
        message =
        'La capacité du restaurant est insuffisante pour le nombre de convives demandé.';
        break;
    }

    return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange),
          ),
          child:Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
    );
  }

  Future<void> _createReservation(ClientState clientState) async {
    final restaurant = _restaurantId;
    if(restaurant==null || selectedSlot==null) return;

    final text = _specialRequestController.text.trim();
    final request = text.isEmpty ? null : text;

    try {
      await ReservationServices.saveReservation(null, restaurant, selectedSlot!, numberOfGuests, 'pending', request);

      //si jamais on quitte la fenêtre alors que la methode n est pas terminée, on arrête le processus

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation créée avec succès'), backgroundColor: Colors.green),
      );

      ref.read(clientStateProvider.notifier).refresh();
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red,),
      );
    }
  }

  Future<void> _saveChanges(ClientState state) async {
    if(_restaurantId == null || selectedSlot == null) return;

    final text = _specialRequestController.text.trim();
    final request = text.isEmpty ? null : text;

    final details = state.currentReservationDetails?.value;

    final referenceTime = ref.read(referenceTimeProvider);

    if (details != null &&
        details.status == 'confirmed' &&
        details.dateTime.isAfter(referenceTime)) {
      final agreed = await showDialog<bool>(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text('Modifier une réservation confirmée'),
              content: const Text(
                  'Cette réservation est confirmée. La modifier la remettra en attente '
                      'et les tables associées seront libérées. Souhaitez-vous continuer ?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false),
                    child: const Text('Non')),
                TextButton(onPressed: () => Navigator.pop(context, true),
                    child: const Text('Oui')),
              ],
            ),
      );
      if (agreed != true) return;
    }

      try {
        await ReservationServices.saveReservation(widget.resaId, _restaurantId!, selectedSlot!, numberOfGuests, 'pending', request);
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Réservation modifiée avec succès'), backgroundColor: Colors.green));
        ref.read(clientStateProvider.notifier).refresh();
        ref.read(clientStateProvider.notifier).loadReservationDetails(widget.resaId!);
        if (!mounted) return;
        Navigator.pop(context);

      } catch (e){
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
  }


  void _onGuestChanged(ClientState clientState, int delta) {
    setState(() => numberOfGuests += delta);

    _guestDebounce(() async {
      // dès que le nb de guests change, on recheck la disponibilité
      final restaurant = _restaurantId;
      if (restaurant == null) return;

      final referenceTime = ref.read(referenceTimeProvider);
      final refDay = DateTime(referenceTime.year, referenceTime.month, referenceTime.day); //besoin juste de la date de reftime


      // on recherche les slots dispo pour ce nombre de guests
      //date écrite à la main, à changer une fois que time travel est fait
      final date = selectedDate
          ?? (clientState.availableSlots?.isNotEmpty == true
              ? DateTime(clientState.availableSlots!.first.year,
              clientState.availableSlots!.first.month,
              clientState.availableSlots!.first.day)
              : refDay);


      ref.read(clientStateProvider.notifier)
          .loadSlotsPerDay(restaurant, date, numberOfGuests, widget.resaId);

      if (selectedSlot != null) {
      final fits = await ReservationServices.checkCapacity(
      restaurant, numberOfGuests, selectedSlot!, widget.resaId);

      //mounted donc toujours sur la page
      if (mounted) setState(() => canFitTable = fits);
      }
    });
  }

}
