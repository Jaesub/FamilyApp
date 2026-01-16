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
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final events = widget.controller.eventsOn(_selectedDay, widget.filter);

    return Column(
      children: [
        CalendarDatePicker(
          initialDate: _selectedDay,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          onDateChanged: (d) => setState(() => _selectedDay = d),
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
