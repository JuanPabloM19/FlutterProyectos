import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/equipment_model.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:provider/provider.dart';

class EquipmentWidget extends StatefulWidget {
  final Equipment? selectedEquipment;
  final List<Equipment> equipmentList;
  final Function(Equipment?) onChanged;
  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
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
  _EquipmentWidgetState createState() => _EquipmentWidgetState();
}

class _EquipmentWidgetState extends State<EquipmentWidget> {
  late Equipment? _currentSelectedEquipment;

  @override
  void initState() {
    super.initState();
    _currentSelectedEquipment = widget.selectedEquipment;
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<Equipment>(
        value: _currentSelectedEquipment,
        isExpanded: true,
        items: widget.equipmentList.map((equipment) {
          bool isAvailable = eventProvider.isTeamAvailable(
            equipment.nameE,
            widget.selectedDate,
            widget.startTime,
            widget.endTime,
          );

          return DropdownMenuItem<Equipment>(
            value: equipment,
            child: Text(
              equipment.nameE,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isAvailable ? Colors.black : Colors.grey,
              ),
            ),
            enabled: isAvailable,
          );
        }).toList(),
        onChanged: (Equipment? equipment) {
          if (equipment != null &&
              eventProvider.isTeamAvailable(
                equipment.nameE,
                widget.selectedDate,
                widget.startTime,
                widget.endTime,
              )) {
            setState(() {
              _currentSelectedEquipment = equipment;
            });
            widget.onChanged(equipment);
          }
        },
        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
        dropdownColor: Colors.white,
      ),
    );
  }
}
