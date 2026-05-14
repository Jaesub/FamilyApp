import 'package:flutter/material.dart';

class BoardWritePage extends StatefulWidget {
  // 수정 모드를 위해 기존 데이터를 받을 수 있는 변수 추가
  final Map<String, String>? initialData;
  final int? postIndex;

  const BoardWritePage({
    super.key,
    this.initialData, // null이면 새 글 작성, 값이 있으면 글 수정
    this.postIndex,   // 몇 번째 글인지 저장
  });

  @override
  State<BoardWritePage> createState() => _BoardWritePageState();
}

class _BoardWritePageState extends State<BoardWritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 수정 모드일 경우: 넘어온 기존 데이터를 텍스트 필드에 미리 채워넣기
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _contentController.text = widget.initialData!['content'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _savePost() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }

    final savedData = <String, String>{
      'title': _titleController.text,
      'content': _contentController.text,
      'author': widget.initialData?['author'] ?? '나',
      'date': widget.initialData?['date'] ?? DateTime.now().toString().substring(0, 10),
    };

    final result = {
      'data': savedData,
      'index': widget.postIndex,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.initialData == null ? '게시글이 등록되었습니다!' : '게시글이 수정되었습니다!')),
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.initialData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '글 수정하기' : '글쓰기'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _savePost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '내용을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}