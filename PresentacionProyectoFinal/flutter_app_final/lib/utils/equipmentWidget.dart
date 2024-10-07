import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/equipment_model.dart';

class EquipmentWidget extends StatelessWidget {
  final Equipment? selectedEquipment; // Cambiado a Equipment?
  final List<Equipment> equipmentList;
  final ValueChanged<Equipment?> onChanged;

  const EquipmentWidget({
    Key? key,
    required this.selectedEquipment,
    required this.equipmentList,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Equipment>(
      isExpanded: true,
      value: selectedEquipment, // Directamente el equipo seleccionado
      items:
          equipmentList.map<DropdownMenuItem<Equipment>>((Equipment equipment) {
        return DropdownMenuItem<Equipment>(
          value: equipment,
          child: Text(equipment.nameE),
        );
      }).toList(),
      onChanged: onChanged,
      hint: const Text('Selecciona un equipo'),
    );
  }
}
