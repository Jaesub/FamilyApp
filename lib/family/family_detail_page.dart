import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 데이터를 기기에 저장하기 위한 패키지
import 'family_model.dart';

class FamilyDetailPage extends StatefulWidget {
  final FamilyMember member;
  final List<FamilyMember> allMembers;

  const FamilyDetailPage({
    super.key,
    required this.member,
    required this.allMembers,
  });

  @override
  State<FamilyDetailPage> createState() => _FamilyDetailPageState();
}

class _FamilyDetailPageState extends State<FamilyDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FamilyMember> _siblings = [];

  @override
  void initState() {
    super.initState();
    _initTabs();
  }

  void _initTabs() {
    FamilyMember? parent;
    try {
      parent = widget.allMembers.firstWhere(
            (m) => m.childrenIds.contains(widget.member.id),
      );
    } catch (_) {
      parent = null;
    }

    if (parent != null) {
      _siblings = parent.childrenIds
          .map((id) => widget.allMembers.firstWhere((m) => m.id == id))
          .toList();
    } else {
      _siblings = [widget.member];
    }

    int initialIndex = _siblings.indexOf(widget.member);
    if (initialIndex == -1) initialIndex = 0;

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
              tabs: _siblings.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final member = entry.value;
                return Tab(text: "$index ${member.relation}");
              }).toList(),
            ),
          ),
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

  Widget _buildFamilyView(FamilyMember target) {
    FamilyMember? spouse;
    if (target.spouseId != null) {
      try {
        spouse = widget.allMembers.firstWhere((m) => m.id == target.spouseId);
      } catch (_) {}
    }

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
          .whereType<FamilyMember>()
          .toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${target.relation}네 가족",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPersonCard(member: target, isHighlight: true),
              if (spouse != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(width: 20, height: 2, color: Colors.grey.shade300),
                ),
                _buildPersonCard(member: spouse, isHighlight: false),
              ],
            ],
          ),
          const SizedBox(height: 40),
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

  Widget _buildPersonCard({required FamilyMember member, bool isHighlight = false}) {
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
          EditableProfileAvatar(iconData: Icons.person, radius: 25, memberId: member.id),
          const Spacer(),
          Text(member.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(member.relation, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(member.description, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildChildRow(FamilyMember child) {
    return Row(
      children: [
        Container(
          width: 100,
          height: 120,
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EditableProfileAvatar(iconData: Icons.face, radius: 20, memberId: child.id),
              const SizedBox(height: 10),
              Text(child.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(child.relation, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("상세 정보", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(child.description, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        )
      ],
    );
  }
}

// ==========================================
// 프로필 이미지 선택 및 저장 기능이 포함된 위젯
// ==========================================
class EditableProfileAvatar extends StatefulWidget {
  final IconData iconData;
  final double radius;
  final String memberId;

  const EditableProfileAvatar({
    Key? key,
    required this.iconData,
    this.radius = 25,
    required this.memberId,
  }) : super(key: key);

  @override
  State<EditableProfileAvatar> createState() => _EditableProfileAvatarState();
}

class _EditableProfileAvatarState extends State<EditableProfileAvatar> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedImage(); // 위젯이 화면에 그려질 때 저장된 사진을 불러옵니다.
  }

  // 기기에 저장된 사진 경로를 불러오는 함수
  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    // 멤버 ID를 키값으로 사용하여 저장된 사진 경로를 찾습니다.
    final imagePath = prefs.getString('profile_image_${widget.memberId}');

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) { // 파일이 실제로 기기에 존재하는지 확인
        setState(() {
          _selectedImage = file;
        });
      }
    }
  }

  // 사진을 선택하고 저장하는 함수
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // 선택한 사진의 경로를 기기에 영구적으로 저장합니다.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_${widget.memberId}', pickedFile.path);
      }
    } catch (e) {
      debugPrint("이미지 선택 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
            child: _selectedImage == null
                ? Icon(widget.iconData, size: widget.radius * 1.5, color: Colors.white)
                : null,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFF8F5F),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(widget.radius * 0.3),
            child: Icon(Icons.camera_alt, color: Colors.white, size: widget.radius * 0.5),
          ),
        ],
      ),
    );
  }
}