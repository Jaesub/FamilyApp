import 'package:flutter/material.dart';
import '../board/board_page.dart';
import '../board/board_controller.dart';
import '../family/family_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  //final VoidCallback onLogout;
  final Future<void> Function() onLogout;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.onLogout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // 게시판 컨트롤러를 HomePage에서 관리 (한번만 생성)
  final BoardController _boardController = BoardController();

  void _onSelectMenu(int index) {
    Navigator.pop(context);
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return const Center(child: Text("🏠 홈 화면", style: TextStyle(fontSize: 24)));
      case 1:
        return BoardPage(controller: _boardController);
      case 2:
        return const FamilyPage();
      default:
        return const Center(child: Text("알 수 없는 화면"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("가족사랑 앱 💖")),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader( // 추후 로그인 정보
              accountName: const Text("원희님"),
              accountEmail: const Text("wongldia@google.com"),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("홈"),
              selected: _selectedIndex == 0,
              onTap: () => _onSelectMenu(0),
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text("게시판"),
              selected: _selectedIndex == 1,
              onTap: () => _onSelectMenu(1),
            ),
            ListTile(
              leading: const Icon(Icons.family_restroom),
              title: const Text("가계도"),
              selected: _selectedIndex == 2,
              onTap: () => _onSelectMenu(2),
            ),
            SwitchListTile(
              title: const Text("다크모드"),
              value: widget.isDarkMode,
              onChanged: (_) => widget.onToggleDarkMode(),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("로그아웃"),
              onTap: () async {
                Navigator.pop(context);
                await widget.onLogout(); // 실제 로그아웃
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("로그아웃 되었어요.")));
              },
            ),
          ],
        ),
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "게시판"),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: "가계도"),
        ],
      ),
    );
  }
}
