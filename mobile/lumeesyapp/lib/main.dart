import 'package:flutter/material.dart';
import 'pages/TelaHome.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const LumeesApp());
}

class LumeesApp extends StatelessWidget {
  const LumeesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumees',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const TelaHome(),

      routes: {
        '/': (context) => const TelaHome(),

        // adicionar depois
        // '/autenticacao': (context) => const TelaAutenticacao(),
        // '/dashboard': (context) => const TelaDashboard(),
        // '/relatorio': (context) => const TelaRelatorio(),
      },
    );
  }
}