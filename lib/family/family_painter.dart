// lib/family/family_painter.dart
import 'package:flutter/material.dart';
import 'family_model.dart';

class FamilyTreePainter extends CustomPainter {
  final List<FamilyMember> members;
  final Offset offset; // [NEW] 캔버스 중심 이동을 위한 오프셋

  FamilyTreePainter({
    required this.members,
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (members.isEmpty) return;

    // [중요] 캔버스의 원점(0,0)을 화면 중앙으로 이동
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final spousePaint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final childLinePaint = Paint()
      ..color = const Color(0xFFFF8F5F)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const double halfHeight = 80.0;
    final Set<String> processedIds = {};

    for (var member in members) {
      if (processedIds.contains(member.id)) continue;

      FamilyMember? spouse;
      if (member.spouseId != null) {
        try {
          spouse = members.firstWhere((m) => m.id == member.spouseId);
        } catch (_) {}
      }

      Offset startPoint;

      if (spouse != null) {
        processedIds.add(spouse.id);
        canvas.drawLine(member.position, spouse.position, spousePaint);
        final centerPos = (member.position + spouse.position) / 2;
        startPoint = centerPos + const Offset(0, halfHeight);
      } else {
        startPoint = member.position + const Offset(0, halfHeight);
      }
      processedIds.add(member.id);

      final Set<String> childrenIds = {...member.childrenIds};
      if (spouse != null) {
        childrenIds.addAll(spouse.childrenIds);
      }

      if (childrenIds.isEmpty) continue;

      List<Offset> childrenTopPoints = [];
      for (var childId in childrenIds) {
        try {
          final child = members.firstWhere((m) => m.id == childId);
          childrenTopPoints.add(child.position - const Offset(0, halfHeight));
        } catch (_) {}
      }

      if (childrenTopPoints.isEmpty) continue;

      double minX = childrenTopPoints.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
      double maxX = childrenTopPoints.map((p) => p.dx).reduce((a, b) => a > b ? a : b);

      double midY = (startPoint.dy + childrenTopPoints.first.dy) / 2;

      final path = Path();
      path.moveTo(startPoint.dx, startPoint.dy);
      path.lineTo(startPoint.dx, midY);

      double barLeft = minX < startPoint.dx ? minX : startPoint.dx;
      double barRight = maxX > startPoint.dx ? maxX : startPoint.dx;

      path.moveTo(barLeft, midY);
      path.lineTo(barRight, midY);

      for (var childTop in childrenTopPoints) {
        path.moveTo(childTop.dx, midY);
        path.lineTo(childTop.dx, childTop.dy);
      }

      canvas.drawPath(path, childLinePaint);
    }

    canvas.restore(); // 캔버스 상태 복구
  }

  @override
  bool shouldRepaint(covariant FamilyTreePainter oldDelegate) {
    return true;
  }
}