import 'package:flutter/material.dart';
import 'schedule_controller.dart';
import 'schedule_model.dart';
import 'schedule_list_tab.dart';
import 'schedule_calendar_tab.dart';
import 'schedule_edit_page.dart';

// "일정" 메인 화면: 상단 TabBar(리스트/달력) + 카테고리 필터(전체/중요/기타)
class SchedulePage extends StatefulWidget {
  final ScheduleController controller;

  const SchedulePage({super.key, required this.controller});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('다가오는 일정'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '리스트'),
            Tab(text: '달력 보기'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 검색 기능 (나중에)
            },
          ),
        ],
      ),

      // 상단 필터 + TabBarView
      body: Column(
        children: [

          const Divider(height: 1),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ScheduleListTab(
                  controller: ctrl,
                  onChanged: () => setState(() {}),
                ),
                ScheduleCalendarTab(
                  controller: ctrl,
                  onChanged: () => setState(() {}),
                ),
              ],
            ),
          ),
        ],
      ),

      // 우측 하단 + 버튼(임시로 오늘 날짜에 일정 추가)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ScheduleEditPage(controller: ctrl),
            ),
          );
          if (changed == true) setState(() {});
        },
        child: const Icon(Icons.add),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // TODO: 실제로는 "일정 추가 페이지"로 이동시키면 됨
      //     // 지금은 임시로 오늘 날짜에 빠른 추가
      //     ctrl.addQuick(day: DateTime.now());
      //     setState(() {});
      //   },
      //   child: const Icon(Icons.add),
      // ),

    );
  }
}
