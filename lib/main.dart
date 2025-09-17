import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/MainPage.dart';
import 'home/MainPageViewModel.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MainPageViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow)),
      home: const MainPage(title: 'Family App'),
    );
  }
}
