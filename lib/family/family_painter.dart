// lib/family/family_painter.dart
import 'package:flutter/material.dart';
import 'family_model.dart';

class FamilyTreePainter extends CustomPainter {
  final List<FamilyMember> members;
  final Offset offset;

  FamilyTreePainter({
    required this.members,
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (members.isEmpty) return;

    // 캔버스 좌표 이동 (화면 중앙 정렬)
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final spousePaint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.5)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final childLinePaint = Paint()
      ..color = const Color(0xFFFF8F5F)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 카드 크기의 절반 (중앙에서 상하단까지의 거리)
    // 카드 높이 160 / 2 = 80
    const double halfHeight = 80.0;

    // [수정] 자녀 선 그리기용 중복 체크 (부부 선은 중복 체크 없이 그림)
    final Set<String> processedForChildren = {};

    for (var member in members) {
      // 1. 배우자 연결선 그리기 (무조건 시도)
      if (member.spouseId != null) {
        try {
          final spouse = members.firstWhere((m) => m.id == member.spouseId);
          // member.position이 이미 '카드의 정중앙'입니다.
          canvas.drawLine(member.position, spouse.position, spousePaint);
        } catch (_) {
          // 배우자 정보를 찾을 수 없으면 패스
        }
      }

      // 2. 자녀 연결선 그리기 (중복 방지 필요)
      if (processedForChildren.contains(member.id)) continue;

      FamilyMember? spouse;
      if (member.spouseId != null) {
        try {
          spouse = members.firstWhere((m) => m.id == member.spouseId);
        } catch (_) {}
      }

      // 자녀 선은 부부 중 한 번만 처리하면 됨
      processedForChildren.add(member.id);
      if (spouse != null) {
        processedForChildren.add(spouse.id);
      }

      // 자녀 목록 합치기
      final Set<String> childrenIds = {...member.childrenIds};
      if (spouse != null) {
        childrenIds.addAll(spouse.childrenIds);
      }

      if (childrenIds.isEmpty) continue;

      List<Offset> childrenTopPoints = [];
      for (var childId in childrenIds) {
        try {
          final child = members.firstWhere((m) => m.id == childId);
          // 자녀의 상단 중앙 좌표 = 중앙 - 반 높이
          childrenTopPoints.add(child.position - const Offset(0, halfHeight));
        } catch (_) {}
      }

      if (childrenTopPoints.isEmpty) continue;

      // 부모 쪽 시작점 결정 (선이 내려오는 곳)
      Offset startPoint;
      if (spouse != null) {
        // 부부인 경우: 두 사람 사이의 정중앙에서, 카드 하단 높이만큼 내려옴
        final centerOfSpouses = (member.position + spouse.position) / 2;
        startPoint = centerOfSpouses + const Offset(0, halfHeight);
      } else {
        // 한부모인 경우: 내 카드의 하단 중앙
        startPoint = member.position + const Offset(0, halfHeight);
      }

      // 선 그리기 로직 (직각 형태)
      double minX = childrenTopPoints.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
      double maxX = childrenTopPoints.map((p) => p.dx).reduce((a, b) => a > b ? a : b);

      // 중간 꺾임 높이
      double midY = (startPoint.dy + childrenTopPoints.first.dy) / 2;

      final path = Path();

      // (1) 부모에서 중간 높이까지 수직으로 내리기
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(startPoint.dx, midY);

      // (2) 자녀들의 범위만큼 수평선 긋기
      double barLeft = minX < startPoint.dx ? minX : startPoint.dx;
      double barRight = maxX > startPoint.dx ? maxX : startPoint.dx;

      path.moveTo(barLeft, midY);
      path.lineTo(barRight, midY);

      // (3) 수평선에서 각 자녀 머리 위로 수직선 내리기
      for (var childTop in childrenTopPoints) {
        path.moveTo(childTop.dx, midY);
        path.lineTo(childTop.dx, childTop.dy);
      }

      canvas.drawPath(path, childLinePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FamilyTreePainter oldDelegate) => true;
}