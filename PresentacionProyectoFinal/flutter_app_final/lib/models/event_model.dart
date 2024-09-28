import 'package:flutter/material.dart';

class Event {
  final String title;
  final Color color;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String equipment;
  final DateTime date; // Añadir la propiedad date

  Event({
    required this.title,
    required this.color,
    required this.startTime,
    required this.endTime,
    required this.equipment,
    required this.date, // Asignar date en el constructor
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'color': color.value,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'equipment': equipment,
      'date': date.toIso8601String(), // Añadir date al método toJson
    };
  }

  static Event fromJson(Map<String, dynamic> json) {
    final startTimeParts = json['startTime'].split(':');
    final endTimeParts = json['endTime'].split(':');

    return Event(
      title: json['title'],
      color: Color(json['color']),
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      equipment: json['equipment'],
      date: DateTime.parse(json['date']), // Añadir date en el método fromJson
    );
  }
}
