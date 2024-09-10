import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class EventProvider with ChangeNotifier {
  final Map<DateTime, List<Event>> _events = {};

  EventProvider() {
    _loadEvents();
  }

  List<Event> getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void addEvent(DateTime day, Event event) {
    if (_events[day] != null) {
      _events[day]!.add(event);
    } else {
      _events[day] = [event];
    }
    _saveEvents();
    notifyListeners();
  }

  void _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsMap = _events.map((key, value) {
      return MapEntry(key.toString(), value.map((e) => e.toJson()).toList());
    });
    prefs.setString('events', json.encode(eventsMap));
  }

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
      notifyListeners();
    }
  }
}
