import 'package:flutter/material.dart';
import 'board_write_page.dart';

class BoardDetailPage extends StatefulWidget {
  String title;
  String content;
  String author;
  String date;
  final int postIndex;

  BoardDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    required this.postIndex,
  });

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  // 내 글인지 확인 (현재는 임시로 '나'로 하드코딩)
  bool get _isMyPost {
    return widget.author == '나';
  }

  // 🚀 게시글 삭제 확인 다이얼로그 띄우기
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('게시글 삭제'),
          content: const Text('정말로 이 게시글을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), // 창 닫기 (취소)
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // 창 닫기
                // 🚀 목록 화면으로 'delete(삭제)' 동작과 몇 번째 글인지 넘겨줌
                Navigator.pop(context, {'action': 'delete', 'index': widget.postIndex});
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // 글 수정 로직
  Future<void> _editPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoardWritePage(
          initialData: {
            'title': widget.title,
            'content': widget.content,
            'author': widget.author,
            'date': widget.date,
          },
          postIndex: widget.postIndex,
        ),
      ),
    );

    if (result != null && result['data'] != null) {
      setState(() {
        widget.title = result['data']['title']!;
        widget.content = result['data']['content']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 보기'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isMyPost) ...[
            // 상단 수정 버튼
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editPost,
            ),
            // 🚀 상단 삭제 버튼 추가
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, size: 24, color: Colors.blueAccent),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.author, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(widget.date, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 300),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(widget.content, style: const TextStyle(fontSize: 16, height: 1.8)),
              ),
              const SizedBox(height: 20),

              // 🚀 하단 버튼 영역 (수정과 삭제 나란히 배치)
              if (_isMyPost)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _editPost,
                      icon: const Icon(Icons.edit),
                      label: const Text('수정'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: const Icon(Icons.delete),
                      label: const Text('삭제'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}