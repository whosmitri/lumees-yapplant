import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SoilHumidityData {
  final String hour;
  final double humidity;

  const SoilHumidityData({
    required this.hour,
    required this.humidity,
  });
}

class SoilHumidityChart extends StatelessWidget {
  final List<SoilHumidityData> data;

  const SoilHumidityChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),

      height: 340,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.water_drop_rounded,
                size: 22,
                color: Color(0xFF5A7DFF),
              ),
              SizedBox(width: 8),
              Text(
                'Umidade do Solo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: BarChart(
              BarChartData(
                maxY: 100,

                alignment: BarChartAlignment.spaceAround,

                borderData: FlBorderData(show: false),

                gridData: FlGridData(show: false),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 55,

                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= data.length) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${data[index].humidity.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                data[index].hour,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                barGroups: List.generate(
                  data.length,
                  (index) {
                    final item = data[index];

                    return BarChartGroupData(
                      x: index,

                      barRods: [
                        BarChartRodData(
                          toY: item.humidity,

                          width: 12,

                          color: const Color(0xFF5A7DFF),

                          borderRadius:
                              BorderRadius.circular(10),

                          backDrawRodData:
                              BackgroundBarChartRodData(
                            show: true,
                            toY: 100,
                            color: const Color(0xFFE9ECF3),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}