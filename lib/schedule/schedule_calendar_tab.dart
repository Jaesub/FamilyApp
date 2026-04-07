import 'package:flutter/material.dart';
import 'schedule_controller.dart';
import 'schedule_model.dart';
import 'schedule_edit_page.dart';

class ScheduleCalendarTab extends StatefulWidget {
  final ScheduleController controller;
  final VoidCallback onChanged;

  const ScheduleCalendarTab({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<ScheduleCalendarTab> createState() => _ScheduleCalendarTabState();
}

class _ScheduleCalendarTabState extends State<ScheduleCalendarTab> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  static const double _dayNumberHeight = 22;
  static const double _slotHeight = 14;
  static const int _maxVisibleSlots = 3; // 일정 3줄 + 마지막 줄은 +N
  static const double _weekRowHeight =
      _dayNumberHeight + (_slotHeight * (_maxVisibleSlots + 1));

  DateTime _firstDayOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
  int _daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  List<ScheduleItem> _monthEvents() {
    return widget.controller.all;
  }

  List<ScheduleItem> _findEventsForDay(DateTime day) {
    final events = _monthEvents().where((e) => e.occursOn(day)).toList();

    events.sort((a, b) {
      final pinnedCompare = (b.pinned ? 1 : 0) - (a.pinned ? 1 : 0);
      if (pinnedCompare != 0) return pinnedCompare;

      final importantCompare = (b.isImportant ? 1 : 0) - (a.isImportant ? 1 : 0);
      if (importantCompare != 0) return importantCompare;

      return a.startDateTime.compareTo(b.startDateTime);
    });

    return events;
  }

  List<ScheduleItem> _singleDayEventsForDay(DateTime day) {
    return _findEventsForDay(day).where((e) => !e.isMultiDay).toList();
  }

  List<ScheduleItem> _multiDayEventsForWeek(List<DateTime> weekDays) {
    final weekStart = _dateOnly(weekDays.first);
    final weekEnd = _dateOnly(weekDays.last);

    return _monthEvents().where((e) {
      if (!e.isMultiDay) return false;

      final start = _dateOnly(e.startDateTime);
      final end = _dateOnly(e.endDateTime);

      return !end.isBefore(weekStart) && !start.isAfter(weekEnd);
    }).toList();
  }

  int _weekCount(DateTime month) {
    final firstDay = _firstDayOfMonth(month);
    final daysCount = _daysInMonth(month);
    final startWeekday = firstDay.weekday % 7;
    final totalCells = startWeekday + daysCount;
    return (totalCells / 7).ceil();
  }

  List<DateTime> _weekDays(int weekIndex) {
    final firstDay = _firstDayOfMonth(_focusedMonth);
    final startWeekday = firstDay.weekday % 7;
    final gridStart = firstDay.subtract(Duration(days: startWeekday));
    final start = gridStart.add(Duration(days: weekIndex * 7));

    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  bool _isCurrentMonth(DateTime d) {
    return d.year == _focusedMonth.year && d.month == _focusedMonth.month;
  }

  int _startIndexInWeek(ScheduleItem item, List<DateTime> weekDays) {
    for (int i = 0; i < weekDays.length; i++) {
      if (item.occursOn(weekDays[i])) return i;
    }
    return 0;
  }

  int _endIndexInWeek(ScheduleItem item, List<DateTime> weekDays) {
    for (int i = weekDays.length - 1; i >= 0; i--) {
      if (item.occursOn(weekDays[i])) return i;
    }
    return 6;
  }

  List<_PositionedSchedule> _assignLanes(List<ScheduleItem> items) {
    items.sort((a, b) {
      final c = a.startDateTime.compareTo(b.startDateTime);
      if (c != 0) return c;
      return a.endDateTime.compareTo(b.endDateTime);
    });

    final List<List<ScheduleItem>> lanes = [];
    final List<_PositionedSchedule> result = [];

    for (final item in items) {
      bool assigned = false;

      for (int lane = 0; lane < lanes.length; lane++) {
        final last = lanes[lane].last;

        final overlaps = !last.endDateTime.isBefore(item.startDateTime) &&
            !item.endDateTime.isBefore(last.startDateTime);

        if (!overlaps) {
          lanes[lane].add(item);
          result.add(_PositionedSchedule(item: item, lane: lane));
          assigned = true;
          break;
        }
      }

      if (!assigned) {
        lanes.add([item]);
        result.add(_PositionedSchedule(item: item, lane: lanes.length - 1));
      }
    }

    return result;
  }

  Widget _buildScheduleBar(
      ScheduleItem item, {
        required String text,
        required Color? color,
        VoidCallback? onTap,
      }) {
    final bar = Container(
      width: double.infinity,
      height: _slotHeight,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.zero,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
        ),
      ),
    );

    if (onTap == null) return bar;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.zero,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        onTap: onTap,
        child: bar,
      ),
    );
  }

  Widget _buildOverflowBar(int count) {
    return Container(
      width: double.infinity,
      height: _slotHeight,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.zero,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        '+$count',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.black87,
        ),
      ),
    );
  }

  Set<int> _occupiedLanesForDay(
      DateTime day,
      List<_PositionedSchedule> visiblePositioned,
      ) {
    final result = <int>{};

    for (final ps in visiblePositioned) {
      if (ps.item.occursOn(day)) {
        result.add(ps.lane);
      }
    }

    return result;
  }

  List<Widget> _buildSingleDayBarsForCell(
      DateTime day,
      List<_PositionedSchedule> visiblePositioned,
      ) {
    final singleEvents = _singleDayEventsForDay(day);
    final occupied = _occupiedLanesForDay(day, visiblePositioned);

    final bars = <Widget>[];
    int singleIndex = 0;

    for (int slot = 0; slot < _maxVisibleSlots; slot++) {
      if (occupied.contains(slot)) {
        bars.add(const SizedBox(
          height: _slotHeight,
          width: double.infinity,
        ));
        continue;
      }

      if (singleIndex < singleEvents.length) {
        final event = singleEvents[singleIndex];
        bars.add(

          _buildScheduleBar(
            event,
            text: event.title,
            color: Color(event.colorValue),
            // // 하루일정 클릭 이벤트
            // onTap: () async {
            //   final changed = await Navigator.of(context).push<bool>(
            //     MaterialPageRoute(
            //       builder: (_) => ScheduleEditPage(
            //         controller: widget.controller,
            //         item: event,
            //       ),
            //     ),
            //   );
            //
            //   if (changed == true) {
            //     widget.onChanged();
            //     setState(() {});
            //   }
            // },

            // 클릭 이벤트 없도록 수정
            onTap: null,
          ),
        );
        singleIndex++;
      } else {
        bars.add(const SizedBox(
          height: _slotHeight,
          width: double.infinity,
        ));
      }
    }

    final hiddenCount = singleEvents.length - singleIndex;

    if (hiddenCount > 0) {
      bars.add(_buildOverflowBar(hiddenCount));
    } else {
      bars.add(const SizedBox(
        height: _slotHeight,
        width: double.infinity,
      ));
    }

    return bars;
  }

  Widget _buildWeekRow(List<DateTime> weekDays) {
    final multi = _multiDayEventsForWeek(weekDays);
    final positioned = _assignLanes(multi);

    final visiblePositioned =
    positioned.where((e) => e.lane < _maxVisibleSlots).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 7;

        return SizedBox(
          height: _weekRowHeight,
          child: Stack(
            children: [
              Row(
                children: weekDays.map((date) {
                  final selected = _isSameDay(date, _selectedDay);
                  final isCurrentMonth = _isCurrentMonth(date);
                  final singleDayBars =
                  _buildSingleDayBarsForCell(date, visiblePositioned);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDay = date),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected
                              ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: _dayNumberHeight,
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: isCurrentMonth ? null : Colors.grey,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            ...singleDayBars,
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              ...visiblePositioned.map((ps) {
                final item = ps.item;
                final startIndex = _startIndexInWeek(item, weekDays);
                final endIndex = _endIndexInWeek(item, weekDays);
                final left = startIndex * cellWidth;
                final width = (endIndex - startIndex + 1) * cellWidth;
                final top = _dayNumberHeight + (ps.lane * _slotHeight);

                return Positioned(
                  left: left,
                  top: top,
                  width: width,
                  height: _slotHeight,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.zero,
                      splashColor: Colors.white24,
                      highlightColor: Colors.white10,
                      // 클릭시 수정페이지 가는 부분 ~ if(changed == true) 까지
                      // onTap: () async {
                      //   final changed = await Navigator.of(context).push<bool>(
                      //     MaterialPageRoute(
                      //       builder: (_) => ScheduleEditPage(
                      //         controller: widget.controller,
                      //         item: item,
                      //       ),
                      //     ),
                      //   );
                      //
                      //   if (changed == true) {
                      //     widget.onChanged();
                      //     setState(() {});
                      //   }
                      // },
                      // 수정탭으로 바로 가지 않도록 수적
                      onTap: null,

                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(item.colorValue),
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekCount = _weekCount(_focusedMonth);
    final events = widget.controller.eventsOn(_selectedDay);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_focusedMonth.year}.${_focusedMonth.month.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('일'),
              Text('월'),
              Text('화'),
              Text('수'),
              Text('목'),
              Text('금'),
              Text('토'),
            ],
          ),
        ),
        const SizedBox(height: 6),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: List.generate(
              weekCount,
                  (weekIndex) => _buildWeekRow(_weekDays(weekIndex)),
            ),
          ),
        ),

        const Divider(height: 1),

        Expanded(
          child: events.isEmpty
              ? const Center(child: Text('선택한 날짜에 일정이 없습니다.'))
              : ListView.builder(
            itemCount: events.length,
            itemBuilder: (_, i) {
              final it = events[i];
              final isImportant = it.isImportant;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isImportant
                      ? Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.06)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Icon(
                    isImportant ? Icons.star_rounded : Icons.event_note,
                    color: Color(it.colorValue),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          it.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isImportant
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (it.pinned) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.push_pin, size: 18),
                      ],
                    ],
                  ),
                  subtitle: it.memo == null
                      ? null
                      : Text(
                    it.memo!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isImportant)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Text(
                            '중요',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          widget.controller.remove(it.id);
                          widget.onChanged();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => ScheduleEditPage(
                          controller: widget.controller,
                          item: it,
                        ),
                      ),
                    );
                    if (changed == true) {
                      widget.onChanged();
                      setState(() {});
                    }
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

class _PositionedSchedule {
  final ScheduleItem item;
  final int lane;

  _PositionedSchedule({
    required this.item,
    required this.lane,
  });
}