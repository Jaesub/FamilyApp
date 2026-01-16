import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'schedule_controller.dart';
import 'schedule_model.dart';

class ScheduleListTab extends StatelessWidget {
  final ScheduleController controller;
  final ScheduleCategory filter;
  final VoidCallback onChanged;

  const ScheduleListTab({
    super.key,
    required this.controller,
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = controller.filtered(filter).toList()
      ..sort((a, b) {
        // pinned 우선, 그 다음 날짜 오름차순
        final p = (b.pinned ? 1 : 0) - (a.pinned ? 1 : 0);
        if (p != 0) return p;
        return a.start.compareTo(b.start);
      });

    // 월별 그룹핑
    final Map<String, List<ScheduleItem>> grouped = {};
    for (final it in items) {
      final key = DateFormat('yyyy.MM').format(it.start);
      grouped.putIfAbsent(key, () => []).add(it);
    }

    if (grouped.isEmpty) {
      return const Center(child: Text('일정이 없습니다.'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        for (final month in grouped.keys) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(month, style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final it in grouped[month]!) _ScheduleCard(item: it, onDelete: () {
            controller.remove(it.id);
            onChanged();
          }),
          const SizedBox(height: 8),
        ]
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleItem item;
  final VoidCallback onDelete;

  const _ScheduleCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy.MM.dd');
    final right = item.end == null
        ? dateFmt.format(item.start)
        : '${dateFmt.format(item.start)} - ${dateFmt.format(item.end!)}';

    return Card(
      child: ListTile(
        title: Text(item.title),
        subtitle: item.memo == null ? null : Text(item.memo!, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(right, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            InkWell(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
