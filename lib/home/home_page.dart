import 'package:flutter/material.dart';
import '../board/board_page.dart';
import '../board/board_controller.dart';
import '../family/family_page.dart';
import '../models/user.dart';
import '../schedule/schedule_page.dart';
import '../schedule/schedule_controller.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  //final VoidCallback onLogout;
  final Future<void> Function() onLogout;
  final Future<void> Function(BuildContext) onLoginRequested; // 로그인 요청 콜백
  final User? user; // 현재 로그인 사용자

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

  // 게시판 컨트롤러를 HomePage에서 관리 (한번만 생성)
  final BoardController _boardController = BoardController();
  // 스케줄 컨트롤러
  final ScheduleController _scheduleController = ScheduleController();

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
        return FamilyPage();
      case 3:
        return SchedulePage(controller: _scheduleController);
      default:
        return const Center(child: Text("알 수 없는 화면"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = widget.user != null; // 로그인 여부
    return Scaffold(
      appBar: AppBar(title: const Text("가족사랑 앱 💖")),
      drawer: Drawer(
        child: ListView(
          children: [
            // 로그인 여부에 따른 헤더 표시
            UserAccountsDrawerHeader(
            //   accountName: const Text("원희님"),
            //   accountEmail: const Text("wongldia@google.com"),
            // ),
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
            ListTile(
              leading: const Icon(Icons.family_restroom),
              title: const Text("가계도"),
              selected: _selectedIndex == 2,
              onTap: () => _onSelectMenu(2),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("일정"),
              selected: _selectedIndex == 3,
              onTap: () => _onSelectMenu(3),
            ),
            SwitchListTile(
              title: const Text("다크모드"),
              value: widget.isDarkMode,
              onChanged: (_) => widget.onToggleDarkMode(),
            ),

            // ListTile(
            //   leading: const Icon(Icons.logout),
            //   title: const Text("로그아웃"),
            //   onTap: () async {
            //     Navigator.pop(context);
            //     await widget.onLogout(); // 실제 로그아웃 _goLogin() 호출되어 LoginPage로 교체됨
            //     if (!mounted) return;
            //     ScaffoldMessenger.of(context)
            //         .showSnackBar(const SnackBar(content: Text("로그아웃 되었어요.")));
            //   },
            // ),

            // 로그인/로그아웃 메뉴를 조건부로 렌더링
            if (!loggedIn)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text("로그인"),
                onTap: () async {
                  Navigator.pop(context); // Drawer 닫기
                  await widget.onLoginRequested(context); // LoginPage로 이동하여 로그인 처리
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
                  await widget.onLogout(); // 상태만 초기화
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "게시판"),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: "가계도"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "일정"),
        ],
      ),
    );
  }
}
