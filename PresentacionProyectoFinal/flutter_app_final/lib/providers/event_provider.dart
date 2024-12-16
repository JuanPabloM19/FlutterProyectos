import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/providers/equipment_provider.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/services/firebase_services.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';

class EventProvider with ChangeNotifier {
  final FirebaseServices _firebaseServices = FirebaseServices();
  Map<DateTime, List<String>> _occupiedTeams = {};
  List<Event> _events = [];
  Map<String, Map<DateTime, List<Event>>> _userEvents = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserProvider _userProvider = UserProvider();
  String? _userId;
  List<Event> get events => _events;

  EventProvider() {
    loadEvents();
    _loadOccupiedTeams();
  }

  void setUserId(String userId) {
    _userId = userId;
    print(' UID asignado en Provider: $_userId');
    fetchUserEventsFromFirebase();
  }

  // Método para obtener todos los eventos de Firebase
  Future<void> fetchEvents({bool isAdmin = false}) async {
    try {
      if (isAdmin) {
        final querySnapshot =
            await FirebaseFirestore.instance.collection('events').get();
        if (querySnapshot.docs.isEmpty) {
          print('No se encontraron eventos para cargar.');
        } else {
          _events = querySnapshot.docs
              .map((doc) => Event.fromMap(doc.data()))
              .toList();
          notifyListeners();
        }
      } else {
        final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('events')
            .get();

        if (querySnapshot.docs.isEmpty) {
          print('No se encontraron eventos para el usuario.');
        } else {
          _events = querySnapshot.docs
              .map((doc) => Event.fromMap(doc.data()))
              .toList();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error al obtener eventos: $e');
    }
  }

  Map<DateTime, List<Event>> _groupEventsByDate(List<Event> events) {
    final Map<DateTime, List<Event>> groupedEvents = {};
    for (var event in events) {
      final dateOnly =
          DateTime(event.date.year, event.date.month, event.date.day);
      if (!groupedEvents.containsKey(dateOnly)) {
        groupedEvents[dateOnly] = [];
      }
      groupedEvents[dateOnly]!.add(event);
    }
    return groupedEvents;
  }

// Obtener eventos de Firebase y actualizar estado local
  Future<void> fetchUserEventsFromFirebase() async {
    if (_userId == null || _userId!.isEmpty) {
      print(' Error: El UID es nulo o vacío. No se puede obtener eventos.');
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('events')
          .get();

      _events = querySnapshot.docs.map((doc) {
        final eventData = doc.data();
        return Event.fromMap(eventData);
      }).toList();

      print(' Eventos cargados correctamente: ${_events.length} eventos');
      notifyListeners();
    } catch (e) {
      print(' Error al obtener eventos para UID $_userId: $e');
    }
  }

  List<Event> getEventsForDay(DateTime selectedDay, String userId) {
    try {
      return _events.where((event) {
        final eventDateOnly =
            DateTime(event.date.year, event.date.month, event.date.day);
        final selectedDayOnly =
            DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

        return event.userId == userId && eventDateOnly == selectedDayOnly;
      }).toList();
    } catch (e) {
      print("Error al filtrar eventos del día: $e");
      return [];
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<List<Event>> getAllEventsForDay(DateTime day,
      {bool isAdmin = false}) async {
    try {
      final startOfDay = DateTime.utc(day.year, day.month, day.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(Duration(seconds: 1));

      final eventsForDay = <Event>[];

      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print("Usuario no autenticado");
        return [];
      }

      if (isAdmin) {
        // Si es administrador, obtenemos todos los eventos de todos los usuarios
        final usersSnapshot =
            await FirebaseFirestore.instance.collection('users').get();
        for (var userDoc in usersSnapshot.docs) {
          final eventsSnapshot = await userDoc.reference
              .collection('events')
              .where('date',
                  isGreaterThanOrEqualTo: startOfDay.toIso8601String())
              .where('date', isLessThan: endOfDay.toIso8601String())
              .get();

          for (var eventDoc in eventsSnapshot.docs) {
            eventsForDay.add(Event.fromFirestore(eventDoc));
          }
        }
      } else {
        // Si no es administrador, obtenemos solo los eventos del usuario logueado
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('events')
            .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
            .where('date', isLessThan: endOfDay.toIso8601String())
            .get();

        for (var eventDoc in querySnapshot.docs) {
          eventsForDay.add(Event.fromFirestore(eventDoc));
        }
      }
      return eventsForDay;
    } catch (e) {
      print("Error al obtener eventos: $e");
      return [];
    }
  }

  // Editar evento
  Future<void> editEvent(
      BuildContext context, Event oldEvent, Event updatedEvent) async {
    try {
      await _firebaseServices.updateEvent(oldEvent, updatedEvent, context);
      await fetchUserEventsFromFirebase();
    } catch (e) {
      print("Error al editar evento: $e");
    }
  }

  // Método para agregar un evento en EventProvider
  Future<void> addEvent(BuildContext context, Event event) async {
    try {
      if (event.id.isEmpty) {
        var uuid = Uuid();
        event.id = uuid.v4();
      }

      if (event.title.isEmpty ||
          event.userId.isEmpty ||
          event.equipment.isEmpty) {
        print("Error: Datos incompletos para el evento.");
        return;
      }

      final equipmentProvider =
          Provider.of<EquipmentProvider>(context, listen: false);
      final success = await equipmentProvider.reserveEquipment(
        event.equipment,
        event.date.toIso8601String(),
        event.userId,
        event.title,
        event.startTime,
        event.endTime,
        event.color,
        event.data ?? '',
        context,
        event.id,
      );

      if (!success) {
        throw Exception('No se pudo reservar el equipo para esta fecha.');
      }

      notifyListeners();
      print("Evento agregado correctamente con ID: ${event.id}");
    } catch (e) {
      print("Error al agregar evento: $e");
    }
  }

  // Guardar evento localmente
  void _saveEventLocally(String userId, Event event) {
    if (_userEvents[userId] == null) {
      _userEvents[userId] = {};
    }
    final dateOnly =
        DateTime(event.date.year, event.date.month, event.date.day);
    if (_userEvents[userId]![dateOnly] == null) {
      _userEvents[userId]![dateOnly] = [];
    }
    _userEvents[userId]![dateOnly]!.add(event);
  }

  // Eliminar evento
  Future<void> deleteEvent(
      BuildContext context, DateTime date, Event event) async {
    try {
      final firebaseServices = FirebaseServices();
      await firebaseServices.deleteEvent(event.userId, event);

      final dateOnly = DateTime(date.year, date.month, date.day);
      _userEvents[event.userId]?[dateOnly]
          ?.removeWhere((e) => e.id == event.id);

      notifyListeners();
      await fetchUserEventsFromFirebase();
    } catch (e) {
      print('Error al eliminar evento: $e');
      throw e;
    }
  }

// Método público para cargar eventos
  Future<void> loadEvents() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print("Error: Usuario no autenticado.");
        return;
      }
      await fetchEvents();
      _userEvents.clear();

      if (_events.isNotEmpty) {
        for (var event in _events) {
          final dateOnly =
              DateTime(event.date.year, event.date.month, event.date.day);
          if (_userEvents[userId] == null) {
            _userEvents[userId] = {};
          }
          if (_userEvents[userId]![dateOnly] == null) {
            _userEvents[userId]![dateOnly] = [];
          }
          _userEvents[userId]![dateOnly]!.add(event);
        }
      } else {
        print("No se encontraron eventos para cargar.");
      }
    } catch (e) {
      print("Error al cargar eventos: $e");
    }
  }

  // Verificar si el equipo está disponible para una fecha específica
  bool isTeamAvailable(String equipmentName, DateTime selectedDate,
      TimeOfDay startTime, TimeOfDay endTime) {
    DateTime startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );

    for (var userEvents in _userEvents.values) {
      if (userEvents[selectedDate] != null) {
        for (var event in userEvents[selectedDate]!) {
          if (event.equipment == equipmentName) {
            DateTime eventStartTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              event.startTime.hour,
              event.startTime.minute,
            );

            DateTime eventEndTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              event.endTime.hour,
              event.endTime.minute,
            );

            if ((startDateTime.isBefore(eventEndTime) &&
                    endDateTime.isAfter(eventStartTime)) ||
                startDateTime.isAtSameMomentAs(eventStartTime) ||
                endDateTime.isAtSameMomentAs(eventEndTime)) {
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  Future<void> _loadOccupiedTeams() async {
    try {
      _occupiedTeams = await _firebaseServices.getOccupiedTeams();
    } catch (e) {
      print("Error al cargar equipos ocupados: $e");
    }
  }

  Future<void> _saveOccupiedTeams() async {
    try {
      await _firebaseServices.saveOccupiedTeams(_occupiedTeams);
    } catch (e) {
      print("Error al guardar equipos ocupados: $e");
    }
  }

// Método para obtener todos los eventos de todos los usuarios (solo para admin)
  Future<List<Map<String, dynamic>>> fetchAllEventsForAdmin() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    var doc = await _firestore.collection('users').doc(currentUser?.uid).get();
    if (doc.exists && doc.data()?['isAdmin'] == true) {
      var querySnapshot = await _firestore.collection('events').get();
      return querySnapshot.docs.map((e) => e.data()).toList();
    } else {
      return [];
    }
  }
}
