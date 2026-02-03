// lib/family/family_model.dart
import 'package:flutter/material.dart';

class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final String imageUrl;
  final String description;
  final Offset position;
  final List<String> childrenIds;
  final String? spouseId;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    this.imageUrl = "",
    required this.description,
    required this.position,
    List<String>? childrenIds,
    this.spouseId
  }) : childrenIds = childrenIds ?? [];
}