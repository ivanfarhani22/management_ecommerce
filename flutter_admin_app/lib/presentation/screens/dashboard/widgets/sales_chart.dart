import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesChart extends StatelessWidget {
  const SalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Sales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      );
                      switch (value.toInt()) {
                        case 0: return const Text('Jan', style: style);
                        case 1: return const Text('Feb', style: style);
                        case 2: return const Text('Mar', style: style);
                        case 3: return const Text('Apr', style: style);
                        case 4: return const Text('May', style: style);
                        case 5: return const Text('Jun', style: style);
                        default: return const Text('', style: style);
                      }
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}K',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(0, 3),
                    FlSpot(1, 5),
                    FlSpot(2, 4),
                    FlSpot(3, 7),
                    FlSpot(4, 6),
                    FlSpot(5, 8),
                  ],
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}