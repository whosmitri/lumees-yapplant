import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

import '../widgets/card_sensor.dart';
import '../widgets/card_info.dart';

class TelaJardim extends StatefulWidget {
  const TelaJardim({super.key});

  @override
  State<TelaJardim> createState() => _TelaJardimState();
}

class _TelaJardimState extends State<TelaJardim> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bool desktop = size.width >= 1200;
    final bool tablet = size.width >= 700;

    final double imagemLargura =
        desktop ? 430 : tablet ? 360 : 280;

    final double imagemAltura =
        desktop ? 520 : tablet ? 430 : 330;

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
                    "assets/images/bgs/bg_principal_dia.png",
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
                          
                          Wrap(
                            spacing: 18,
                            runSpacing: 18,
                            alignment: WrapAlignment.center,

                            children: [
                              SensorCard(
                                icon: Icons.water_drop_rounded,
                                iconColor: Colors.blue,
                                titulo: "Umidade do Solo",
                                valor: "20%",
                              ),

                              SensorCard(
                                icon: Icons.wb_sunny_rounded,
                                iconColor: Colors.amber,
                                titulo: "Luminosidade",
                                valor: "3000 lx",
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
                                valor: "28°C",
                              ),

                              SensorCard(
                                icon: Icons.cloud_queue_rounded,
                                iconColor: Colors.lightBlue,
                                titulo: "Umidade do Ar",
                                valor: "64%",
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
                                texto: "Estação do ano: Outono",
                              ),

                              InfoCard(
                                icon: Icons.wb_twilight_rounded,
                                iconColor: AppTheme.mainGreen,
                                texto: "Período do dia: Dia",
                              ),
                            ],
                          )
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
    );
  }
}