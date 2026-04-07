import 'dart:math';
import 'schedule_model.dart';
import 'package:flutter/material.dart';

// 일정 데이터를 관리하는 컨트롤러(메모리 저장)
// - 실제 API/DB 붙일 때 여기 로직을 Repository로 옮기면 됨
class ScheduleController {
  final List<ScheduleItem> _items = [
    ScheduleItem(
      id: '1',
      title: '이다진 생일',
      memo: '상단 고정, 중요표시, 숨기기 등',
      startDateTime: DateTime(2026, 7, 9),
      endDateTime: DateTime(2026, 7, 9),
      pinned: true,
      isImportant: false,
      allDay: true,
      colorValue: Colors.blueGrey.value,
    ),
    ScheduleItem(
      id: '2',
      title: '여행',
      memo: '',
      startDateTime: DateTime(2026, 4, 9),
      endDateTime: DateTime(2026, 4, 11),
      pinned: false,
      isImportant: false,
      allDay: true,
      colorValue: Colors.amber.value,
    ),
    ScheduleItem(
      id: '3',
      title: '결혼식',
      memo: '메모',
      startDateTime: DateTime(2026, 8, 1),
      endDateTime: DateTime(2026, 8, 1),
      pinned: false,
      isImportant: false,
      allDay: true,
      colorValue: Colors.limeAccent.value,
    ),
  ];

  List<ScheduleItem> get all => List.unmodifiable(_items);

  // 특정 날짜에 해당하는 일정만 추출 >>> 색상 넣으면서 전체로 변경
  List<ScheduleItem> eventsOn(DateTime day) {
    return all.where((e) => e.occursOn(day)).toList();
  }

  // 일정 추가
  ScheduleItem add({
    required String title,
    String? memo,
    required DateTime start,
    required DateTime end,
    required bool pinned,
    required bool isImportant,
    required bool allDay,
    required int colorValue,

  }) {
    final id = '${Random().nextInt(99999999)}';
    final item = ScheduleItem(
      id: id,
      title: title,
      memo: (memo != null && memo.trim().isEmpty) ? null : memo,
      startDateTime: start,
      endDateTime: end,
      pinned: pinned,
      isImportant: isImportant,
      allDay: allDay,
      colorValue: colorValue,
    );
    _items.add(item);
    return item;
  }

  // 일정 수정 (id로 찾아 업데이트)
  void update({
    required String id,
    required String title,
    String? memo,
    required DateTime start,
    required DateTime end,
    required bool pinned,
    required bool isImportant,
    required bool allDay,
    required int colorValue,
  }) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return;

    final item = _items[idx];
    item.title = title;
    item.memo = (memo != null && memo.trim().isEmpty) ? null : memo;
    item.startDateTime = start;
    item.endDateTime = end;
    item.pinned = pinned;
    item.isImportant = isImportant;
    item.allDay = allDay;
    item.colorValue = colorValue;
  }

  // 삭제
  void remove(String id) => _items.removeWhere((e) => e.id == id);
}
