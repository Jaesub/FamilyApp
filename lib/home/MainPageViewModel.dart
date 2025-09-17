// lib/home/MainPageViewModel.dart
import 'package:flutter/material.dart';
import 'package:fm2025/home/Model/BoardModel.dart';


class MainPageViewModel extends ChangeNotifier {
  int selectedIndex = 0;

  final List<Board> boards = [
    Board(title: '공지사항', posts: ['공지1', '공지2', '공지3']),
    Board(title: '자유게시판', posts: ['자유1', '자유2']),
    Board(title: 'Q&A', posts: ['Q&A1', 'Q&A2']),
  ];

  void selectBoard(int index) {
    selectedIndex = index;
    notifyListeners(); // View에 변경 알림
  }

  void addPost(String post) {
    boards[selectedIndex].posts.add(post);
    notifyListeners();
  }
}