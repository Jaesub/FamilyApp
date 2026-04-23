import 'package:flutter/material.dart';
import 'schedule_controller.dart';
import 'schedule_model.dart';

class ScheduleEditPage extends StatefulWidget {
  final ScheduleController controller;

  // edit 모드면 item이 들어오고, add 모드면 null
  final ScheduleItem? item;

  // 추가 모드에서 시작 날짜를 미리 지정하고 싶을 때
  final DateTime? initialDay;

  const ScheduleEditPage({
    super.key,
    required this.controller,
    this.item,
    this.initialDay,
  });

  @override
  State<ScheduleEditPage> createState() => _ScheduleEditPageState();
}

class _ScheduleEditPageState extends State<ScheduleEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtr;
  late final TextEditingController _memoCtr;

  late DateTime _startDate;
  late DateTime _endDate;

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  bool _pinned = false;
  bool _isImportant = false;
  bool _allDay = true;
  late int _colorValue;

  final List<Color> _presetColors = [
    Colors.grey,
    Colors.redAccent,
    Colors.orange,
    Colors.green,
    Colors.blueAccent,
    Colors.purple,
    Colors.teal,
  ];

  bool get _isEdit => widget.item != null;

  bool get _isMultiDay {
    return _startDate.year != _endDate.year ||
        _startDate.month != _endDate.month ||
        _startDate.day != _endDate.day;
  }

  @override
  void initState() {
    super.initState();

    final it = widget.item;
    _titleCtr = TextEditingController(text: it?.title ?? '');
    _memoCtr = TextEditingController(text: it?.memo ?? '');

    final baseDay = widget.initialDay ?? DateTime.now();

    final start = it?.startDateTime ??
        DateTime(baseDay.year, baseDay.month, baseDay.day, 0, 0);
    final end = it?.endDateTime ??
        DateTime(baseDay.year, baseDay.month, baseDay.day, 23, 59, 59);

    _startDate = DateTime(start.year, start.month, start.day);
    _endDate = DateTime(end.year, end.month, end.day);

    _startTime = TimeOfDay(hour: start.hour, minute: start.minute);
    _endTime = TimeOfDay(hour: end.hour, minute: end.minute);

    _pinned = it?.pinned ?? false;
    _isImportant = it?.isImportant ?? false;
    _allDay = it?.allDay ?? true;
    _colorValue = it?.colorValue ?? Colors.grey.value;
  }

  @override
  void dispose() {
    _titleCtr.dispose();
    _memoCtr.dispose();
    super.dispose();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  String _two(int n) => n.toString().padLeft(2, '0');
  String _fmtDate(DateTime d) => '${d.year}.${_two(d.month)}.${_two(d.day)}';
  String _fmtTime(TimeOfDay t) =>
      '${_two(t.hour)}:${_two(t.minute)}';

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _startDate = _normalize(picked);

      // 종료일이 시작일보다 이전이면 종료일 제거
      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      _endDate = _normalize(picked);
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked == null) return;

    setState(() {
      _startTime = picked;
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked == null) return;

    setState(() {
      _endTime = picked;
    });
  }

  void _setSingleDay() {
    setState(() {
      _endDate = _startDate;
    });
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtr.text.trim();
    final memo = _memoCtr.text;

    late final DateTime finalStart;
    late final DateTime finalEnd;

    if (_allDay) {
      finalStart = DateTime(_startDate.year, _startDate.month, _startDate.day, 0, 0, 0);
      finalEnd = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
    } else {
      finalStart = _combineDateAndTime(_startDate, _startTime);
      finalEnd = _combineDateAndTime(_endDate, _endTime);
    }

    if (_isEdit) {
      widget.controller.update(
        id: widget.item!.id,
        title: title,
        memo: memo,
        start: finalStart,
        end: finalEnd,
        pinned: _pinned,
        isImportant: _isImportant,
        allDay: _allDay,
        colorValue: _colorValue,
      );
    } else {
      widget.controller.add(
        title: title,
        memo: memo,
        start: finalStart,
        end: finalEnd,
        pinned: _pinned,
        isImportant: _isImportant,
        allDay: _allDay,
        colorValue: _colorValue,
      );
    }

    Navigator.pop(context, true); // ✅ 저장 성공 표시
  }

  void _delete() {
    if (!_isEdit) return;
    widget.controller.remove(widget.item!.id);
    Navigator.pop(context, true); // ✅ 삭제 성공 표시
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '일정 수정' : '일정 추가'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('삭제할까요?'),
                    content: const Text('이 일정을 삭제하면 복구할 수 없습니다.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
                    ],
                  ),
                );
                if (ok == true && mounted)
                  _delete();
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleCtr,
                      decoration: const InputDecoration(
                        labelText: '제목',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return '제목을 입력하세요.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _memoCtr,
                      decoration: const InputDecoration(
                        labelText: '메모',
                        prefixIcon: Icon(Icons.notes),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('중요일정'),
                      subtitle: const Text('리스트에서 강조 표시됩니다.'),
                      value: _isImportant,
                      onChanged: (v) => setState(() => _isImportant = v),
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('종일'),
                      subtitle: const Text('종일 일정이면 시간을 입력하지 않습니다.'),
                      value: _allDay,
                      onChanged: (v) {
                        setState(() {
                          _allDay = v;
                        });
                      },
                    ),

                    const Divider(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickStartDate,
                            icon: const Icon(Icons.event),
                            label: Text('시작: ${_fmtDate(_startDate)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickEndDate,
                            icon: const Icon(Icons.event_available),
                            label: Text('종료: ${_fmtDate(_endDate)}'),
                          ),
                        ),
                      ],
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isMultiDay ? _setSingleDay : null,
                        child: const Text('하루 일정으로 맞추기'),
                      ),
                    ),

                    if (!_allDay) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickStartTime,
                              icon: const Icon(Icons.schedule),
                              label: Text('시작시간: ${_fmtTime(_startTime)}'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickEndTime,
                              icon: const Icon(Icons.schedule_send),
                              label: Text('종료시간: ${_fmtTime(_endTime)}'),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 8),
                    const Divider(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '바 색상',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetColors.map((color) {
                        final selected = _colorValue == color.value;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _colorValue = color.value;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color: selected ? Colors.black : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: selected
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('상단 고정'),
                      subtitle: const Text('리스트에서 위쪽에 먼저 표시됩니다.'),
                      value: _pinned,
                      onChanged: (v) => setState(() => _pinned = v),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(_isEdit ? '수정 저장' : '추가 저장'),
            ),
          ),
        ],
      ),
    );
  }
}