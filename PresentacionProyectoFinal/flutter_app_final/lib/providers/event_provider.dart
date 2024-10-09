import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/utils/databaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';

class EventProvider with ChangeNotifier {
  final Map<String, Map<DateTime, List<Event>>> _userEvents = {};
  final Map<DateTime, List<String>> _occupiedTeams =
      {}; // Equipos ocupados por fecha

  EventProvider() {
    _loadEvents(); // Cargar eventos al inicializar
    _loadOccupiedTeams(); // Cargar equipos ocupados al inicializar
  }

  // Obtener eventos de un día específico para el usuario logueado
  List<Event> getEventsForDay(DateTime day, String userId) {
    DateTime dateOnly = DateTime(day.year, day.month, day.day);
    return _userEvents[userId]?[dateOnly] ?? [];
  }

  // Obtener todos los eventos para un día específico
// Obtener todos los eventos para un día específico
  List<Event> getAllEventsForDay(DateTime day) {
    List<Event> allEventsForDay = [];
    List<Event> allEvents = getAlEvents(); // Obtener todos los eventos

    for (var event in allEvents) {
      if (isSameDay(event.date, day)) {
        allEventsForDay.add(event);
      }
    }

    return allEventsForDay;
  }

  List<Event> get events {
    List<Event> allEvents = [];
    _userEvents.forEach((userId, userEventMap) {
      userEventMap.forEach((date, eventList) {
        allEvents.addAll(eventList);
      });
    });
    return allEvents;
  }

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

    // Verificar si el equipo está reservado en ese rango de tiempo
    for (var userEvents in _userEvents.values) {
      if (userEvents[selectedDate] != null) {
        for (var event in userEvents[selectedDate]!) {
          if (event.equipment == equipmentName &&
              ((startDateTime.isBefore(event.endTime as DateTime) &&
                      endDateTime.isAfter(event.startTime as DateTime)) ||
                  (startDateTime
                          .isAtSameMomentAs(event.startTime as DateTime) ||
                      endDateTime
                          .isAtSameMomentAs(event.endTime as DateTime)))) {
            return false; // El equipo no está disponible
          }
        }
      }
    }
    return true; // El equipo está disponible
  }

  // Método para agregar un evento para el usuario logueado
  void addEvent(BuildContext context, Event event) {
    final userId = event.userId;
    final dateOnly =
        DateTime(event.date.year, event.date.month, event.date.day);

    // Verificar si el equipo está disponible
    if (!isTeamAvailable(
        event.equipment, dateOnly, event.startTime, event.endTime)) {
      throw Exception(
          'El equipo ya está reservado por otro usuario para esta fecha.');
    }

    if (_userEvents[userId] == null) {
      _userEvents[userId] = {};
    }

    if (_userEvents[userId]![dateOnly] == null) {
      _userEvents[userId]![dateOnly] = [];
    }

    _userEvents[userId]![dateOnly]!.add(event);

    // Actualizar equipos ocupados
    _occupiedTeams.update(dateOnly, (teams) {
      teams.add(event.equipment);
      return teams;
    }, ifAbsent: () => [event.equipment]);

    // Guardar eventos y equipos ocupados
    _saveEvents(context, userId);
    _saveOccupiedTeams();
    notifyListeners();
  }

  // Método para eliminar un evento
  void deleteEvent(BuildContext context, DateTime date, Event event) {
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

      // Guardar eventos y equipos ocupados
      _saveEvents(context, userId);
      _saveOccupiedTeams();
      notifyListeners();
    }
  }

  // Método para editar un evento
  void editEvent(BuildContext context, DateTime oldDate, Event oldEvent,
      DateTime newDate, Event newEvent) {
    deleteEvent(context, oldDate, oldEvent); // Eliminar evento anterior
    newEvent.date = newDate; // Actualizar la fecha del nuevo evento
    addEvent(context, newEvent); // Agregar el nuevo evento
  }

  // Método para cargar eventos desde SharedPreferences
  Future<void> fetchEvents() async {
    await _loadEvents();
    await _loadOccupiedTeams(); // Asegurarse de cargar también los equipos ocupados
    notifyListeners();
  }

  // Método para guardar eventos en SharedPreferences
  Future<void> _saveEvents(BuildContext context, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> eventsMap = {};

    _userEvents[userId]?.forEach((key, value) {
      eventsMap[key.toIso8601String()] = value
          .map((e) => e.toJson(context)) // Aquí pasamos el context
          .toList();
    });

    await prefs.setString('events_$userId', jsonEncode(eventsMap));
  }

  // Método para cargar eventos desde SharedPreferences
  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();

    _userEvents.clear(); // Limpiar eventos previos para evitar duplicados

    final keys =
        prefs.getKeys(); // Obtener todas las claves de SharedPreferences
    for (String key in keys) {
      if (key.startsWith('events_')) {
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          final userId = key.split('_')[1];
          Map<String, dynamic> jsonData = json.decode(jsonString);
          _userEvents[userId] = {};
          jsonData.forEach((dateKey, eventList) {
            DateTime date = DateTime.parse(dateKey);
            _userEvents[userId]![date] =
                (eventList as List).map((e) => Event.fromJson(e)).toList();
          });
        }
      }
    }
  }

  // Método para guardar equipos ocupados en SharedPreferences
  Future<void> _saveOccupiedTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, List<String>> occupiedMap = {};

    _occupiedTeams.forEach((key, value) {
      occupiedMap[key.toIso8601String()] = value;
    });

    await prefs.setString('occupied_teams', jsonEncode(occupiedMap));
  }

  // Método para cargar equipos ocupados desde SharedPreferences
  Future<void> _loadOccupiedTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('occupied_teams');

    if (jsonString != null) {
      Map<String, dynamic> jsonData = json.decode(jsonString);
      _occupiedTeams.clear();
      jsonData.forEach((key, value) {
        _occupiedTeams[DateTime.parse(key)] =
            (value as List).map((e) => e.toString()).toList();
      });
    }
  }

  // Método para liberar equipo en un día específico
  void freeEquipment(int equipmentId, DateTime date) {
    final occupiedTeams = _occupiedTeams[date];
    if (occupiedTeams != null) {
      occupiedTeams
          .removeWhere((equipment) => equipment == equipmentId.toString());
      if (occupiedTeams.isEmpty) {
        _occupiedTeams.remove(date);
      }

      _saveOccupiedTeams(); // Guardar cambios en los equipos ocupados
    }
  }

  // Método público para cargar eventos
  Future<void> loadEvents() async {
    await _loadEvents(); // Asegúrate de esperar a que se carguen los eventos
    await _loadOccupiedTeams(); // También cargar equipos ocupados
    notifyListeners();
  }

  Future<List<Event>> getAllEvents() async {
    final List<Map<String, dynamic>> data =
        await DatabaseHelper().getAllReservations();
    return data
        .map((eventMap) => Event.fromJson(eventMap))
        .toList(); // Asegúrate de que el método sea fromJson
  }

  // Obtener todos los eventos
// Obtener todos los eventos
  List<Event> getAlEvents() {
    List<Event> allEvents = [];
    _userEvents.forEach((userId, userEventMap) {
      userEventMap.forEach((date, eventList) {
        allEvents.addAll(eventList);
      });
    });
    return allEvents;
  }
}
