import 'package:flutter/material.dart';

class ScheduleItem {
  final String id;            // 건당 id
  String title;               // 제목
  String? memo;               // 내용
  DateTime startDateTime;     // 시작일
  DateTime endDateTime;       // 종료일
  bool pinned;                // 상단 고정 여부
  bool isImportant;           // 중요 여부
  bool allDay;                // 종일 여부
  int colorValue;             // 일정 배경색상

  ScheduleItem({
    required this.id,
    required this.title,
    required this.memo,
    required this.startDateTime,
    required this.endDateTime,
    this.pinned = false,
    required this.isImportant,
    required this.allDay,
    required this.colorValue,
  });

  // // 특정 날짜(day)에 이 일정이 포함되는지 판단
  // // 예) start=7/9, end=7/11이면 7/10에도 true
  // bool occursOn(DateTime day) {
  //   final s = DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
  //   final e0 = endDateTime ?? startDateTime;
  //   final e = DateTime(e0.year, e0.month, e0.day);
  //   final d = DateTime(day.year, day.month, day.day);
  //   return (d.isAtSameMomentAs(s) || d.isAfter(s)) &&
  //       (d.isAtSameMomentAs(e) || d.isBefore(e));
  // }
  bool get isMultiDay {
    return startDateTime.year != endDateTime.year ||
        startDateTime.month != endDateTime.month ||
        startDateTime.day != endDateTime.day;
  }

  bool occursOn(DateTime day) {
    final target = DateTime(day.year, day.month, day.day);
    final start = DateTime(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day,
    );
    final end = DateTime(
      endDateTime.year,
      endDateTime.month,
      endDateTime.day,
    );

    return !target.isBefore(start) && !target.isAfter(end);
  }

  bool startsOn(DateTime day) {
    return startDateTime.year == day.year &&
        startDateTime.month == day.month &&
        startDateTime.day == day.day;
  }

  bool endsOn(DateTime day) {
    return endDateTime.year == day.year &&
        endDateTime.month == day.month &&
        endDateTime.day == day.day;
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    final categoryString = (json['category'] ?? '').toString();
    return ScheduleItem(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      memo: json['memo'] ?? '',
      startDateTime: DateTime.parse(json['startDateTime']),
      endDateTime: DateTime.parse(json['endDateTime']),
      isImportant: json['isImportant'] ?? false,
      pinned: json['pinned'] ?? false,
      allDay: json['allDay'] ?? false,
      colorValue: json['colorValue'] ?? Colors.grey.value,
    );
  }
}
