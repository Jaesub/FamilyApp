enum ScheduleCategory { all, important, etc }

class ScheduleItem {
  final String id;            // 건당 id
  String title;               // 제목
  String? memo;               // 내용
  DateTime start;             // 시작일
  DateTime? end;              // 종료일
  bool pinned;                // 상단 고정 여부
  ScheduleCategory category;  // 중요/기타 같은 분류

  ScheduleItem({
    required this.id,
    required this.title,
    this.memo,
    required this.start,
    this.end,
    this.pinned = false,
    this.category = ScheduleCategory.etc,
  });

  // 특정 날짜(day)에 이 일정이 포함되는지 판단
  // 예) start=7/9, end=7/11이면 7/10에도 true
  bool occursOn(DateTime day) {
    final s = DateTime(start.year, start.month, start.day);
    final e0 = end ?? start;
    final e = DateTime(e0.year, e0.month, e0.day);
    final d = DateTime(day.year, day.month, day.day);
    return (d.isAtSameMomentAs(s) || d.isAfter(s)) &&
        (d.isAtSameMomentAs(e) || d.isBefore(e));
  }
}
