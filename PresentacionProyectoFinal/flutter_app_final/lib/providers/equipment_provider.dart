import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/equipment_model.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:flutter_app_final/utils/databaseHelper.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class EquipmentProvider with ChangeNotifier {
  List<Equipment> _equipmentList = [];
  bool _isLoading = false;
  String? _error;

  List<Equipment> get equipmentList => _equipmentList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEquipments() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Map<String, dynamic>> equipmentData =
          await DatabaseHelper().getAllEquipment();
      _equipmentList = equipmentData.map((e) => Equipment.fromJson(e)).toList();
      _error = null;
    } catch (e) {
      print("Error: $e");
      _error = "Error al cargar equipos: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reserveEquipment(
    BuildContext context,
    int equipmentId,
    String date,
    String userId,
    String title,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Color? color,
  ) async {
    // Verificar si el equipo está disponible antes de la reserva
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final equipmentName = _equipmentList
        .firstWhere((equipment) => equipment.id == equipmentId)
        .nameE;

    DateTime parsedDate = DateTime.parse(date);
    bool isAvailable = eventProvider.isTeamAvailable(
      equipmentName,
      parsedDate,
      startTime!,
      endTime!,
    );

    if (!isAvailable) {
      print('El equipo no está disponible.');
      return false; // Salir si no está disponible
    }

    // Si el equipo está disponible, proceder con la reserva
    final success = await DatabaseHelper().reserveEquipment(
      equipmentId,
      date,
      userId,
      startTime,
      endTime,
    );

    if (success) {
      await fetchEquipments();
      eventProvider.addEvent(
        context,
        Event(
          title: title,
          date: parsedDate,
          startTime: startTime,
          endTime: endTime,
          color: color ?? Colors.blue,
          userId: userId,
          equipment: equipmentName,
          data: '',
        ),
      );
    }

    return success;
  }

  // Método para liberar equipo
  Future<void> freeEquipment(int equipmentId, String date) async {
    await DatabaseHelper().freeEquipment(equipmentId, date);
    await fetchEquipments();

    // Lógica para liberar el equipo en EventProvider
    DateTime parsedDate = DateTime.parse(date);
    Provider.of<EventProvider>(context as BuildContext, listen: false)
        .freeEquipment(
            equipmentId, parsedDate); // Llama al método de liberar equipo
  }
}
