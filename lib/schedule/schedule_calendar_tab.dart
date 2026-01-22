import 'package:flutter/material.dart';
import 'schedule_controller.dart';
import 'schedule_model.dart';
import 'schedule_edit_page.dart';

// 달력 탭: 달력에서 날짜 선택 → 해당 날짜 일정만 아래 리스트로 노출
class ScheduleCalendarTab extends StatefulWidget {
  final ScheduleController controller;
  final ScheduleCategory filter;
  final VoidCallback onChanged;

  const ScheduleCalendarTab({
    super.key,
    required this.controller,
    required this.filter,
    required this.onChanged,
  });

  @override
  State<ScheduleCalendarTab> createState() => _ScheduleCalendarTabState();
}

class _ScheduleCalendarTabState extends State<ScheduleCalendarTab> {
  DateTime _focusedMonth = DateTime.now(); // 추가: 현재 보고 있는 달
  DateTime _selectedDay = DateTime.now();  // 기존 유지

  // 추가: 해당 날짜에 일정이 있는지(점 표시 여부)
  bool _hasEvent(DateTime day) {
    return widget.controller.eventsOn(day, widget.filter).isNotEmpty;
  }

  DateTime _firstDayOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
  int _daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

  void _prevMonth() {
    setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1));
  }

  void _nextMonth() {
    setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1));
  }

  // 추가: 해당 날짜에 "중요(important)" 일정이 하나라도 있는지
  bool _hasImportantEvent(DateTime day) {
    // final events = widget.controller.eventsOn(day, widget.filter);
    // 필터 무시하고 중요 여부만 확인하는 버전
    final events = widget.controller.eventsOn(day, ScheduleCategory.all);

    // 필터가 important가 아니더라도,
    // day에 important 일정이 있으면 true로 표시하고 싶으면 아래처럼 하면 됨.
    // (현재 filter가 all/important/etc에 따라 eventsOn 결과가 달라지므로,
    //  "항상 important를 표시"하고 싶으면 filter를 ScheduleCategory.all로 조회해야 함)
    return events.any((e) => e.category == ScheduleCategory.important);
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = _firstDayOfMonth(_focusedMonth);
    final daysCount = _daysInMonth(_focusedMonth);
    final startWeekday = firstDay.weekday % 7; // 일요일=0

    final events = widget.controller.eventsOn(_selectedDay, widget.filter);

    return Column(
      children: [
        // CalendarDatePicker(
        //   initialDate: _selectedDay,
        //   firstDate: DateTime(2000),
        //   lastDate: DateTime(2100),
        //   onDateChanged: (d) => setState(() => _selectedDay = d),
        // ),

        // 월 이동 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
              Expanded(
                child: Center(
                  child: Text(
                    '${_focusedMonth.year}.${_focusedMonth.month.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('일'), Text('월'), Text('화'), Text('수'),
              Text('목'), Text('금'), Text('토'),
            ],
          ),
        ),

        const SizedBox(height: 6),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.1,
          ),
          itemCount: startWeekday + daysCount,
          itemBuilder: (context, index) {
            if (index < startWeekday) return const SizedBox.shrink();

            final day = index - startWeekday + 1;
            final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);

            final selected =
                date.year == _selectedDay.year &&
                    date.month == _selectedDay.month &&
                    date.day == _selectedDay.day;

            final hasEvent = _hasEvent(date);
            final hasImportant = _hasImportantEvent(date);  // 추가
            final dotSize = hasImportant ? 7.0 : 6.0;       // 추가

            return GestureDetector(
              onTap: () => setState(() => _selectedDay = date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (hasEvent)
                      Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasImportant ? Colors.redAccent : Colors.grey, // 중요=빨강, 일반=회색
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),


        const Divider(height: 1),
        Expanded(
          child: events.isEmpty
              ? const Center(child: Text('선택한 날짜에 일정이 없습니다.'))
              : ListView.builder(
            itemCount: events.length,
            itemBuilder: (_, i) {
              final it = events[i];

              // 리스트 추가
              return ListTile(
                title: Text(it.title),
                subtitle: it.memo == null ? null : Text(it.memo!),
                onTap: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ScheduleEditPage(controller: widget.controller, item: it),
                    ),
                  );
                  if (changed == true) {
                    widget.onChanged();
                    setState(() {});
                  }
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    widget.controller.remove(it.id);
                    widget.onChanged();
                    setState(() {});
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
