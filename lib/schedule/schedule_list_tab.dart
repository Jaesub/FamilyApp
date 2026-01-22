import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'schedule_controller.dart';
import 'schedule_model.dart';
import 'schedule_edit_page.dart';

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

    final _dateFmt = DateFormat('yyyy.mm.dd');
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        for (final month in grouped.keys) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(month, style: Theme.of(context).textTheme.titleMedium),
          ),

          // 카드 생성 부분 수정
          for (final it in grouped[month]!)
            _ScheduleCard(
              item: it,
              onTap: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => ScheduleEditPage(controller: controller, item: it),
                  ),
                );
                if (changed == true) onChanged();
              },
              onDelete: () {
                controller.remove(it.id);
                onChanged();
              },
            ),
          const SizedBox(height: 8),
        ]
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleItem item;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ScheduleCard({
    required this.item,
    required this.onDelete,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy.MM.dd');

    // 오른쪽 날짜 문자열: 단일/기간
    final dateText = item.end == null
        ? dateFmt.format(item.start)
        : '${dateFmt.format(item.start)} - ${dateFmt.format(item.end!)}';

    // 중요 여부
    final isImportant = item.category == ScheduleCategory.important;

    // 이전버전
    // return Card(
    //   child: ListTile(
    //     onTap: onTap,  // ✅ 탭하면 수정 화면
    //     title: Text(item.title),
    //     subtitle: item.memo == null ? null : Text(item.memo!, maxLines: 1, overflow: TextOverflow.ellipsis),
    //     trailing: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text(right, style: Theme.of(context).textTheme.bodySmall),
    //         const SizedBox(height: 6),
    //         InkWell(
    //           onTap: onDelete,
    //           child: const Icon(Icons.delete_outline, size: 18),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    // 신규 ui
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap, // ✅ 탭하면 수정 화면으로
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 왼쪽: 중요 표시 아이콘(중요일 때만)
              if (isImportant)
                const Padding(
                  padding: EdgeInsets.only(top: 2, right: 10),
                  child: Icon(Icons.star_rounded, size: 20),
                )
              else
                const SizedBox(width: 30), // 아이콘 자리 고정으로 정렬 유지

              // ✅ 가운데: 제목/메모
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 + (고정 핀은 오른쪽에 둘 수도 있는데, 제목 옆에 작게 표시하는 버전)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.pinned) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.push_pin, size: 18),
                        ],
                      ],
                    ),

                    // 메모가 있을 때만 한 줄
                    if (item.memo != null && item.memo!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.memo!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ✅ 오른쪽: 날짜 + 삭제 버튼(정렬)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dateText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: onDelete, // 삭제만 별도로
                    child: const Icon(Icons.delete_outline, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
