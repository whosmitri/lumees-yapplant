import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LightData {
  final String hour;
  final double lux;

  const LightData({
    required this.hour,
    required this.lux,
  });
}

class LightChart extends StatelessWidget {
  final List<LightData> data;

  const LightChart({
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
                Icons.wb_sunny_rounded,
                size: 22,
                color: Color(0xFFFFC107),
              ),
              SizedBox(width: 8),
              Text(
                'Luminosidade',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10000,

                borderData: FlBorderData(
                  show: false,
                ),

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.black.withValues(alpha: 0.06),
                      strokeWidth: 1,
                    );
                  },
                ),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,

                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= data.length) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            data[index].hour,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()} Lux',
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      data.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        data[index].lux,
                      ),
                    ),

                    isCurved: true,

                    color: const Color(0xFFFFC107),

                    barWidth: 3.5,

                    isStrokeCapRound: true,

                    dotData: FlDotData(
                      show: true,
                      getDotPainter:
                          (
                            spot,
                            percent,
                            barData,
                            index,
                          ) => FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: const Color(0xFFFFC107),
                          ),
                    ),

                    belowBarData: BarAreaData(
                      show: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}