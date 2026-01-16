import 'dart:math';
import 'schedule_model.dart';

// 일정 데이터를 관리하는 컨트롤러(메모리 저장)
// - 실제 API/DB 붙일 때 여기 로직을 Repository로 옮기면 됨
class ScheduleController {
  final List<ScheduleItem> _items = [
    ScheduleItem(
      id: '1',
      title: '이다진 생일',
      memo: '상단 고정, 중요표시, 숨기기 등',
      start: DateTime(2025, 7, 9),
      category: ScheduleCategory.important,
      pinned: true,
    ),
    ScheduleItem(
      id: '2',
      title: '여행',
      start: DateTime(2025, 7, 9),
      end: DateTime(2025, 7, 11),
      category: ScheduleCategory.etc,
    ),
    ScheduleItem(
      id: '3',
      title: '이다진 결혼식',
      memo: '메모',
      start: DateTime(2025, 8, 1),
      category: ScheduleCategory.important,
    ),
  ];

  List<ScheduleItem> get all => List.unmodifiable(_items);

  // 카테고리 필터 적용
  List<ScheduleItem> filtered(ScheduleCategory filter) {
    if (filter == ScheduleCategory.all) return all;
    return all.where((e) => e.category == filter).toList();
  }

  // 특정 날짜에 해당하는 일정만 추출
  List<ScheduleItem> eventsOn(DateTime day, ScheduleCategory filter) {
    return filtered(filter).where((e) => e.occursOn(day)).toList();
  }

  // 일정 추가
  ScheduleItem add({
    required String title,
    String? memo,
    required DateTime start,
    DateTime? end,
    required ScheduleCategory category,
    required bool pinned,
  }) {
    final id = '${Random().nextInt(99999999)}';
    final item = ScheduleItem(
      id: id,
      title: title,
      memo: memo,
      start: start,
      end: end,
      category: category,
      pinned: pinned,
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
    DateTime? end,
    required ScheduleCategory category,
    required bool pinned,
  }) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return;

    final item = _items[idx];
    item.title = title;
    item.memo = (memo != null && memo.trim().isEmpty) ? null : memo;
    item.start = start;
    item.end = end;
    item.category = category;
    item.pinned = pinned;
  }

  // 빠른 추가(임시): 선택한 날짜에 "새 일정" 1개 추가
  void addQuick({required DateTime day}) {
    final id = '${Random().nextInt(99999999)}';
    _items.add(ScheduleItem(
      id: id,
      title: '새 일정',
      start: DateTime(day.year, day.month, day.day),
      category: ScheduleCategory.etc,
    ));
  }

  // 삭제
  void remove(String id) => _items.removeWhere((e) => e.id == id);
}
