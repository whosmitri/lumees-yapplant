import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
//import '../widgets/aba_cadastro.dart';
//import '../widgets/aba_login.dart';

class TelaAuth extends StatelessWidget {
  const TelaAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.mainIvory,

        body: SafeArea(
          child: Stack(
            children: [

              // CABEÇALHO
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
                child: Container(
                  width: double.infinity,
                  height: 230,

                  decoration: BoxDecoration(
                    color: AppTheme.auxSand,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  alignment: Alignment.center,

                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 72),
                    child: Text(
                      "lumees.yapp",
                      style: AppTheme.titleLarge.copyWith(
                        fontSize: 36,
                      ),
                    ),
                  ),
                ),
              ),


              // CARD
              Align(
                alignment: Alignment.topCenter,

                child: Padding(
                  padding: const EdgeInsets.only(top: 170),

                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),

                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 570,
                          maxHeight: 520,
                        ),

                        child: Card(
                          color: AppTheme.mainIvory,
                          elevation: 10,
                          shadowColor: Colors.black.withValues(alpha: 0.2),

                          child: const Padding(
                            padding: EdgeInsets.all(24),

                            child: Column(
                              children: [
                                SizedBox(height: 12),

                                // TAB BAR
                                TabBar(
                                  indicatorColor: AppTheme.auxOlive,
                                  labelColor: AppTheme.mainDark,
                                  unselectedLabelColor: Colors.grey,

                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),

                                  tabs: [
                                    Tab(text: "Criar Conta"),
                                    Tab(text: "Entrar"),
                                  ],
                                ),


                                // CONTEÚDO
                                Expanded(
                                  child: TabBarView(

                                    children: [
                                      Text('cadastro'),
                                      Text('login')
                                      //AbaCadastro(),
                                      //AbaLogin(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}