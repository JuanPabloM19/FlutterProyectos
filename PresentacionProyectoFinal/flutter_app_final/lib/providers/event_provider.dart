import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/services/firebase_services.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';

class EventProvider with ChangeNotifier {
  final FirebaseServices _firebaseServices = FirebaseServices();
  Map<DateTime, List<String>> _occupiedTeams = {};
  List<Event> _events = [];
  Map<String, Map<DateTime, List<Event>>> _userEvents = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserProvider _userProvider =
      UserProvider(); // O accede a través de provider

  List<Event> get events => _events;

  EventProvider() {
    loadEvents(); // Cargar eventos al inicializar
    _loadOccupiedTeams(); // Cargar equipos ocupados al inicializar
  }

  // Método para obtener todos los eventos de Firebase
  Future<void> fetchEvents({bool isAdmin = false}) async {
    try {
      if (isAdmin) {
        // Obtener todos los eventos de todos los usuarios para el admin
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
        // Obtener eventos del usuario actual
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

  // Agrupar eventos por fecha
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
  Future<void> fetchUserEventsFromFirebase(
      BuildContext context, String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: userId)
          .get();

      _events =
          querySnapshot.docs.map((doc) => Event.fromMap(doc.data())).toList();
      notifyListeners(); // Notificar a la vista
    } catch (e) {
      print('Error al obtener eventos: $e');
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
          .subtract(Duration(seconds: 1)); // Hasta el final del día

      final eventsForDay = <Event>[];

      // Verificar si el usuario está autenticado
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print("Usuario no autenticado");
        return []; // Retorna una lista vacía si el usuario no está autenticado
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

      // Refrescar eventos locales desde Firebase
      await fetchUserEventsFromFirebase(context, updatedEvent.userId);
    } catch (e) {
      print("Error al editar evento: $e");
    }
  }

  Future<void> addEvent(BuildContext context, Event event) async {
    try {
      if (event.id.isEmpty) {
        event.id = _firestore
            .collection('users')
            .doc(event.userId)
            .collection('events')
            .doc()
            .id;
      }

      // Validar datos del evento
      if (event.title.isEmpty ||
          event.userId.isEmpty ||
          event.equipment.isEmpty) {
        print("Error: Datos incompletos para el evento.");
        return;
      }

      final dateOnly =
          DateTime(event.date.year, event.date.month, event.date.day);

      // Verificar disponibilidad del equipo
      if (!isTeamAvailable(
          event.equipment, dateOnly, event.startTime, event.endTime)) {
        throw Exception(
            'El equipo ya está reservado por otro usuario para esta fecha.');
      }

      // Guardar el evento en Firestore
      await _firebaseServices.saveUserEvents(event.userId, [event], context);

      // Guardar localmente
      _saveEventLocally(event.userId, event);
      notifyListeners();
      print("Evento agregado correctamente.");
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

      // Eliminar el evento de la lista local
      final dateOnly = DateTime(date.year, date.month, date.day);
      _userEvents[event.userId]?[dateOnly]
          ?.removeWhere((e) => e.id == event.id);

      // Notificar a los widgets dependientes que los eventos han cambiado
      notifyListeners();
      // Recargar eventos desde Firebase para sincronizar
      await fetchUserEventsFromFirebase(context, event.userId);
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

      // Espera los eventos antes de proceder
      await fetchEvents(); // Asegúrate de que los eventos están cargados

      // Limpiar eventos previos
      _userEvents.clear();

      // Iterar sobre los eventos si no están vacíos
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
    // Convertir TimeOfDay a DateTime para hacer comparaciones
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

    // Verificar eventos en el día seleccionado
    for (var userEvents in _userEvents.values) {
      if (userEvents[selectedDate] != null) {
        for (var event in userEvents[selectedDate]!) {
          if (event.equipment == equipmentName) {
            // Convertir los tiempos de los eventos a DateTime para la comparación
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

            // Verificar si hay solapamiento de horarios
            if ((startDateTime.isBefore(eventEndTime) &&
                    endDateTime.isAfter(eventStartTime)) ||
                startDateTime.isAtSameMomentAs(eventStartTime) ||
                endDateTime.isAtSameMomentAs(eventEndTime)) {
              return false; // El equipo no está disponible
            }
          }
        }
      }
    }
    return true; // El equipo está disponible
  }

  // Método para cargar equipos ocupados desde Firebase
  Future<void> _loadOccupiedTeams() async {
    try {
      _occupiedTeams = await _firebaseServices.getOccupiedTeams();
    } catch (e) {
      print("Error al cargar equipos ocupados: $e");
    }
  }

  // Método para guardar equipos ocupados en Firebase
  Future<void> _saveOccupiedTeams() async {
    try {
      await _firebaseServices.saveOccupiedTeams(_occupiedTeams);
    } catch (e) {
      print("Error al guardar equipos ocupados: $e");
    }
  }

  // Método para obtener todos los eventos de todos los usuarios (solo para admin)
  Future<void> fetchAllEventsForAdmin() async {
    try {
      final events = await _firebaseServices.getAllAdminEvents();
      _events = events;
      notifyListeners();
    } catch (e) {
      print("Error al obtener los eventos para el administrador: $e");
    }
  }
}
