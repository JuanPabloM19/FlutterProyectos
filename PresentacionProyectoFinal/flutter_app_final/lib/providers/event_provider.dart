import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';

class EventProvider with ChangeNotifier {
  final Map<String, Map<DateTime, List<Event>>> _userEvents = {};
  Map<DateTime, List<String>> _occupiedTeams = {};
  List<Event> _events = [];

  final FirebaseServices _firebaseServices = FirebaseServices();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EventProvider() {
    loadEvents(); // Cargar eventos al inicializar
    _loadOccupiedTeams(); // Cargar equipos ocupados al inicializar
  }

  // Método para obtener todos los eventos de Firebase
// Método para obtener todos los eventos de Firebase
  Future<List<Event>> fetchEvents() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('Usuario no autenticado.');
      }

      final events = await _firebaseServices.getAllEvents(userId);
      _events = events; // Almacenamos los eventos en la lista _events
      notifyListeners(); // Notificamos a los listeners (UI) que los eventos han cambiado
      return events;
    } catch (e) {
      print("Error al obtener eventos: $e");
      return [];
    }
  }

  Future<List<Event>> getEventsForDay(DateTime day, String userId) async {
    try {
      // Obtiene todos los eventos del usuario desde FirebaseServices
      List<Event> allEvents = await _firebaseServices.getAllEvents(userId);

      // Filtra los eventos para el día especificado
      List<Event> eventsForDay = allEvents.where((event) {
        return isSameDay(event.date, day); // Usa isSameDay para comparar fechas
      }).toList();

      return eventsForDay;
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

  // Obtener todos los eventos para un día específico, independientemente del usuario
  Future<List<Event>> getAllEventsForDay(DateTime day) async {
    List<Event> allEventsForDay = [];
    final allEvents = await fetchEvents(); // Obtener todos los eventos

    for (var event in allEvents) {
      if (isSameDay(event.date, day)) {
        allEventsForDay.add(event);
      }
    }
    return allEventsForDay;
  }

  // Editar un evento
  Future<void> editEvent(
      BuildContext context, Event event, Event updatedEvent) async {
    try {
      await _firebaseServices.updateEvent(event, updatedEvent, context);
      // Actualizar eventos en local si es necesario
      notifyListeners();
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

  // Método para eliminar un evento
  Future<void> deleteEvent(
      BuildContext context, DateTime date, Event event) async {
    final userId = event.userId;
    DateTime dateOnly = DateTime(date.year, date.month, date.day);

    if (_userEvents[userId] != null && _userEvents[userId]![dateOnly] != null) {
      _userEvents[userId]![dateOnly]!.remove(event);

      if (_userEvents[userId]![dateOnly]!.isEmpty) {
        _userEvents[userId]!.remove(dateOnly);
      }

      // Liberar el equipo ocupado
      if (_occupiedTeams[dateOnly] != null) {
        _occupiedTeams[dateOnly]!.remove(event.equipment);
        if (_occupiedTeams[dateOnly]!.isEmpty) {
          _occupiedTeams.remove(dateOnly);
        }
      }

      // Guardar los cambios en Firebase
      await _firebaseServices.deleteEvent(userId, event);
      _saveOccupiedTeams();
      notifyListeners();
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

      final events = await fetchEvents();
      _userEvents.clear();

      for (var event in events) {
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
}
