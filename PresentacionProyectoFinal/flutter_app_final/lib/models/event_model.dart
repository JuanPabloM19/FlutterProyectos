import 'dart:convert';
import 'package:flutter/material.dart';

class Event {
  String title;
  DateTime date; // Cambiado a DateTime
  TimeOfDay startTime;
  TimeOfDay endTime;
  Color color;
  String userId;
  String equipment;
  final String data; // Campo adicional

  Event({
    required this.title,
    required this.date, // Asegúrate de pasar un DateTime
    required this.startTime,
    required this.endTime,
    required this.color,
    this.userId = '',
    this.equipment = '',
    required this.data, // Requerido
  });

  String toJson() {
    return jsonEncode({
      'title': title,
      'date': date.toIso8601String(), // Asegúrate de convertir a string
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'color': color.value,
      'userId': userId,
      'equipment': equipment,
      'data': data, // Incluye 'data'
    });
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
          hour: int.parse(json['startTime'].split(':')[0]),
          minute: int.parse(json['startTime'].split(':')[1])),
      endTime: TimeOfDay(
          hour: int.parse(json['endTime'].split(':')[0]),
          minute: int.parse(json['endTime'].split(':')[1])),
      color: Color(json['color']),
      userId: json['userId'],
      equipment: json['equipment'],
      data: json['data'], // Incluye 'data'
    );
  }
}
