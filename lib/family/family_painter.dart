// lib/family/family_painter.dart
import 'dart:math' show min, max;
import 'package:flutter/material.dart';
import 'family_model.dart';

class FamilyTreePainter extends CustomPainter {
  final List<FamilyMember> members;
  final Offset offset;

  FamilyTreePainter({
    required this.members,
    this.offset = Offset.zero,
  });

  static const double halfWidth = 60.0;
  static const double halfHeight = 80.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (members.isEmpty) return;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final spousePaint = Paint()
      ..color = Colors.pinkAccent.withValues(alpha: 0.8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final childLinePaint = Paint()
      ..color = const Color(0xFFFF8F5F)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 각 멤버(또는 부부 쌍)를 한 번씩만 처리
    final Set<String> processedIds = {};

    for (var member in members) {
      if (processedIds.contains(member.id)) continue;

      FamilyMember? spouse;
      if (member.spouseId != null) {
        try {
          spouse = members.firstWhere((m) => m.id == member.spouseId);
        } catch (_) {}
      }

      processedIds.add(member.id);
      if (spouse != null) processedIds.add(spouse.id);

      final Set<String> childrenIds = {...member.childrenIds};
      if (spouse != null) childrenIds.addAll(spouse.childrenIds);

      if (spouse != null && childrenIds.isEmpty) {
        // 자녀 없는 부부: 분홍 연결선 (카드 중앙 엣지 사이)
        final Offset leftCenter = member.position.dx <= spouse.position.dx
            ? member.position
            : spouse.position;
        final Offset rightCenter = member.position.dx <= spouse.position.dx
            ? spouse.position
            : member.position;
        canvas.drawLine(
          leftCenter + const Offset(halfWidth, 0),
          rightCenter - const Offset(halfWidth, 0),
          spousePaint,
        );
        continue;
      }

      if (childrenIds.isEmpty) continue;

      final List<Offset> childTops = [];
      for (var childId in childrenIds) {
        try {
          final child = members.firstWhere((m) => m.id == childId);
          childTops.add(child.position - const Offset(0, halfHeight));
        } catch (_) {}
      }
      if (childTops.isEmpty) continue;

      final path = Path();

      if (spouse != null) {
        // 자녀 있는 부부: 커플바(카드 중앙) + T자 연결선 (주황 단색)
        final Offset leftCenter = member.position.dx <= spouse.position.dx
            ? member.position
            : spouse.position;
        final Offset rightCenter = member.position.dx <= spouse.position.dx
            ? spouse.position
            : member.position;

        // 커플 중앙 Y (카드 중간 높이)
        final double coupleCenterY =
            (member.position.dy + spouse.position.dy) / 2;
        final double coupleCenterX =
            (member.position.dx + spouse.position.dx) / 2;

        // 커플바: 왼쪽 카드 오른쪽 엣지 → 오른쪽 카드 왼쪽 엣지 (카드 중앙 높이)
        path.moveTo(leftCenter.dx + halfWidth, coupleCenterY);
        path.lineTo(rightCenter.dx - halfWidth, coupleCenterY);

        final Offset startPoint = Offset(coupleCenterX, coupleCenterY);
        final double minChildTopY = childTops.map((p) => p.dy).reduce(min);
        final double midY = (startPoint.dy + minChildTopY) / 2;
        final double minX = childTops.map((p) => p.dx).reduce(min);
        final double maxX = childTops.map((p) => p.dx).reduce(max);
        final double barLeft = min(minX, startPoint.dx);
        final double barRight = max(maxX, startPoint.dx);

        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(startPoint.dx, midY);
        path.moveTo(barLeft, midY);
        path.lineTo(barRight, midY);
        for (var childTop in childTops) {
          path.moveTo(childTop.dx, midY);
          path.lineTo(childTop.dx, childTop.dy);
        }
      } else {
        // 혼자 + 자녀: 카드 하단 중앙에서 T자 연결
        final Offset startPoint = member.position + const Offset(0, halfHeight);
        final double minChildTopY = childTops.map((p) => p.dy).reduce(min);
        final double midY = (startPoint.dy + minChildTopY) / 2;
        final double minX = childTops.map((p) => p.dx).reduce(min);
        final double maxX = childTops.map((p) => p.dx).reduce(max);
        final double barLeft = min(minX, startPoint.dx);
        final double barRight = max(maxX, startPoint.dx);

        path.moveTo(startPoint.dx, startPoint.dy);
        path.lineTo(startPoint.dx, midY);
        path.moveTo(barLeft, midY);
        path.lineTo(barRight, midY);
        for (var childTop in childTops) {
          path.moveTo(childTop.dx, midY);
          path.lineTo(childTop.dx, childTop.dy);
        }
      }

      canvas.drawPath(path, childLinePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FamilyTreePainter oldDelegate) => true;
}
