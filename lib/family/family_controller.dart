// lib/family/family_controller.dart
import 'package:flutter/material.dart';
import 'family_model.dart';

class FamilyController {
  // '나'를 (0,0) 중심으로 배치
  final List<FamilyMember> _members = [
    // --- 3세대 (나 - 중심) ---
    FamilyMember(
      id: 'c1', name: '김지훈', relation: '나(본인)', description: 'Flutter 공부',
      position: const Offset(0, 0),
    ),
    FamilyMember(
      id: 'c2', name: '김서연', relation: '동생', description: '시험 기간',
      position: const Offset(220, 0),
    ),

    // --- 2세대 (부모) ---
    FamilyMember(
      id: 'p1', name: '김민수', relation: '아빠', description: '회사원',
      position: const Offset(-150, -300), childrenIds: ['c1', 'c2'],
      spouseId: 'p2',
    ),
    FamilyMember(
      id: 'p2', name: '박지민', relation: '엄마', description: '선생님',
      position: const Offset(150, -300), childrenIds: ['c1', 'c2'],
      spouseId: 'p1',
    ),
    FamilyMember(
      id: 'p3', name: '김미영', relation: '고모', description: '부산 거주',
      position: const Offset(450, -300), childrenIds: [],
    ),

    // --- 1세대 (조부모) ---
    FamilyMember(
      id: 'g1', name: '김철수', relation: '할아버지', description: '생신: 05.05',
      position: const Offset(-300, -600), childrenIds: ['p1', 'p3'],
      spouseId: 'g2',
    ),
    FamilyMember(
      id: 'g2', name: '이영희', relation: '할머니', description: '생신: 11.11',
      position: const Offset(0, -600), childrenIds: [],
      spouseId: 'g1',
    ),
  ];

  List<FamilyMember> get members => _members;

  // [헬퍼] 특정 멤버와 그 자손들의 가장 오른쪽 X 좌표 구하기
  double _getSubtreeMaxX(FamilyMember member) {
    double maxX = member.position.dx;

    // 배우자가 있으면 배우자 위치도 고려
    if (member.spouseId != null) {
      try {
        final spouse = _members.firstWhere((m) => m.id == member.spouseId);
        if (spouse.position.dx > maxX) maxX = spouse.position.dx;
      } catch (_) {}
    }

    // 자식들의 위치 재귀적으로 확인
    for (var childId in member.childrenIds) {
      try {
        final child = _members.firstWhere((m) => m.id == childId);
        double childMaxX = _getSubtreeMaxX(child);
        if (childMaxX > maxX) maxX = childMaxX;
      } catch (_) {}
    }

    return maxX;
  }

  // [기능] 특정 위치(startX) 오른쪽에 있는 멤버들을 오른쪽으로 밀어내기
  void _shiftMembersRight(double startX, double y, double shiftAmount) {
    // 같은 세대(Y)이면서 startX보다 오른쪽에 있는 노드들 찾기
    final targetNodes = _members.where((m) =>
    (m.position.dy - y).abs() < 50 &&
        m.position.dx >= startX - 10
    ).toList();

    final Set<String> movedIds = {};

    void moveNodeRecursively(String nodeId) {
      if (movedIds.contains(nodeId)) return;
      movedIds.add(nodeId);

      final index = _members.indexWhere((m) => m.id == nodeId);
      if (index == -1) return;

      final member = _members[index];

      _members[index] = FamilyMember(
        id: member.id,
        name: member.name,
        relation: member.relation,
        imageUrl: member.imageUrl,
        description: member.description,
        position: member.position + Offset(shiftAmount, 0),
        childrenIds: member.childrenIds,
        spouseId: member.spouseId,
      );

      // 자식들도 따라 이동
      for (var childId in member.childrenIds) {
        moveNodeRecursively(childId);
      }
      // 배우자도 따라 이동
      if (member.spouseId != null) {
        moveNodeRecursively(member.spouseId!);
      }
    }

    for (var node in targetNodes) {
      moveNodeRecursively(node.id);
    }
  }

  // 가족 추가
  void addMember({
    required String name,
    required String relation,
    required String description,
    required String? relatedMemberId,
    required bool isAddAsParent,
    String? spouseId,
  }) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    Offset newPosition = const Offset(0, 400);
    const double siblingGap = 220.0;

    List<String> initialChildren = [];

    if (relatedMemberId != null) {
      try {
        final relatedMember = _members.firstWhere((m) => m.id == relatedMemberId);
        const double verticalGap = 300.0;

        if (isAddAsParent) {
          // [부모로 추가]
          newPosition = relatedMember.position - const Offset(80, verticalGap);
          initialChildren.add(relatedMemberId);
        } else {
          // [자녀로 추가]

          // 1. 부부의 자녀 목록 확인
          FamilyMember? spouse;
          if (relatedMember.spouseId != null) {
            try {
              spouse = _members.firstWhere((m) => m.id == relatedMember.spouseId);
            } catch (_) {}
          }
          Set<String> existingChildrenIds = {...relatedMember.childrenIds};
          if (spouse != null) existingChildrenIds.addAll(spouse.childrenIds);

          if (existingChildrenIds.isEmpty) {
            newPosition = relatedMember.position + const Offset(0, verticalGap);
          } else {
            // 형제 중 가장 오른쪽 위치 찾기
            double maxX = -double.infinity;
            double currentY = 0;
            for (var id in existingChildrenIds) {
              try {
                final child = _members.firstWhere((m) => m.id == id);
                currentY = child.position.dy;
                // 자녀 본인과 그 배우자까지 고려하여 가장 오른쪽 찾기
                if (child.position.dx > maxX) maxX = child.position.dx;
                if (child.spouseId != null) {
                  final childSpouse = _members.firstWhere((m) => m.id == child.spouseId);
                  if (childSpouse.position.dx > maxX) maxX = childSpouse.position.dx;
                }
              } catch (_) {}
            }
            newPosition = Offset(maxX + siblingGap, currentY);
          }

          // 2. [핵심 로직] 내 부모의 왼쪽 형제들 때문에 자리가 좁지 않은지 확인
          // (왼쪽 집안의 자녀들이 내 자리까지 뻗어왔는지 체크)
          final leftSiblings = _members.where((m) =>
          (m.position.dy - relatedMember.position.dy).abs() < 50 && // 같은 세대(부모 세대)
              m.position.dx < relatedMember.position.dx // 내 부모보다 왼쪽에 있는 사람
          );

          double maxRightOfLeftFamilies = -double.infinity;
          for (var sibling in leftSiblings) {
            // 그 형제(집안)의 자손들이 뻗은 최대 X좌표 계산
            double subtreeMax = _getSubtreeMaxX(sibling);
            if (subtreeMax > maxRightOfLeftFamilies) maxRightOfLeftFamilies = subtreeMax;
          }

          // 만약 왼쪽 집안이 너무 커서 내 자리(newPosition)를 침범한다면?
          if (maxRightOfLeftFamilies != -double.infinity) {
            double safeX = maxRightOfLeftFamilies + siblingGap; // 안전 거리 확보
            if (newPosition.dx < safeX) {
              // 필요한 만큼 밀어내기 양 계산
              double shiftNeeded = safeX - newPosition.dx;

              // 내 부모(relatedMember)와 그 오른쪽 모든 가족들을 오른쪽으로 이동
              _shiftMembersRight(
                  relatedMember.position.dx - 10, // 내 부모 위치부터
                  relatedMember.position.dy,      // 내 부모 세대에서
                  shiftNeeded                     // 필요한 만큼 이동
              );

              // 내 자녀의 위치도 이동된 부모에 맞춰 조정
              newPosition = newPosition + Offset(shiftNeeded, 0);
            }
          }

          relatedMember.childrenIds.add(newId);
        }
      } catch (e) { /* ignore */ }
    } else if (spouseId != null) {
      try {
        final spouse = _members.firstWhere((m) => m.id == spouseId);
        newPosition = spouse.position + const Offset(220, 0);
      } catch (e) {}
    }

    // 3. 내가 들어갈 자리에 원래 있던 사람들(내 동생들, 혹은 오른쪽 집안) 밀어내기
    _shiftMembersRight(newPosition.dx, newPosition.dy, siblingGap);

    final newMember = FamilyMember(
      id: newId,
      name: name,
      relation: relation,
      description: description,
      position: newPosition,
      childrenIds: initialChildren,
      spouseId: spouseId,
    );

    _members.add(newMember);

    if (spouseId != null) {
      final index = _members.indexWhere((m) => m.id == spouseId);
      if (index != -1) {
        final s = _members[index];
        _members[index] = FamilyMember(
          id: s.id,
          name: s.name,
          relation: s.relation,
          imageUrl: s.imageUrl,
          description: s.description,
          position: s.position,
          childrenIds: s.childrenIds,
          spouseId: newId,
        );
      }
    }
  }

  void deleteMember(String id) {
    _members.removeWhere((m) => m.id == id);
    for (var i = 0; i < _members.length; i++) {
      var member = _members[i];
      member.childrenIds.remove(id);
      if (member.spouseId == id) {
        _members[i] = FamilyMember(
          id: member.id,
          name: member.name,
          relation: member.relation,
          imageUrl: member.imageUrl,
          description: member.description,
          position: member.position,
          childrenIds: member.childrenIds,
          spouseId: null,
        );
      }
    }
  }

  void updateMember(FamilyMember updatedMember) {
    final index = _members.indexWhere((m) => m.id == updatedMember.id);
    if (index != -1) {
      _members[index] = updatedMember;
    }
  }
}