import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    String route = "";

    switch (index) {
      case 0:
        route = '/jardim';
        break;

      case 1:
        route = '/dashboard';
        break;

      case 2:
        route = '/diagnostico';
        break;

      case 3:
        route = '/relatorio';
        break;

      case 4:
        route = '/usuario';
        break;

      default:
        route = '/jardim';;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (route) => false,
    );

    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    ); */
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          0,
          18,
          18,
        ),

        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.mainIvory,

            borderRadius: BorderRadius.circular(40),

            boxShadow: const [
              BoxShadow(
                blurRadius: 16,
                offset: Offset(0, 6),
                color: Color(0x22000000),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),

            child: BottomNavigationBar(
              currentIndex: currentIndex,

              onTap: (index) => _navigate(
                context,
                index,
              ),

              type: BottomNavigationBarType.fixed,
              backgroundColor: AppTheme.mainIvory, // cor de fundo
              elevation: 0,
              selectedItemColor: AppTheme.mainDark, // ícone selecionado
              unselectedItemColor: AppTheme.auxOlive, // ícone não selecionado
              showSelectedLabels: false,

              showUnselectedLabels: false,

              items: const [

                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Principal',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: 'Dashboard',
                ),

                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.sparkles),
                  label: 'Lee IA',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.download_rounded),
                  label: 'Relatório',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Usuário',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}