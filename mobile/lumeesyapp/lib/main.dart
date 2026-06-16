import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

import './services/firebase_service.dart';

import 'pages/TelaHome.dart';
import 'pages/TelaAuth.dart';
import 'pages/TelaJardim.dart';
import 'pages/TelaDashboard.dart';
import 'pages/TelaRelatorio.dart';
import 'pages/TelaDiagnostico.dart';
import 'pages/TelaAddPlanta.dart';
//import 'pages/TelaUsuario.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // inicializa firebase
  await FirebaseService.initialize();

  // inicializa o app
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
        '/autenticacao': (_) => const TelaAuth(),
        '/add_planta': (_) => const TelaAddPlanta(),
        '/jardim': (_) => const TelaJardim(),
        '/dashboard': (_) => const TelaDashboardWidget(),
        '/diagnostico': (_) => const TelaDiagnostico(),
        '/relatorio': (_) => const TelaRelatorio(),
        // // '/autenticacao': (_) => const TelaUsuario(),
      },
    );
  }
}