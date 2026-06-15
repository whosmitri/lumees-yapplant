import 'package:flutter/material.dart';

import '../widgets/card_add_planta.dart';

import '../../theme/app_theme.dart';

class TelaAddPlanta extends StatelessWidget {
  const TelaAddPlanta({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo!!'),
      ),
      body: Container(
        width: double.infinity,
        color: AppTheme.auxSand,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Card(
                color: AppTheme.mainIvory,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceReport,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_florist_rounded,
                          size: 64,
                          color: AppTheme.mainGreen,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'Sem plantas no jardim',
                        textAlign: TextAlign.center,
                        style: AppTheme.titleMedium,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Adicione sua primeira planta',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: const CardAddPlanta(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar sua planta'),
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
    );
  }
}