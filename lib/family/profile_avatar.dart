import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileAvatar extends StatefulWidget {
  final IconData iconData;
  final double radius;
  final String memberId;
  final bool isEditable; // true면 카메라 아이콘 표시 및 터치 시 갤러리 실행

  const ProfileAvatar({
    Key? key,
    required this.iconData,
    this.radius = 25,
    required this.memberId,
    this.isEditable = false, // 기본값은 '수정 불가(단순 표시용)'로 설정
  }) : super(key: key);

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_${widget.memberId}');

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        if (mounted) {
          setState(() {
            _selectedImage = file;
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    if (!widget.isEditable) return; // 수정 불가능 모드면 아무 동작도 안 함

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
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
      onTap: widget.isEditable ? _pickImage : null,
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
          // isEditable이 true일 때만 우측 하단에 주황색 카메라 뱃지 표시
          if (widget.isEditable)
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