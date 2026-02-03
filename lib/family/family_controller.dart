// lib/family/family_controller.dart
import 'package:flutter/material.dart';
import 'family_model.dart';

class FamilyController {
  // '나'를 (0,0) 중심으로 배치
  final List<FamilyMember> _members = [
    // --- 3세대 (나 - 중심) ---
    FamilyMember(
      id: 'c1', name: '김지훈', relation: '나(본인)', description: 'Flutter 공부',
      position: const Offset(0, 0), // 화면 중앙
    ),
    FamilyMember(
      id: 'c2', name: '김서연', relation: '동생', description: '시험 기간',
      position: const Offset(160, 0), // 내 오른쪽
    ),

    // --- 2세대 (부모 - 위쪽) ---
    FamilyMember(
      id: 'p1', name: '김민수', relation: '아빠', description: '회사원',
      position: const Offset(-150, -300), childrenIds: ['c1', 'c2'], // 내 위, 왼쪽
      spouseId: 'p2',
    ),
    FamilyMember(
      id: 'p2', name: '박지민', relation: '엄마', description: '선생님',
      position: const Offset(150, -300), childrenIds: ['c1', 'c2'], // 내 위, 오른쪽
      spouseId: 'p1',
    ),
    FamilyMember(
      id: 'p3', name: '김미영', relation: '고모', description: '부산 거주',
      position: const Offset(450, -300), childrenIds: [], // 아빠 라인 오른쪽
    ),

    // --- 1세대 (조부모 - 더 위쪽) ---
    FamilyMember(
      id: 'g1', name: '김철수', relation: '할아버지', description: '생신: 05.05',
      position: const Offset(-300, -600), childrenIds: ['p1', 'p3'], // 아빠의 위
      spouseId: 'g2',
    ),
    FamilyMember(
      id: 'g2', name: '이영희', relation: '할머니', description: '생신: 11.11',
      position: const Offset(0, -600), childrenIds: [], // 할아버지 옆
      spouseId: 'g1',
    ),
  ];

  List<FamilyMember> get members => _members;

  // 가족 추가 (배우자 선택 로직 추가)
  void addMember({
    required String name,
    required String relation,
    required String description,
    required String? relatedMemberId, // 부모/자녀 연결 ID
    required bool isAddAsParent,      // 부모로 추가할지 여부
    String? spouseId,                 // [NEW] 선택된 배우자 ID
  }) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    Offset newPosition = const Offset(0, 400); // 기본 위치

    List<String> initialChildren = [];

    // 1. 부모/자녀 관계에 따른 위치 계산
    if (relatedMemberId != null) {
      try {
        final relatedMember = _members.firstWhere((m) => m.id == relatedMemberId);
        const double verticalGap = 300.0;
        const double siblingGap = 160.0;

        if (isAddAsParent) {
          // 부모로 추가: 위쪽으로 이동
          newPosition = relatedMember.position - const Offset(80, verticalGap);
          initialChildren.add(relatedMemberId);
        } else {
          // 자녀로 추가: 아래쪽으로 이동
          if (relatedMember.childrenIds.isEmpty) {
            newPosition = relatedMember.position + const Offset(0, verticalGap);
          } else {
            final lastChildId = relatedMember.childrenIds.last;
            try {
              final lastChild = _members.firstWhere((m) => m.id == lastChildId);
              newPosition = lastChild.position + const Offset(siblingGap, 0);
            } catch (e) {
              newPosition = relatedMember.position +
                  Offset(siblingGap * relatedMember.childrenIds.length, verticalGap);
            }
          }
          relatedMember.childrenIds.add(newId);
        }
      } catch (e) { /* ignore */ }
    } else if (spouseId != null) {
      // [NEW] 부모/자녀 연결 없이 배우자만 선택한 경우: 배우자 옆에 배치
      try {
        final spouse = _members.firstWhere((m) => m.id == spouseId);
        newPosition = spouse.position + const Offset(120, 0); // 배우자 오른쪽
      } catch (e) {}
    }

    // 2. 새 멤버 생성
    final newMember = FamilyMember(
      id: newId,
      name: name,
      relation: relation,
      description: description,
      position: newPosition,
      childrenIds: initialChildren,
      spouseId: spouseId, // [NEW] 배우자 연결
    );

    _members.add(newMember);

    // 3. 선택된 배우자 쪽에서도 나를 배우자로 등록 (양방향 연결)
    if (spouseId != null) {
      final index = _members.indexWhere((m) => m.id == spouseId);
      if (index != -1) {
        final s = _members[index];
        // 기존 객체를 교체하여 업데이트
        _members[index] = FamilyMember(
          id: s.id,
          name: s.name,
          relation: s.relation,
          imageUrl: s.imageUrl,
          description: s.description,
          position: s.position,
          childrenIds: s.childrenIds,
          spouseId: newId, // [NEW] 서로 연결
        );
      }
    }
  }

  // 삭제 (배우자 연결 끊기 포함)
  void deleteMember(String id) {
    _members.removeWhere((m) => m.id == id);

    for (var i = 0; i < _members.length; i++) {
      var member = _members[i];

      // 자식 목록에서 삭제
      member.childrenIds.remove(id);

      // [NEW] 배우자 연결 끊기
      if (member.spouseId == id) {
        _members[i] = FamilyMember(
          id: member.id,
          name: member.name,
          relation: member.relation,
          imageUrl: member.imageUrl,
          description: member.description,
          position: member.position,
          childrenIds: member.childrenIds,
          spouseId: null, // null로 초기화
        );
      }
    }
  }

  // 수정
  void updateMember(FamilyMember updatedMember) {
    final index = _members.indexWhere((m) => m.id == updatedMember.id);
    if (index != -1) {
      _members[index] = updatedMember;
    }
  }
}