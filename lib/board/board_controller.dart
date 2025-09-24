import 'board_model.dart';

class BoardController {
  final List<Post> _posts = [];

  List<Post> get posts => List.unmodifiable(_posts);

  void addPost() {
    int next = _posts.length + 1;
    _posts.add(Post("📌 게시글 $next"));
  }

  void removePost(Post post) {
    _posts.remove(post);
  }

  void clearPosts() {
    _posts.clear();
  }

  // 글 수정 기능 추가
  void updatePost(Post post, String newTitle) {
    final index = _posts.indexOf(post);
    if (index != -1) {
      _posts[index] = Post(newTitle);
    }
  }
}
