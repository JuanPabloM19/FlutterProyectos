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
  final TimeOfDay endTime; // Added to account for time range
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
      padding:
          EdgeInsets.symmetric(horizontal: 16), // Added padding for spacing
      child: DropdownButton<Equipment>(
        value: selectedEquipment,
        isExpanded: true, // Ensure dropdown expands to fit content
        items: equipmentList.map((equipment) {
          bool isAvailable = eventProvider.isTeamAvailable(
            equipment.nameE,
            selectedDate,
            startTime, // Passing start time
            endTime, // Passing end time
          );

          return DropdownMenuItem<Equipment>(
            value: equipment,
            child: Text(
              equipment.nameE,
              overflow: TextOverflow.ellipsis, // Handle long text with ellipsis
              style: TextStyle(
                color: isAvailable ? Colors.black : Colors.grey,
              ),
            ),
            enabled: isAvailable, // Enable/Disable based on availability
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
            onChanged(equipment); // Notify only if available
          }
        },
        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
        dropdownColor: Colors.white,
      ),
    );
  }
}
