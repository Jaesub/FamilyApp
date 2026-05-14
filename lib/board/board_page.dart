import 'package:flutter/material.dart';
import 'board_controller.dart';
import 'board_detail_page.dart';
import 'board_write_page.dart';

class BoardPage extends StatefulWidget {
  final BoardController controller;

  const BoardPage({
    super.key,
    required this.controller,
  });

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  // 게시글 데이터를 저장할 리스트 (임시 데이터 2개 포함)
  List<Map<String, String>> posts = [
    {
      'title': '가족사랑 앱을 시작합니다! 🎉',
      'content': '우리 가족만의 소중한 공간이 생겼어요. 앞으로 이곳에 즐거운 이야기들을 많이 남겨보아요!',
      'author': '시스템',
      'date': '2024-05-20',
    },
    {
      'title': '이번 주말 가족 식사 메뉴 정하기',
      'content': '이번 주말에 다 같이 밥 먹을 건데 다들 뭐 먹고 싶어? 댓글 남겨줘~',
      'author': '아빠',
      'date': '2024-05-20',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공유 게시판'),
        centerTitle: true,
        elevation: 0,
      ),
      body: posts.isEmpty
          ? const Center(child: Text("아직 작성된 게시글이 없습니다."))
          : ListView.builder(
        itemCount: posts.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          final post = posts[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.article, color: Colors.white),
              ),
              title: Text(
                post['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('작성자: ${post['author']} • ${post['date']}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                // 리스트를 누르면 상세 페이지로 이동하며 postIndex 넘겨주기
                final updatedResult = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BoardDetailPage(
                      title: post['title']!,
                      content: post['content']!,
                      author: post['author']!,
                      date: post['date']!,
                      postIndex: index, // 몇 번째 글인지 인덱스 전달
                    ),
                  ),
                );

                // 상세 화면에서 돌아왔을 때, 삭제 신호인지 수정 신호인지 판단!
                if (updatedResult != null) {
                  // 1. 삭제된 경우
                  if (updatedResult['action'] == 'delete') {
                    setState(() {
                      posts.removeAt(updatedResult['index']); // 리스트에서 항목 제거
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('게시글이 삭제되었습니다.')),
                    );
                  }
                  // 2. 수정된 경우
                  else if (updatedResult['data'] != null && updatedResult['index'] != null) {
                    setState(() {
                      posts[updatedResult['index']] = Map<String, String>.from(updatedResult['data']);
                    });
                  }
                }
              },
            ),
          );
        },
      ),
      // 새 글 쓰기 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 글쓰기 페이지로 이동
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BoardWritePage(),
            ),
          );

          // 새 글 작성 데이터가 돌아왔다면 리스트 맨 위에 추가
          if (result != null && result['data'] != null) {
            setState(() {
              posts.insert(0, Map<String, String>.from(result['data']));
            });
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}