import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_a03/providers/manager_state_provider.dart';
import 'package:prbd_2526_a03/views/widgets/time_travel_widget.dart';

import '../../models/tables.dart';



class EditTableScreen extends ConsumerStatefulWidget {
  final Tables? table;
  const EditTableScreen({super.key, required this.table});

  @override
  ConsumerState<EditTableScreen> createState() => _EditTableScreen();
}


class _EditTableScreen extends ConsumerState<EditTableScreen>{
  bool get isEdit => widget.table != null;
  late final ValidatingTextEditingController _tableNumberController;
  int capacity = 2;


  @override
  void initState(){
    super.initState();

    _tableNumberController = ValidatingTextEditingController(
      validator: (input) {
        if (input.trim().isEmpty) return 'Le numéro est requis';
        final n = int.tryParse(input);
        
        final tables = ref.read(managerStateProvider).value?.tablesPerRestaurant ?? [];
        //any pour verifier s'il y au moins un elem qui satisfait la condition
        final taken = tables.any((table) => table.tableNumber == n && table.id != widget.table?.id );
        if(taken) return 'Ce numéro est déjà utilisé pour ce restaurant';

        return null;
      },
      initialValue: widget.table?.tableNumber.toString() ?? '2'
    );

    _tableNumberController.onAfterValidated = () => setState(() {});

    if (isEdit) {
      capacity = widget.table!.capacity;
    }


  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minNeeded = widget.table?.minCapacityNeeded ?? 0;
    final limit = minNeeded > 1 ? minNeeded : 1;
    final atLimit = capacity <= limit;


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(isEdit ? 'Modifier la table' : 'Nouvelle table'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            onPressed: () =>  _saveTable(),
            icon: const Icon(Icons.save),
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
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _tableNumberController,
                  decoration:  InputDecoration(
                    labelText: 'Numéro de table',
                    border: const OutlineInputBorder(),
                    errorText: _tableNumberController.errorText,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Capacité'),
                Row(
                  children: [
                      Tooltip(
                      message: atLimit ? (isEdit ? 'Impossible de diminuer la capacité : une ou plusieurs résa utilisent cette table et nécessitent au moins cette capacité'
                      : 'Capacité minimale (1 personne)')
                      : '',
                  child: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: atLimit
                        ? null
                        : () => setState(() => capacity = capacity - 1),
                  ),
                ),

                     Text(
                      '$capacity personnes',
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() {
                        capacity = capacity + 1;
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveTable() async{
    await _tableNumberController.validateAndWait();
    if (_tableNumberController.isValid != true) return;

    final number = int.tryParse(_tableNumberController.text);
    final notifier = ref.read(managerStateProvider.notifier);
    if (number == null) {
      return;
    }

    try {
        await notifier.saveTable(number, capacity, widget.table?.id);

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Table sauvegardée avec succès'), backgroundColor: Colors.green));
      // notifier.loadTables();
      Navigator.pop(context);


    }catch (e){
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }
}
