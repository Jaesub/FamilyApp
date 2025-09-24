import 'package:flutter/material.dart';
import 'home/home_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가족사랑 앱 💖',
      theme: _isDarkMode
          ? ThemeData.dark()
          : ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: HomePage(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
      ),
    );
  }
}
