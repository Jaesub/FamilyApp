import 'package:flutter/material.dart';
import '../board/board_page.dart';
import '../board/board_controller.dart';
import '../family/family_page.dart';
import '../models/user.dart';
import '../schedule/schedule_page.dart';
import '../schedule/schedule_controller.dart';
import '../ai/ai_chat_page.dart'; // 🚀 AI 페이지 임포트

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  final Future<void> Function() onLogout;
  final Future<void> Function(BuildContext) onLoginRequested;
  final User? user;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.onLogout,
    required this.onLoginRequested,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final BoardController _boardController = BoardController();
  final ScheduleController _scheduleController = ScheduleController();

  void _onSelectMenu(int index) {
    // Drawer에서 호출될 때는 pop을 하지만, BottomNavigationBar에서는 안 하므로 구분 필요
    // 여기서는 Drawer에서만 호출된다고 가정하고 pop을 유지합니다.
    Navigator.pop(context);
    setState(() {
      _selectedIndex = index;
    });
  }

  // 🚀 화면 5개 연결 (홈, 게시판, AI, 가계도, 일정)
  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return const Center(child: Text("🏠 홈 화면", style: TextStyle(fontSize: 24)));
      case 1:
        return BoardPage(controller: _boardController);
      case 2:
        return const AiChatPage(); // 🚀 AI 화면을 2번 인덱스로 할당
      case 3:
        return const FamilyPage(); // 가계도
      case 4:
        return SchedulePage(controller: _scheduleController); // 일정
      default:
        return const Center(child: Text("알 수 없는 화면"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = widget.user != null;

    return Scaffold(
      appBar: AppBar(title: const Text("가족사랑 앱 💖")),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                loggedIn ? (widget.user!.displayName) : "로그인이 필요합니다",
              ),
              accountEmail: Text(
                loggedIn ? (widget.user!.email) : "이메일 미지정",
              ),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  loggedIn
                      ? widget.user!.displayName.characters.first
                      : '🙂',
                ),
              ),
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
            // 🚀 좌측 서랍장 메뉴에도 AI 추가
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text("AI 조수"),
              selected: _selectedIndex == 2,
              onTap: () => _onSelectMenu(2),
            ),
            ListTile(
              leading: const Icon(Icons.family_restroom),
              title: const Text("가계도"),
              selected: _selectedIndex == 3,
              onTap: () => _onSelectMenu(3),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("일정"),
              selected: _selectedIndex == 4,
              onTap: () => _onSelectMenu(4),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text("다크모드"),
              value: widget.isDarkMode,
              onChanged: (_) => widget.onToggleDarkMode(),
            ),
            if (!loggedIn)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text("로그인"),
                onTap: () async {
                  Navigator.pop(context);
                  await widget.onLoginRequested(context);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("로그인 되었습니다.")),
                  );
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("로그아웃"),
                onTap: () async {
                  Navigator.pop(context);
                  await widget.onLogout();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("로그아웃 되었어요.")),
                  );
                },
              ),
          ],
        ),
      ),
      body: _getPage(),
      // 🚀 하단 탭에 AI 아이콘 추가
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selectedIndex = i), // BottomNavigationBar용 탭 이벤트
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "게시판"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "AI"), // 🚀 중앙에 AI 탭 추가
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: "가계도"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "일정"),
        ],
      ),
    );
  }
}