import 'package:flutter/material.dart';

class Event {
  final String title;
  final Color color;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String equipment;

  Event({
    required this.title,
    required this.color,
    required this.startTime,
    required this.endTime,
    required this.equipment,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'color': color.value,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'equipment': equipment,
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
    );
  }
}
