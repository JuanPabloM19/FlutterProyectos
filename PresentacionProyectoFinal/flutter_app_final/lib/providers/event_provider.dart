import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class EventProvider with ChangeNotifier {
  final Map<String, Map<DateTime, List<Event>>> _userEvents =
      {}; // Eventos por usuario

  EventProvider() {
    _loadEvents();
  }

  // Obtener eventos de un día específico para el usuario logueado
  List<Event> getEventsForDay(DateTime day, String userId) {
    DateTime dateOnly = DateTime(day.year, day.month, day.day);
    if (_userEvents[userId] != null && _userEvents[userId]![dateOnly] != null) {
      return _userEvents[userId]![dateOnly]!;
    }
    return [];
  }

  // Método para agregar un evento para el usuario logueado
  void addEvent(Event event) {
    final userId = event.userId;
    final dateOnly =
        DateTime(event.date.year, event.date.month, event.date.day);

    if (_userEvents[userId] == null) {
      _userEvents[userId] = {};
    }

    if (_userEvents[userId]![dateOnly] == null) {
      _userEvents[userId]![dateOnly] = [];
    }

    _userEvents[userId]![dateOnly]!.add(event);

    // Guardar los eventos en SharedPreferences
    _saveEvents(userId);
    notifyListeners();
  }

  // Método para eliminar un evento
  void deleteEvent(DateTime date, Event event) {
    final userId = event.userId;
    DateTime dateOnly = DateTime(date.year, date.month, date.day);
    if (_userEvents[userId] != null && _userEvents[userId]![dateOnly] != null) {
      _userEvents[userId]![dateOnly]!.remove(event);
      if (_userEvents[userId]![dateOnly]!.isEmpty) {
        _userEvents[userId]!.remove(dateOnly);
      }
      _saveEvents(userId);
      notifyListeners();
    }
  }

  // Método para editar un evento
  void editEvent(
      DateTime oldDate, Event oldEvent, DateTime newDate, Event newEvent) {
    deleteEvent(oldDate, oldEvent);
    // Asegúrate de que el newEvent tenga la fecha correcta
    newEvent.date = newDate; // Actualiza la fecha del evento
    addEvent(newEvent); // Llama a addEvent solo con newEvent
  }

  // Método para guardar eventos en SharedPreferences
  void _saveEvents(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> eventsMap = {};

    _userEvents[userId]?.forEach((key, value) {
      eventsMap[key.toIso8601String()] = value
          .map((e) => jsonDecode(e.toJson()))
          .toList(); // Cambiado a jsonDecode
    });

    await prefs.setString('events_$userId', jsonEncode(eventsMap));
  }

  // Método para cargar eventos de SharedPreferences
  void _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      String? eventsJson = prefs.getString('events_$userId');
      if (eventsJson != null) {
        Map<String, dynamic> eventsMap = jsonDecode(eventsJson);
        _userEvents[userId] = {};

        eventsMap.forEach((key, value) {
          DateTime date = DateTime.parse(key);
          _userEvents[userId]![date] =
              (value as List).map((e) => Event.fromJson(e)).toList();
        });
      }
    }
  }

  // Método público para cargar eventos
  void loadEvents() {
    _loadEvents();
    notifyListeners();
  }
}
