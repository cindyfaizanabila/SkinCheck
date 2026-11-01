import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme.dart';

void main() => runApp(const SkinCheckApp());

class SkinCheckApp extends StatelessWidget {
  const SkinCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinCheck',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}
