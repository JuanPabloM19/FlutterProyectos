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

  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.parse(json['date']).toLocal();

    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: parsedDate,
      startTime: Event.parseTime(json['startTime']),
      endTime: Event.parseTime(json['endTime']),
      color: Color(int.tryParse(json['color']?.toString() ?? '0xFF000000') ??
          0xFF000000),
      userId: json['userId'] ?? '',
      equipment: json['equipment'] ?? '',
      data: json['data'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
      'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
      'color': color.value,
      'userId': userId,
      'equipment': equipment,
      'data': data,
    };
  }

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime eventDate =
        Event.dateFromFirebase(data['date']); // Esto está correcto
    final startTime = Event.parseTime(data['startTime']);
    final endTime = Event.parseTime(data['endTime']);
    int colorValue =
        int.tryParse(data['color']?.toString() ?? '0xFF000000') ?? 0xFF000000;

    return Event(
      id: data['id'] ?? doc.id, // Usa el id del documento si no tiene id
      title: data['title'] ?? '',
      date: eventDate,
      startTime: startTime,
      endTime: endTime,
      color: Color(colorValue),
      userId: data['userId'] ?? '',
      equipment: data['equipment'] ?? '',
      data: data['data'] ?? '',
    );
  }

  static TimeOfDay parseTime(dynamic time) {
    if (time is Map<String, dynamic>) {
      return TimeOfDay(hour: time['hour'], minute: time['minute']);
    } else if (time is String) {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } else {
      throw ArgumentError('Formato inválido para startTime o endTime');
    }
  }

  static DateTime dateFromFirebase(dynamic date) {
    if (date is Timestamp) {
      return date.toDate().toUtc();
    } else if (date is String) {
      return DateTime.parse(date).toUtc();
    } else if (date is DateTime) {
      return date.toUtc();
    } else {
      throw ArgumentError('Formato de fecha no reconocido: $date');
    }
  }

  static Event fromMap(Map<String, dynamic> map) {
    final startTime = parseTime(map['startTime']);
    final endTime = parseTime(map['endTime']);
    final eventDate = DateTime.parse(map['date']).toUtc();

    return Event(
      id: map['id'] ?? 'unknown',
      title: map['title'] ?? '',
      date: eventDate,
      startTime: startTime,
      endTime: endTime,
      color: Color(map['color'] ?? 0xFF000000),
      userId: map['userId'] ?? '',
      equipment: map['equipment'] ?? '',
      data: map['data'] ?? '',
    );
  }
}
