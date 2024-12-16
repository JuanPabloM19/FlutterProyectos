import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/models/equipment_model.dart';
import 'package:flutter_app_final/models/event_model.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:flutter_app_final/utils/databaseHelper.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class EquipmentProvider with ChangeNotifier {
  List<Equipment> _equipmentList = [];
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    String equipmentId,
    String date,
    String userId,
    String title,
    TimeOfDay startTime,
    TimeOfDay endTime,
    Color color,
    String data,
    BuildContext context,
    String eventId,
  ) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Buscar equipo por nombre (nameE)
        QuerySnapshot querySnapshot = await _firestore
            .collection('equipment')
            .where('nameE', isEqualTo: equipmentId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw Exception("Equipo no encontrado");
        }

        DocumentReference equipmentRef = querySnapshot.docs.first.reference;

        DocumentSnapshot equipmentSnapshot =
            await transaction.get(equipmentRef);
        Map<String, dynamic> equipmentData =
            equipmentSnapshot.data() as Map<String, dynamic>;
        List<String> reservedDates = (equipmentData['reservedDates'] is List)
            ? List<String>.from(equipmentData['reservedDates'])
            : [];

        if (reservedDates.contains(date)) {
          throw Exception("El equipo ya está reservado para esta fecha.");
        }

        // Actualizar lista de fechas reservadas
        reservedDates.add(date);
        transaction.update(equipmentRef, {
          'reservedDates': FieldValue.arrayUnion([date])
        });

        DateTime parsedDate = DateTime.parse(date);
        String formattedDate = parsedDate.toIso8601String();

        Event newEvent = Event(
          id: eventId, // Usar el ID proporcionado, no generarlo de nuevo
          title: title,
          date: parsedDate,
          startTime: startTime,
          endTime: endTime,
          color: color,
          userId: userId,
          equipment: equipmentId,
          data: data,
        );

        DocumentReference eventRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(eventId);

        transaction.set(eventRef, newEvent.toJson());
      });

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print("Error al reservar equipo: $e");
      return false;
    }
  }

  Future<bool> checkEquipmentAvailability(
      String equipmentId, String date) async {
    try {
      DocumentSnapshot equipmentSnapshot =
          await _firestore.collection('equipment').doc(equipmentId).get();

      if (!equipmentSnapshot.exists) {
        throw Exception("Equipo no encontrado");
      }

      Map<String, dynamic> equipmentData =
          equipmentSnapshot.data() as Map<String, dynamic>;
      var reservedDatesData = equipmentData['reservedDates'];
      List<String> reservedDates = (reservedDatesData is List)
          ? List<String>.from(reservedDatesData)
          : [];

      return !reservedDates.contains(date);
    } catch (e) {
      print("Error al verificar disponibilidad: $e");
      return false;
    }
  }

  Future<void> freeEquipment(int equipmentId, String date) async {
    await DatabaseHelper().freeEquipment(equipmentId, date);
    await fetchEquipments();
  }
}
