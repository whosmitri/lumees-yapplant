import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';

class TelaDiagnostico extends StatefulWidget {
  const TelaDiagnostico({super.key});

  @override
  State<TelaDiagnostico> createState() => _TelaDiagnosticoState();
}

class _TelaDiagnosticoState extends State<TelaDiagnostico> {
  bool carregando = false;
  bool possuiResultado = false;

  String estadoClassificado = '';
  String textoExplicativo = '';
  String? mensagemErro;

  // =================
  // API
  Future<void> analisarPlanta() async {
    setState(() {
      carregando = true;
      possuiResultado = false;
    });

    try {
      final resultado =
          await ApiService.analisarPlanta();

      setState(() {
          estadoClassificado = resultado["estado_classificado"];
          textoExplicativo = resultado["texto_explicativo"];

          possuiResultado = true;
      });
    }

    catch(e){
      setState(() {
        mensagemErro = e.toString();
      });
    }

    finally{
        setState((){
            carregando = false;
        });
    }
  }
  // =================

  Color getCorDiagnostico() {
    switch (estadoClassificado.toLowerCase()) {
      case "excelente":
        return Colors.green.shade700;

      case "bom":
        return AppTheme.mainGreen;

      case "razoável":
        return Colors.amber.shade700;

      case "ruim":
        return Colors.orange.shade700;

      case "crítico":
        return AppTheme.auxDanger;

      default:
        return AppTheme.auxOlive;
    }
  }

  IconData getIconeDiagnostico() {
    switch (estadoClassificado.toLowerCase()) {
      case "excelente":
        return Icons.sentiment_very_satisfied;

      case "bom":
        return Icons.check_circle;

      case "razoável":
        return Icons.sentiment_neutral;

      case "ruim":
        return Icons.warning_amber_rounded;

      case "crítico":
        return Icons.dangerous;

      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Diagnóstico do Lee IA"),
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
      
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [

                  // TOPO
                  Image.asset(
                    "assets/images/bgs/lee.png",
                    height: 170,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Lee",
                    style: AppTheme.titleLarge,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Assistente Inteligente do Lumees",
                    style: AppTheme.bodyMedium,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.psychology),
                      label: const Text("Analisar Planta"),
                      onPressed: carregando ? null : analisarPlanta,
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (carregando)
                    Column(
                      children: const [

                        CircularProgressIndicator(),

                        SizedBox(height: 18),

                        Text(
                          "Lee está analisando sua planta...",
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),

                  if (mensagemErro != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.auxDanger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.auxDanger),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.auxDanger,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mensagemErro!,
                              style: const TextStyle(
                                color: AppTheme.mainDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (possuiResultado) ...[

                    // CARD DIAGNÓSTICO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: AppTheme.auxSand,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Icon(
                            getIconeDiagnostico(),
                            size: 70,
                            color: getCorDiagnostico(),
                          ),

                          const SizedBox(width: 20),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                const Text(
                                  "Diagnóstico",
                                  style: AppTheme.titleMedium,
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  estadoClassificado,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.auxOlive,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CARD EXPLICAÇÃO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: AppTheme.auxSand,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Row(
                            children: [

                              const Icon(
                                Icons.description_outlined,
                                color: AppTheme.auxOlive,
                              ),

                              const SizedBox(width: 10),

                              Text(
                                "Explicação do Lee",
                                style: AppTheme.titleSmall.copyWith(
                                  color: AppTheme.auxOlive,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Text(
                            textoExplicativo,
                            style: AppTheme.bodyMedium,
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 2,
      ),
    );
  }
}