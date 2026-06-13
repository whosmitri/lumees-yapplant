import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AirHumidityData {
  final String hour;
  final double humidity;

  const AirHumidityData({
    required this.hour,
    required this.humidity,
  });
}

class AirHumidityChart extends StatelessWidget {
  final List<AirHumidityData> data;

  const AirHumidityChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    const barColor = Color(0xFF7DD3FC);

    return Container(
      padding: const EdgeInsets.all(24),

      height: 380,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
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
                Icons.cloud_queue_rounded,
                size: 22,
                color: Color(0xFF7DD3FC),
              ),
              SizedBox(width: 8),
              Text(
                'Umidade do Ar',
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
                minY: 0,
                maxY: 105,

                alignment: BarChartAlignment.spaceAround,

                borderData: FlBorderData(
                  show: false,
                ),

                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (
                      group,
                      groupIndex,
                      rod,
                      rodIndex,
                    ) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}%',
                        const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,

                  checkToShowHorizontalLine: (value) =>
                      [0, 25, 50, 75, 100].contains(
                        value.toInt(),
                      ),

                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.08),
                      strokeWidth: 1,
                    );
                  },
                ),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 25,

                      getTitlesWidget: (value, meta) {
                        if ([0, 25, 50, 75, 100]
                            .contains(value.toInt())) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              '${value.toInt()}%',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,

                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= data.length) {
                          return const SizedBox();
                        }

                        return SideTitleWidget(
                          meta: meta,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 8),
                            child: Text(
                              data[index].hour,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                barGroups: List.generate(
                  data.length,
                  (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data[index].humidity,
                          width: 16,
                          color: barColor,
                          borderRadius:
                              const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
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