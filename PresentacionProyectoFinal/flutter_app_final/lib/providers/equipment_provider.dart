/* import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/equipment_model.dart';
import 'package:flutter_app_final/utils/databaseHelper.dart';

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
      _equipmentList = await DatabaseHelper().getAllEquipment();
      _error = null; // Resetea el error si todo salió bien
    } catch (e) {
      print("Error: $e"); // Imprimir error para depuración
      _error = "Error al cargar equipos: ${e.toString()}"; // Manejo de errores
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para reservar un equipo
  Future<bool> reserveEquipment(
      int equipmentId, String date, String userId) async {
    final success =
        await DatabaseHelper().reserveEquipment(equipmentId, date, userId);
    if (success) {
      await fetchEquipments(); // Recargar la lista después de la reserva
    }
    return success;
  }

  // Método para liberar un equipo
  Future<void> freeEquipment(int equipmentId, String date) async {
    await DatabaseHelper().freeEquipment(equipmentId, date);
    await fetchEquipments(); // Recargar la lista después de liberar
  }
} */
