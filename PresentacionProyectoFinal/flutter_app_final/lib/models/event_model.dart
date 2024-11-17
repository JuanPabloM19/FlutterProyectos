import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Event {
  String id;
  String title;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  Color color;
  String userId;
  String equipment;
  String data;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.userId,
    required this.equipment,
    this.data = '',
  }) {
    if (title.isEmpty || userId.isEmpty || equipment.isEmpty) {
      throw ArgumentError('Campos requeridos no pueden estar vacíos.');
    }
  }

  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Color? color,
    String? userId,
    String? equipment,
    String? data,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      equipment: equipment ?? this.equipment,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson(BuildContext context) {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime.format(context),
      'endTime': endTime.format(context),
      'color': color.value, // Convierte Color a entero
      'userId': userId,
      'equipment': equipment,
      'data': data,
    };
  }

  // Método para convertir de Firestore a un Event
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'],
      date: (data['date'] as Timestamp).toDate(),
      startTime:
          TimeOfDay.fromDateTime((data['startTime'] as Timestamp).toDate()),
      endTime: TimeOfDay.fromDateTime((data['endTime'] as Timestamp).toDate()),
      color: Color(int.parse(data['color'])),
      userId: data['userId'],
      equipment: data['equipment'],
      data: data['data'],
    );
  }

  static Event fromJson(Map<String, dynamic> json) {
    if (json['title'] == null ||
        json['userId'] == null ||
        json['equipment'] == null) {
      throw ArgumentError('Faltan campos obligatorios en el JSON.');
    }

    final startTimeParts = (json['startTime'] ?? '00:00').split(':');
    final endTimeParts = (json['endTime'] ?? '00:00').split(':');

    return Event(
      id: json['id'] ?? 'unknown',
      title: json['title'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      color: Color(json['color']),
      userId: json['userId'],
      equipment: json['equipment'],
      data: json['data'] ?? '',
    );
  }

  static Event fromMap(Map<String, dynamic> map) {
    final startTimeParts = (map['startTime'] ?? '00:00').split(':');
    final endTimeParts = (map['endTime'] ?? '00:00').split(':');

    return Event(
      id: map['id'] ?? 'unknown',
      title: map['title'],
      date: DateTime.parse(map['date']),
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      color: Color(map['color']),
      userId: map['userId'],
      equipment: map['equipment'],
      data: map['data'] ?? '',
    );
  }
}
