// lib/home/MainPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fm2025/home/MainPageViewModel.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainPageViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('게시판 메뉴', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            for (int i = 0; i < vm.boards.length; i++)
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(vm.boards[i].title),
                selected: vm.selectedIndex == i,
                onTap: () {
                  vm.selectBoard(i);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: vm.boards[vm.selectedIndex].posts.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.note),
            title: Text(vm.boards[vm.selectedIndex].posts[index]),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${vm.boards[vm.selectedIndex].posts[index]} 클릭됨')),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: vm.selectedIndex,
        onTap: vm.selectBoard,
        items: [
          for (var b in vm.boards)
            BottomNavigationBarItem(icon: const Icon(Icons.article_outlined), label: b.title),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          vm.addPost('새 글 ${vm.boards[vm.selectedIndex].posts.length + 1}');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
