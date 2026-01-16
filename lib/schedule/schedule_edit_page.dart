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

  late DateTime _start;
  DateTime? _end;

  ScheduleCategory _category = ScheduleCategory.etc;
  bool _pinned = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();

    final it = widget.item;
    _titleCtr = TextEditingController(text: it?.title ?? '');
    _memoCtr = TextEditingController(text: it?.memo ?? '');

    final day = widget.initialDay ?? DateTime.now();
    _start = it?.start ?? DateTime(day.year, day.month, day.day);
    _end = it?.end;

    _category = it?.category ?? ScheduleCategory.etc;
    _pinned = it?.pinned ?? false;
  }

  @override
  void dispose() {
    _titleCtr.dispose();
    _memoCtr.dispose();
    super.dispose();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  String _two(int n) => n.toString().padLeft(2, '0');
  String _fmt(DateTime d) => '${d.year}.${_two(d.month)}.${_two(d.day)}';

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _start = _normalize(picked);

      // 종료일이 시작일보다 이전이면 종료일 제거
      if (_end != null && _end!.isBefore(_start)) {
        _end = null;
      }
    });
  }

  Future<void> _pickEnd() async {
    final initial = _end ?? _start;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _start, // ✅ 종료일은 시작일 이후만 허용
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _end = _normalize(picked);
    });
  }

  void _clearEnd() => setState(() => _end = null);

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtr.text.trim();
    final memo = _memoCtr.text;

    if (_isEdit) {
      widget.controller.update(
        id: widget.item!.id,
        title: title,
        memo: memo,
        start: _start,
        end: _end,
        category: _category,
        pinned: _pinned,
      );
    } else {
      widget.controller.add(
        title: title,
        memo: memo,
        start: _start,
        end: _end,
        category: _category,
        pinned: _pinned,
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
                if (ok == true && mounted) _delete();
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
                        if (v == null || v.trim().isEmpty) return '제목을 입력하세요.';
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

                    // 날짜 선택 영역
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickStart,
                            icon: const Icon(Icons.event),
                            label: Text('시작: ${_fmt(_start)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickEnd,
                            icon: const Icon(Icons.event_available),
                            label: Text(_end == null ? '종료: 없음' : '종료: ${_fmt(_end!)}'),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _end == null ? null : _clearEnd,
                        child: const Text('종료일 제거'),
                      ),
                    ),

                    const Divider(height: 24),

                    // 카테고리(전체는 저장용이 아니니 제외)
                    DropdownButtonFormField<ScheduleCategory>(
                      value: _category == ScheduleCategory.all ? ScheduleCategory.etc : _category,
                      decoration: const InputDecoration(
                        labelText: '분류',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(value: ScheduleCategory.important, child: Text('중요')),
                        DropdownMenuItem(value: ScheduleCategory.etc, child: Text('기타')),
                      ],
                      onChanged: (v) => setState(() => _category = v ?? ScheduleCategory.etc),
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
