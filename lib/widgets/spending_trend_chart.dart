import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analytics_models.dart';

/// Line chart showing spending trend over time
class SpendingTrendChart extends StatelessWidget {
  final List<SpendingTrendPoint> trendPoints;

  const SpendingTrendChart({super.key, required this.trendPoints});

  @override
  Widget build(BuildContext context) {
    if (trendPoints.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data available')),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateInterval(),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < trendPoints.length) {
                            final date = trendPoints[value.toInt()].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.month}/${date.day}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _buildSpots(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: _getMaxY(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${_getTotalSpending().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return trendPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount);
    }).toList();
  }

  double _getMaxY() {
    if (trendPoints.isEmpty) return 100;
    final maxAmount = trendPoints
        .map((p) => p.amount)
        .reduce((a, b) => a > b ? a : b);
    return (maxAmount * 1.2).ceilToDouble();
  }

  double _calculateInterval() {
    final maxY = _getMaxY();
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    return 500;
  }

  double _getTotalSpending() {
    return trendPoints.fold(0.0, (sum, point) => sum + point.amount);
  }
}
