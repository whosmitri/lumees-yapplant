import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';

class TelaRelatorio extends StatefulWidget {
  const TelaRelatorio({super.key});

  @override
  State<TelaRelatorio> createState() => _TelaRelatorioState();
}

class _TelaRelatorioState extends State<TelaRelatorio> {
  bool carregando = false;
  bool sucesso = false;
  String? mensagem;
  String? urlDownload;

  Future<void> _gerarRelatorio() async {
    setState(() {
      carregando = true;
      sucesso = false;
      mensagem = null;
    });

    // SIMULAÇÃO DA API
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      carregando = false;
      sucesso = true;

      mensagem =
          'Relatório CSV processado com sucesso. Link pronto para download.';

      urlDownload =
          'https://storage.googleapis.com/lumees/relatorio.csv';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        title: const Text('Relatório CSV'),
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.auxSand,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 72,
                            color: AppTheme.auxOlive,
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Histórico da Planta',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Exporte todas as medições registradas pelo sistema em formato CSV.',
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  'Dados que serão exportados',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 12),

                                ListTile(
                                  leading: Icon(Icons.water_drop),
                                  title: Text('Umidade do solo'),
                                  dense: true,
                                ),

                                ListTile(
                                  leading: Icon(Icons.thermostat),
                                  title: Text('Temperatura'),
                                  dense: true,
                                ),

                                ListTile(
                                  leading: Icon(Icons.wb_sunny),
                                  title: Text('Luminosidade'),
                                  dense: true,
                                ),

                                ListTile(
                                  leading: Icon(Icons.schedule),
                                  title: Text('Data e horário'),
                                  dense: true,
                                ),

                                ListTile(
                                  leading: Icon(Icons.psychology),
                                  title: Text('Recomendações da IA'),
                                  dense: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed:
                                  carregando ? null : _gerarRelatorio,
                              icon: const Icon(Icons.download),
                              label: const Text(
                                'Gerar Relatório CSV',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.auxOlive,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (carregando)
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Gerando relatório...',
                            ),
                          ],
                        ),
                      ),

                    if (sucesso)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.shade300,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                              size: 48,
                            ),

                            const SizedBox(height: 12),

                            Text(
                              mensagem ?? '',
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // abrir URL futuramente
                                },
                                icon: const Icon(Icons.file_download),
                                label: const Text(
                                  'Baixar CSV',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.green.shade700,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (!carregando &&
                        !sucesso &&
                        mensagem != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.auxDanger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mensagem!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.auxDanger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 3,
      ),
    );
  }
}