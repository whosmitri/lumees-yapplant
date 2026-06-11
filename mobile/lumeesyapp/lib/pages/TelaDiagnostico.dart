import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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

  Future<void> analisarPlanta() async {
    setState(() {
      carregando = true;
      possuiResultado = false;
    });

    // =================
    // SIMULAÇÃO DA API

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      carregando = false;
      possuiResultado = true;

      estadoClassificado = "Saudável";

      textoExplicativo =
          "Sua planta apresentou uma boa estabilidade da umidade do solo durante os últimos sete dias. O modelo KNN identificou que os valores permanecem dentro da faixa considerada saudável. Continue mantendo os cuidados atuais.";
    });
    // =================
  }

  Color getCorDiagnostico() {
    switch (estadoClassificado.toLowerCase()) {
      case "saudável":
      case "saudavel":
        return Colors.green;

      case "atenção":
      case "atencao":
        return Colors.orange;

      case "crítico":
      case "critico":
        return AppTheme.auxDanger;

      default:
        return AppTheme.auxOlive;
    }
  }

  IconData getIconeDiagnostico() {
    switch (estadoClassificado.toLowerCase()) {
      case "saudável":
      case "saudavel":
        return Icons.check_circle;

      case "atenção":
      case "atencao":
        return Icons.warning_amber_rounded;

      case "crítico":
      case "critico":
        return Icons.error;

      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainIvory,

      appBar: AppBar(
        title: const Text("Diagnóstico do Lee IA"),
      ),

      body: SafeArea(
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
    );
  }
}