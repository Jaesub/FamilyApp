import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'app.dart';

void main() {
  KakaoSdk.init(
    nativeAppKey: '카카오_네이티브_앱키',
  );

  runApp(const MyApp());
}