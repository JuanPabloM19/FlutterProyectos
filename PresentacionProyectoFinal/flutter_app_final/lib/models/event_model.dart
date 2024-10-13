import 'package:flutter/material.dart';

class Event {
  String title;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  Color color;
  String userId;
  String equipment;
  String data; // Puedes agregar más información

  Event({
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.userId,
    required this.equipment,
    this.data = '',
  });

  Event copyWith({
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
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime.format(context),
      'endTime': endTime.format(context),
      'color': color.value,
      'userId': userId,
      'equipment': equipment,
      'data': data,
    };
  }

  static Event fromJson(Map<String, dynamic> json) {
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
      data: json['data'],
    );
  }

  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      title: map['title'],
      date: DateTime.parse(map['date']),
      startTime: TimeOfDay(
        hour: int.parse(map['startTime'].split(':')[0]),
        minute: int.parse(map['startTime'].split(':')[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(map['endTime'].split(':')[0]),
        minute: int.parse(map['endTime'].split(':')[1]),
      ),
      color: Color(map['color']),
      userId: map['userId'],
      equipment: map['equipment'],
      data: map['data'],
    );
  }
}
