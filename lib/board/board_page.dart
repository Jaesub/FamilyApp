import 'package:flutter/material.dart';
import 'board_controller.dart';
import 'board_model.dart';

// 게시판 페이지
class BoardPage extends StatefulWidget {
  final BoardController controller; // 외부에서 입력받음
  const BoardPage({super.key, required this.controller});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  //final BoardController _controller = BoardController();

  void _addPost() {
    setState(() { // setState() 가 상태 변경 후 UI 즉시 갱신
      widget.controller.addPost();
    });
  }

  void _deletePost(Post post) {
    setState(() {
      widget.controller.removePost(post);
    });
  }

  void _clearPosts() {
    setState(() {
      widget.controller.clearPosts();
    });
  }

  // 게시글 수정
  void _editPost(Post post) {
    final TextEditingController textController =
    TextEditingController(text: post.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("게시글 수정"),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: "새 제목을 입력하세요",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.controller.updatePost(post, textController.text);
                });
                Navigator.pop(context);
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = widget.controller.posts;  // widget.controller 사용

    return Scaffold(  // 화면 기본 구조
      appBar: AppBar( // 상단 바
        title: const Text("게시판"),
        actions: [  // 오른쪽 아이콘들
          IconButton(
            onPressed: _clearPosts,
            icon: const Icon(Icons.delete_forever),
          ),
        ],
      ),
      body: posts.isEmpty
          ? const Center(child: Text("아직 게시글이 없어요 😢"))
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            child: ListTile(
              title: Text(post.title),
              onTap: ()=> _editPost(post),  // 클릭시 수정
              trailing: IconButton( // 오른쪽 끝에 들어가는 버튼
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletePost(post),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPost,
        tooltip: '새 글 추가',
        child: const Icon(Icons.add),
      ),
    );
  }
}
