import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/equipment_model.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:provider/provider.dart';

class EquipmentWidget extends StatelessWidget {
  final Equipment? selectedEquipment;
  final List<Equipment> equipmentList;
  final Function(Equipment?) onChanged;
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime; // Añadido para tener en cuenta el rango de tiempo
  final String userId;

  EquipmentWidget({
    required this.selectedEquipment,
    required this.equipmentList,
    required this.onChanged,
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Container(
      width: 200,
      child: DropdownButton<Equipment>(
        value: selectedEquipment,
        items: equipmentList.map((equipment) {
          bool isAvailable = eventProvider.isTeamAvailable(
            equipment.nameE,
            selectedDate,
            startTime, // Pasar la hora de inicio
            endTime, // Pasar la hora de fin
          );

          return DropdownMenuItem<Equipment>(
            value: equipment,
            child: Text(
              equipment.nameE,
              style: TextStyle(
                color: isAvailable ? Colors.black : Colors.grey,
              ),
            ),
            enabled:
                isAvailable, // Habilitar o deshabilitar según disponibilidad
          );
        }).toList(),
        onChanged: (Equipment? equipment) {
          if (equipment != null &&
              eventProvider.isTeamAvailable(
                equipment.nameE,
                selectedDate,
                startTime,
                endTime,
              )) {
            onChanged(equipment); // Notificar el cambio solo si está disponible
          }
        },
      ),
    );
  }
} 
