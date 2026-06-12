import 'package:flutter/material.dart';

import '../widgets/app_bottom_navigation.dart';
import '../widgets/air_humidity_chart.dart';
import '../widgets/light_chart.dart';
import '../widgets/soil_humidity_chart.dart';
import '../widgets/temperature_chart.dart';

class TelaDashboardWidget extends StatelessWidget {
  const TelaDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // A partir dessa largura mostramos 2 gráficos por linha
    final bool isWideScreen = screenWidth >= 900;

    // Largura máxima de cada card
    final double cardWidth = isWideScreen ? 520 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1200,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,

                children: [
                  SizedBox(
                    width: cardWidth,
                    child: SoilHumidityChart(
                      data: const [
                        SoilHumidityData(
                          hour: '13h',
                          humidity: 72,
                        ),
                        SoilHumidityData(
                          hour: '14h',
                          humidity: 58,
                        ),
                        SoilHumidityData(
                          hour: '15h',
                          humidity: 80,
                        ),
                        SoilHumidityData(
                          hour: '16h',
                          humidity: 43,
                        ),
                        SoilHumidityData(
                          hour: '17h',
                          humidity: 67,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: cardWidth,
                    child: LightChart(
                      data: const [
                        LightData(
                          hour: '13h',
                          lux: 5200,
                        ),
                        LightData(
                          hour: '14h',
                          lux: 8100,
                        ),
                        LightData(
                          hour: '15h',
                          lux: 6800,
                        ),
                        LightData(
                          hour: '16h',
                          lux: 4200,
                        ),
                        LightData(
                          hour: '17h',
                          lux: 2100,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: cardWidth,
                    child: TemperatureChart(
                      data: const [
                        TemperatureData(
                          hour: '13h',
                          temperature: 28,
                        ),
                        TemperatureData(
                          hour: '14h',
                          temperature: 31,
                        ),
                        TemperatureData(
                          hour: '15h',
                          temperature: 34,
                        ),
                        TemperatureData(
                          hour: '16h',
                          temperature: 32,
                        ),
                        TemperatureData(
                          hour: '17h',
                          temperature: 27,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: cardWidth,
                    child: AirHumidityChart(
                      data: const [
                        AirHumidityData(
                          hour: '13h',
                          humidity: 45,
                        ),
                        AirHumidityData(
                          hour: '14h',
                          humidity: 78,
                        ),
                        AirHumidityData(
                          hour: '15h',
                          humidity: 55,
                        ),
                        AirHumidityData(
                          hour: '16h',
                          humidity: 90,
                        ),
                        AirHumidityData(
                          hour: '17h',
                          humidity: 62,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 1,
      ),
    );
  }
}