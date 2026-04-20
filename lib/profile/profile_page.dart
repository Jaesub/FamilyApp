import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // 프로필 이미지 영역
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.person, size: 50, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 16),
            // 사용자 이름 및 역할
            const Text(
              '홍길동',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '아빠 (test@family.com)',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // 메뉴 리스트
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('프로필 수정'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 수정 기능 연결
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('앱 설정'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('알림 설정'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
              onTap: () {
                // TODO: auth_service.dart를 호출하여 로그아웃 로직 실행
              },
            ),
          ],
        ),
      ),
    );
  }
}