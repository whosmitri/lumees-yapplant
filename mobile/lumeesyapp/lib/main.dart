import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

import 'pages/TelaHome.dart';
import 'pages/TelaPrincipal.dart';
import 'pages/TelaDashboard.dart';
import 'pages/TelaRelatorio.dart';
//import 'pages/TelaDiagnostico.dart';
//import 'pages/TelaUsuario.dart';

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
        // adicionar depois
        // '/autenticacao': (context) => const TelaAutenticacao(),
        '/principal': (context) => const TelaPrincipalWidget(),
        '/dashboard': (context) => const TelaDashboardWidget(),
        '/relatorio': (context) => const TelaRelatorio(),
      },
    );
  }
}