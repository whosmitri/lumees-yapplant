import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/season_service.dart';

import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';

class TelaDiagnostico extends StatefulWidget {
  const TelaDiagnostico({super.key});

  @override
  State<TelaDiagnostico> createState() => _TelaDiagnosticoState();
}

class _TelaDiagnosticoState extends State<TelaDiagnostico> {
  // Inicialização dos serviços
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final LocationService _locationService = LocationService();
  final SeasonService _seasonService = SeasonService();

  bool carregando = false;
  bool possuiResultado = false;

  String estadoClassificado = '';
  String textoExplicativo = '';
  String? mensagemErro;

  // =================
  // API INTEGRADA COM FIREBASE
  Future<void> analisarPlanta() async {
    setState(() {
      carregando = true;
      possuiResultado = false;
      mensagemErro = null; // Limpa erros anteriores
    });

    try {
      // 1. Pegar usuário logado
      final usuario = _authService.currentUser;
      if (usuario == null) throw Exception("Usuário não autenticado.");

      // 2. Pegar a planta do usuário no Firestore (usando .first para leitura única e rápida)
      final snapshot = await _databaseService.buscarPlanta(usuario.uid).first;
      if (snapshot.docs.isEmpty) throw Exception("Você não possui nenhuma planta cadastrada.");

      final planta = snapshot.docs.first.data();
      final idPlanta = planta['id_planta'];
      final hashEspecie = planta['id_especie'];

      // 3. Buscar a espécie no catálogo para pegar o NOME em texto (que o Python espera)
      final especieDoc = await _databaseService.obterEspeciePorId(hashEspecie);
      if (especieDoc == null) throw Exception("Espécie da planta não encontrada no catálogo.");

      // O Python espera algo como "suculenta", "lirio_paz", etc.
      // Vamos pegar o nome comum, jogar pra minúsculo e tirar acentos/espaços por segurança!
      String nomeEspecie = especieDoc['nome_comum'].toString().toLowerCase();
      nomeEspecie = nomeEspecie
          .replaceAll(" ", "_")
          .replaceAll("í", "i")
          .replaceAll("á", "a")
          .replaceAll("é", "e")
          .replaceAll("ã", "a");

      // 4. Descobrir a estação do ano real (com fallback para não travar a apresentação se o GPS falhar)
      String estacaoAtual = "Verão";
      try {
        final pos = await _locationService.getCurrentLocation();
        estacaoAtual = _seasonService.getSeason(pos.latitude);
      } catch (_) {
        debugPrint("Falha ao pegar localização. Usando Verão como padrão.");
      }

      // 5. Enviar para a API!
      final resultado = await ApiService.analisarPlanta(
        idPlanta: idPlanta,
        idEspecie: nomeEspecie,
        estacaoAno: estacaoAtual,
      );

      setState(() {
          estadoClassificado = resultado["estado_classificado"];
          textoExplicativo = resultado["texto_explicativo"];
          possuiResultado = true;
      });

    } catch(e) {
      setState(() {
        // Remove a palavra "Exception:" feia da frente da mensagem pro usuário
        mensagemErro = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
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
                    "assets/images/lee/robot_lee.png",
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