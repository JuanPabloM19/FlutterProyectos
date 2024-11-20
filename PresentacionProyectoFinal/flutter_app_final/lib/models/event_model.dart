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
      'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
      'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
      'color': color.value, // Guardar como entero
      'userId': userId,
      'equipment': equipment,
      'data': data,
    };
  }

  // Método para convertir de Firestore a un Event
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    TimeOfDay parseTime(dynamic time) {
      if (time is Map<String, dynamic>) {
        // Asume que viene en formato {hour, minute}
        return TimeOfDay(hour: time['hour'], minute: time['minute']);
      } else if (time is String) {
        final parts = time.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } else {
        throw ArgumentError('Formato inválido para startTime o endTime');
      }
    }

    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: parseTime(data['startTime']),
      endTime: parseTime(data['endTime']),
      color: Color(int.tryParse(data['color'].toString()) ?? 0xFF000000),
      userId: data['userId'] ?? '',
      equipment: data['equipment'] ?? '',
      data: data['data'] ?? '',
    );
  }

  static Event fromJson(Map<String, dynamic> json) {
    TimeOfDay parseTime(dynamic time) {
      if (time is Map<String, dynamic>) {
        return TimeOfDay(hour: time['hour'], minute: time['minute']);
      } else if (time is String) {
        final parts = time.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } else {
        throw ArgumentError('Formato inválido para startTime o endTime');
      }
    }

    return Event(
      id: json['id'] ?? 'unknown',
      title: json['title'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: parseTime(json['startTime']),
      endTime: parseTime(json['endTime']),
      color: Color(json['color'] ?? 0xFF000000),
      userId: json['userId'] ?? '',
      equipment: json['equipment'] ?? '',
      data: json['data'] ?? '',
    );
  }

  static Event fromMap(Map<String, dynamic> map) {
    TimeOfDay parseTime(String time) {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Event(
      id: map['id'] ?? 'unknown',
      title: map['title'] ?? '',
      date: DateTime.parse(map['date']),
      startTime: parseTime(map['startTime'] ?? '00:00'),
      endTime: parseTime(map['endTime'] ?? '00:00'),
      color: Color(map['color'] ?? 0xFF000000),
      userId: map['userId'] ?? '',
      equipment: map['equipment'] ?? '',
      data: map['data'] ?? '',
    );
  }
}
