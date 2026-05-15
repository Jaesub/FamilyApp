// lib/family/family_controller.dart
import 'dart:math' show min, max;
import 'package:flutter/material.dart';
import 'family_model.dart';

class FamilyController {
  final List<FamilyMember> _members = [
    FamilyMember(id: 'c1', name: '김지훈', relation: '나(본인)', description: 'Flutter 공부', position: Offset.zero),
    FamilyMember(id: 'c2', name: '김서연', relation: '동생', description: '시험 기간', position: Offset.zero),
    FamilyMember(id: 'p1', name: '김민수', relation: '아빠', description: '회사원', position: Offset.zero, childrenIds: ['c1', 'c2'], spouseId: 'p2'),
    FamilyMember(id: 'p2', name: '박지민', relation: '엄마', description: '선생님', position: Offset.zero, childrenIds: ['c1', 'c2'], spouseId: 'p1'),
    FamilyMember(id: 'p3', name: '김미영', relation: '고모', description: '부산 거주', position: Offset.zero),
    FamilyMember(id: 'g1', name: '김철수', relation: '할아버지', description: '생신: 05.05', position: Offset.zero, childrenIds: ['p1', 'p3'], spouseId: 'g2'),
    FamilyMember(id: 'g2', name: '이영희', relation: '할머니', description: '생신: 11.11', position: Offset.zero, spouseId: 'g1'),
  ];

  FamilyController() {
    relayout();
  }

  List<FamilyMember> get members => _members;

  void relayout() {
    if (_members.isEmpty) return;

    const double hStep = 220.0; // 형제 간격 (카드 중심 기준)
    const double vStep = 300.0; // 세대 간격

    // ── 1. 누가 자식인지 파악 ─────────────────────────────────────────────
    final Set<String> hasParent = {};
    for (var m in _members) {
      for (var cId in m.childrenIds) hasParent.add(cId);
    }

    // ── 2. 부부 중 primary / secondary 분류 (먼저 나타나는 쪽이 primary) ──
    final Set<String> isSecondary = {};
    final Set<String> couplesSeen = {};
    for (var m in _members) {
      if (couplesSeen.contains(m.id)) continue;
      couplesSeen.add(m.id);
      if (m.spouseId != null) {
        couplesSeen.add(m.spouseId!);
        isSecondary.add(m.spouseId!);
      }
    }

    // 루트: 부모 없음 AND primary
    final roots = _members
        .where((m) => !hasParent.contains(m.id) && !isSecondary.contains(m.id))
        .toList();

    // ── 3. 세대(generation) 할당 ─────────────────────────────────────────
    final Map<String, int> genOf = {};

    void assignGen(String id, int gen) {
      if (genOf.containsKey(id)) return;
      genOf[id] = gen;
      final idx = _members.indexWhere((m) => m.id == id);
      if (idx == -1) return;
      final m = _members[idx];
      // 배우자는 같은 세대
      if (m.spouseId != null) genOf[m.spouseId!] = gen;
      // 자녀는 다음 세대
      for (var cId in m.childrenIds) assignGen(cId, gen + 1);
      // 배우자의 자녀도 다음 세대
      if (m.spouseId != null) {
        final si = _members.indexWhere((s) => s.id == m.spouseId);
        if (si != -1) {
          for (var cId in _members[si].childrenIds) assignGen(cId, gen + 1);
        }
      }
    }

    for (var r in roots) assignGen(r.id, 0);
    // 연결되지 않은 멤버는 세대 0
    for (var m in _members) {
      if (!genOf.containsKey(m.id)) genOf[m.id] = 0;
    }

    final int maxGen = genOf.values.fold(0, (a, b) => a > b ? a : b);

    // ── 4. 재귀 X 배치 (자식 먼저, 부모는 자식 중앙 위에) ────────────────
    final Map<String, double> xOf = {};
    final Set<String> placed = {};

    double placeFamily(String primaryId, double startX) {
      if (placed.contains(primaryId)) return startX;
      placed.add(primaryId);

      final idx = _members.indexWhere((m) => m.id == primaryId);
      if (idx == -1) return startX + hStep;
      final primary = _members[idx];

      FamilyMember? spouse;
      if (primary.spouseId != null) {
        placed.add(primary.spouseId!);
        final si = _members.indexWhere((m) => m.id == primary.spouseId);
        if (si != -1) spouse = _members[si];
      }

      // 자녀 목록 (순서 유지, 중복 제거)
      final List<String> orderedChildren = [...primary.childrenIds];
      if (spouse != null) {
        for (var cId in spouse.childrenIds) {
          if (!orderedChildren.contains(cId)) orderedChildren.add(cId);
        }
      }
      final pending = orderedChildren.where((c) => !placed.contains(c)).toList();

      if (pending.isEmpty) {
        // 리프 노드
        if (spouse != null) {
          xOf[primaryId] = startX;
          xOf[spouse.id] = startX + hStep;
          return startX + hStep * 2;
        }
        xOf[primaryId] = startX;
        return startX + hStep;
      }

      // 자식들 먼저 배치
      double cursor = startX;
      for (var cId in pending) {
        var cPrimId = cId;
        if (isSecondary.contains(cId)) {
          try {
            cPrimId = _members
                .firstWhere((m) => m.spouseId == cId && !isSecondary.contains(m.id))
                .id;
          } catch (_) {}
        }
        if (!placed.contains(cPrimId)) cursor = placeFamily(cPrimId, cursor);
      }

      // 배치된 자녀들의 X 범위로 부모 중앙 계산
      final childXs = orderedChildren
          .where(xOf.containsKey)
          .map((c) => xOf[c]!)
          .toList();

      final double cMin = childXs.isEmpty ? startX : childXs.reduce(min);
      final double cMax = childXs.isEmpty ? startX : childXs.reduce(max);
      final double center = (cMin + cMax) / 2;

      if (spouse != null) {
        xOf[primaryId] = center - hStep / 2;
        xOf[spouse.id] = center + hStep / 2;
        return max(cursor, center + hStep / 2 + hStep);
      }
      xOf[primaryId] = center;
      return max(cursor, center + hStep);
    }

    double cursor = 0;
    for (var root in roots) cursor = placeFamily(root.id, cursor);
    // 고립된 멤버도 배치
    for (var m in _members) {
      if (!placed.contains(m.id) && !isSecondary.contains(m.id)) {
        cursor = placeFamily(m.id, cursor);
      }
    }

    // ── 5. 전체를 x=0 중앙 정렬 후 Y는 세대 기준 적용 ───────────────────
    final allXs = xOf.values.toList();
    if (allXs.isEmpty) return;
    final double xCenter = (allXs.reduce(min) + allXs.reduce(max)) / 2;

    for (var i = 0; i < _members.length; i++) {
      final m = _members[i];
      final x = (xOf[m.id] ?? 0) - xCenter;
      final y = ((genOf[m.id] ?? 0) - maxGen) * vStep; // 리프=0, 위로 갈수록 음수
      _members[i] = FamilyMember(
        id: m.id,
        name: m.name,
        relation: m.relation,
        imageUrl: m.imageUrl,
        description: m.description,
        position: Offset(x, y),
        childrenIds: m.childrenIds,
        spouseId: m.spouseId,
      );
    }
  }

  void addMember({
    required String name,
    required String relation,
    required String description,
    required String? relatedMemberId,
    required bool isAddAsParent,
    String? spouseId,
  }) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final List<String> initialChildren = [];

    if (relatedMemberId != null) {
      try {
        final relatedMember = _members.firstWhere((m) => m.id == relatedMemberId);
        if (isAddAsParent) {
          initialChildren.add(relatedMemberId);
        } else {
          relatedMember.childrenIds.add(newId);
        }
      } catch (_) {}
    }

    _members.add(FamilyMember(
      id: newId,
      name: name,
      relation: relation,
      description: description,
      position: Offset.zero,
      childrenIds: initialChildren,
      spouseId: spouseId,
    ));

    if (spouseId != null) {
      final idx = _members.indexWhere((m) => m.id == spouseId);
      if (idx != -1) {
        final s = _members[idx];
        _members[idx] = FamilyMember(
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

    relayout();
  }

  void deleteMember(String id) {
    _members.removeWhere((m) => m.id == id);
    for (var i = 0; i < _members.length; i++) {
      final m = _members[i];
      m.childrenIds.remove(id);
      if (m.spouseId == id) {
        _members[i] = FamilyMember(
          id: m.id,
          name: m.name,
          relation: m.relation,
          imageUrl: m.imageUrl,
          description: m.description,
          position: m.position,
          childrenIds: m.childrenIds,
          spouseId: null,
        );
      }
    }
    relayout();
  }

  void updateMember(FamilyMember updatedMember) {
    final index = _members.indexWhere((m) => m.id == updatedMember.id);
    if (index != -1) _members[index] = updatedMember;
  }
}
