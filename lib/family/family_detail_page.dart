// lib/family/family_detail_page.dart
import 'package:flutter/material.dart';
import 'family_model.dart';

class FamilyDetailPage extends StatefulWidget {
  final FamilyMember member;
  final List<FamilyMember> allMembers; // [NEW] 관계 확인을 위해 전체 리스트 필요

  const FamilyDetailPage({
    super.key,
    required this.member,
    required this.allMembers, // 생성자 업데이트
  });

  @override
  State<FamilyDetailPage> createState() => _FamilyDetailPageState();
}

class _FamilyDetailPageState extends State<FamilyDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FamilyMember> _siblings = []; // 형제/자매 리스트 (탭 구성용)

  @override
  void initState() {
    super.initState();
    _initTabs();
  }

  void _initTabs() {
    // 1. 현재 멤버의 부모 찾기 (형제 관계 파악용)
    FamilyMember? parent;
    try {
      parent = widget.allMembers.firstWhere(
            (m) => m.childrenIds.contains(widget.member.id),
      );
    } catch (_) {
      parent = null;
    }

    if (parent != null) {
      // 2. 부모가 있으면, 부모의 자녀들(형제들)을 모두 가져옴
      _siblings = parent.childrenIds
          .map((id) => widget.allMembers.firstWhere((m) => m.id == id))
          .toList();
    } else {
      // 3. 부모가 없으면(최상위 노드 등), 본인만 탭에 표시
      _siblings = [widget.member];
    }

    // 4. 본인이 몇 번째 탭인지 확인
    int initialIndex = _siblings.indexOf(widget.member);
    if (initialIndex == -1) initialIndex = 0;

    // 5. 탭 컨트롤러 설정
    _tabController = TabController(
        length: _siblings.length,
        initialIndex: initialIndex,
        vsync: this
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.member.name),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 1. 상단 탭 바 (형제들 목록)
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFFFF8F5F),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFFF8F5F),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              // 동적으로 탭 생성 (예: 1 아빠, 2 고모)
              tabs: _siblings.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final member = entry.value;
                return Tab(text: "$index ${member.relation}");
              }).toList(),
            ),
          ),

          // 2. 탭 내용 (각 형제의 가족 정보)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _siblings.map((sibling) {
                return _buildFamilyView(sibling);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 각 탭의 내용을 구성하는 뷰 (본인 + 배우자 + 자녀들)
  Widget _buildFamilyView(FamilyMember target) {
    // 배우자 찾기
    FamilyMember? spouse;
    if (target.spouseId != null) {
      try {
        spouse = widget.allMembers.firstWhere((m) => m.id == target.spouseId);
      } catch (_) {}
    }

    // 자녀들 찾기
    List<FamilyMember> children = [];
    if (target.childrenIds.isNotEmpty) {
      children = target.childrenIds
          .map((id) {
        try {
          return widget.allMembers.firstWhere((m) => m.id == id);
        } catch (_) {
          return null;
        }
      })
          .whereType<FamilyMember>() // null 제거
          .toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 타이틀
          Text(
            "${target.relation}네 가족",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          // 부부 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 본인 (형제 중 한 명)
              _buildPersonCard(
                member: target,
                isHighlight: true,
              ),

              // 배우자가 있으면 표시
              if (spouse != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(width: 20, height: 2, color: Colors.grey.shade300),
                ),
                _buildPersonCard(
                  member: spouse,
                  isHighlight: false,
                ),
              ] else ...[
                // 배우자 자리가 비어있어도 균형을 위해 투명 공간 유지 가능 (선택 사항)
              ],
            ],
          ),

          const SizedBox(height: 40),

          // 구분선 (자녀가 있을 때만)
          if (children.isNotEmpty) ...[
            Row(
              children: [
                Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("자녀", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ),
                Expanded(child: Container(height: 1, color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 40),

            // 자녀 리스트
            ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildChildRow(child),
            )),
          ] else ...[
            const Text("등록된 자녀가 없습니다.", style: TextStyle(color: Colors.grey)),
          ],

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // 인물 카드 위젯
  Widget _buildPersonCard({
    required FamilyMember member,
    bool isHighlight = false,
  }) {
    return Container(
      width: 140,
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: isHighlight
            ? Border.all(color: const Color(0xFF5AC8FA), width: 2)
            : Border.all(color: Colors.transparent),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 50, color: Colors.grey.shade400),
          const Spacer(),
          Text(
            member.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            member.relation,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            member.description,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 자녀 행 위젯
  Widget _buildChildRow(FamilyMember child) {
    return Row(
      children: [
        // 자녀 사진/박스
        Container(
          width: 100,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.face, size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(child.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(child.relation, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(width: 20),

        // 자녀 상세 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "상세 정보",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(child.description, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        )
      ],
    );
  }
}