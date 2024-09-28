import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class EventProvider with ChangeNotifier {
  final Map<DateTime, List<Event>> _events = {};

  EventProvider() {
    _loadEvents();
  }

  // Método para obtener eventos de un día específico
  List<Event> getEventsForDay(DateTime day) {
    DateTime dateOnly = DateTime(day.year, day.month, day.day);
    return _events[dateOnly] ?? [];
  }

  // Método para agregar un evento
  void addEvent(DateTime day, Event event) {
    DateTime dateOnly = DateTime(day.year, day.month, day.day);

    if (_events[dateOnly] != null) {
      _events[dateOnly]!.add(event);
    } else {
      _events[dateOnly] = [event];
    }
    _saveEvents(); // Guardar eventos en SharedPreferences
    notifyListeners(); // Notificar a los listeners para que se actualicen
  }

  // Método para guardar eventos en SharedPreferences
  void _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsMap = _events.map((key, value) {
      return MapEntry(key.toString(), value.map((e) => e.toJson()).toList());
    });
    prefs.setString('events', json.encode(eventsMap));
  }

  // Método para cargar eventos de SharedPreferences
  void _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString('events');
    if (eventsString != null) {
      final Map<String, dynamic> decodedEvents = json.decode(eventsString);
      decodedEvents.forEach((key, value) {
        final DateTime date = DateTime.parse(key);
        final List<Event> eventsList = List<Event>.from(
          value.map((e) => Event.fromJson(e)),
        );
        _events[date] = eventsList;
      });
      notifyListeners(); // Notificar a los listeners después de cargar
    }
  }

  // Método público para cargar eventos
  void loadEvents() {
    _loadEvents();
  }
}
