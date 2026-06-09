import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/git_state.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GitGUIApp());
}

class GitGUIApp extends StatelessWidget {
  const GitGUIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GitState(),
      child: MaterialApp(
        title: 'GitGUI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F0F11),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFF97316),
            secondary: Color(0xFF22C55E),
            error: Color(0xFFEF4444),
            surface: Color(0xFF1A1A1F),
          ),
          fontFamily: 'Segoe UI',
          textTheme: const TextTheme(
            headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
            headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3),
            titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
            titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
            bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white70),
            bodySmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white54),
            labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white38, letterSpacing: 1.0),
          ),
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(Colors.white12),
            thickness: WidgetStateProperty.all(5),
            radius: const Radius.circular(6),
          ),
          snackBarTheme: SnackBarThemeData(
            contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
            backgroundColor: const Color(0xFF1A1A1F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
