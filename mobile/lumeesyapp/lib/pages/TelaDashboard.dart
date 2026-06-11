import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';
import '../widgets/soil_humidity_chart.dart';
import '../widgets/light_chart.dart';
import '../widgets/temperature_chart.dart';
import '../widgets/air_humidity_chart.dart';

class TelaDashboardWidget extends StatelessWidget {
  const TelaDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.mainIvory,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.mainDark,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              /// ==========================
              /// UMIDADE DO SOLO
              /// ==========================
              SoilHumidityChart(
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

              const SizedBox(height: 20),

              /// ==========================
              /// LUMINOSIDADE
              /// ==========================
              LightChart(
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

              const SizedBox(height: 20),

              /// ==========================
              /// TEMPERATURA DO AR
              /// ==========================
              TemperatureChart(
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

              const SizedBox(height: 20),

              /// ==========================
              /// UMIDADE DO AR
              /// ==========================
              AirHumidityChart(
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

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}