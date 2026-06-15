import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/season_service.dart';
import '../services/time_service.dart';
import '../services/location_service.dart';

import '../theme/app_theme.dart';

import '../widgets/app_bottom_navigation.dart';
import '../widgets/card_sensor.dart';
import '../widgets/card_info.dart';

class TelaJardim extends StatefulWidget {
  const TelaJardim({super.key});

  @override
  State<TelaJardim> createState() => _TelaJardimState();
}

class _TelaJardimState extends State<TelaJardim> {

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final LocationService _locationService = LocationService();
  final SeasonService _seasonService = SeasonService();
  final TimeService _timeService = TimeService();

  String _season = "...";
  String _dayPeriod = "...";

  @override
  void initState() {
    super.initState();
    _loadEnvironment();
  }

  Future<void> _loadEnvironment() async {
    try {
      final position = await _locationService.getCurrentLocation();

      final season =_seasonService.getSeason(position.latitude);

      final dayPeriod = await _timeService.getDayPeriod(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _season = season;
        _dayPeriod = dayPeriod;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _season = "--";
        _dayPeriod = "--";
      });

      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {    
    final size = MediaQuery.of(context).size;

    final bool desktop = size.width >= 1200;
    final bool tablet = size.width >= 700;

    final double imagemLargura =
        desktop ? 430 : tablet ? 360 : 280;

    final double imagemAltura =
        desktop ? 520 : tablet ? 430 : 330;

    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Usuário não autenticado"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.mainIvory,

      
      // APP BAR
      appBar: AppBar(
        backgroundColor: AppTheme.mainIvory,
        elevation: 0,
        title: const Text("Bem-vindo!!"),
      ),

      
      // BODY
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // define a altura do painel inferior proporcional à tela (40% da altura total)
            final double painelAltura = constraints.maxHeight * 0.40;
            
            // o espaço do background será tudo menos o painel (com uma pequena folga para a curva do topo)
            final double bgAltura = constraints.maxHeight - painelAltura + 30;

            return Stack(
              children: [
                
                // BACKGROUND DINÂMICO
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: bgAltura, // cresce ou diminui baseado no tamanho da tela
                  child: Image.asset(
                    _dayPeriod == "Dia"
                      ? "assets/images/bgs/bg_principal_dia.png"
                      : "assets/images/bgs/bg_principal_noite.png",
                    fit: BoxFit.cover,
                  ),
                ),

                
                // IMAGEM DA PLANTINHA (centralizada na área do background)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: painelAltura - 20, // garante que a planta fique acima do painel
                  child: Center(
                    child: SizedBox(
                      width: imagemLargura,
                      height: imagemAltura,
                      child: Image.asset(
                        "assets/images/estados_planta/estado-normal.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                
                // BALÃO DE FALA (ajustado em relação à planta)
                Positioned(
                  top: bgAltura * 0.15, // posiciona a 15% do topo da área visível do fundo
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Estou bem!!",
                        style: AppTheme.titleSmall,
                      ),
                    ),
                  ),
                ),

                
                // PAINEL INFERIOR FLUTUANTE
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: painelAltura, // altura dinâmica baseada na proporção da tela
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.auxSand,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // TÍTULO
                          const Text(
                            "Ambiente",
                            style: AppTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),

                          StreamBuilder(
                            stream: _databaseService.buscarPlanta(user.uid),
                            builder: (context, snapshot) {

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  "Nenhuma planta cadastrada.",
                                );
                              }

                              final planta = snapshot.data!.docs.first.data();

                              return Column(
                                children: [
                                  Wrap(
                                    spacing: 18,
                                    runSpacing: 18,
                                    alignment: WrapAlignment.center,

                                    children: [
                                      SensorCard(
                                        icon: Icons.water_drop_rounded,
                                        iconColor: Colors.blue,
                                        titulo: "Umidade do Solo",
                                        valor:"${planta['ultima_leitura']['umidade_solo_porcentagem']}%",
                                      ),


                                      SensorCard(
                                        icon: Icons.wb_sunny_rounded,
                                        iconColor: Colors.amber,
                                        titulo: "Luminosidade",
                                        valor: "${planta['ultima_leitura']['luminosidade']} lx",
                                      ),
                                    ],
                                  ),

                                  Wrap(
                                    spacing: 18,
                                    runSpacing: 18,
                                    alignment: WrapAlignment.center,

                                    children: [
                                      SensorCard(
                                        icon: Icons.thermostat_rounded,
                                        iconColor: Colors.deepOrange,
                                        titulo: "Temperatura do Ar",
                                        valor: "${planta['ultima_leitura']['temperatura_ar']}°C",
                                      ),

                                      SensorCard(
                                        icon: Icons.cloud_queue_rounded,
                                        iconColor: Colors.lightBlue,
                                        titulo: "Umidade do Ar",
                                        valor: "${planta['ultima_leitura']['umidade_ar']}%",
                                      ),
                                    ],
                                  ),

                                  Wrap(
                                    spacing: 18,
                                    runSpacing: 18,
                                    alignment: WrapAlignment.center,

                                    children: [
                                      InfoCard(
                                        icon: Icons.energy_savings_leaf_rounded,
                                        iconColor: AppTheme.mainGreen,
                                        texto: "Estação do ano: $_season",
                                      ),

                                      InfoCard(
                                        icon: Icons.wb_twilight_rounded,
                                        iconColor: AppTheme.mainGreen,
                                        texto: "Período do dia: $_dayPeriod",
                                      ),
                                    ],
                                  )
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 0,
      ),
    );
  }
}