import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/weather_models.dart';

class ForecastChartCard extends StatelessWidget {
  const ForecastChartCard({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.valueSelector,
    required this.lineColor,
    required this.unit,
    required this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<HourlyPoint> points;
  final double Function(HourlyPoint) valueSelector;
  final Color lineColor;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final spots = _toSpots(points, valueSelector);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: lineColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lineColor.withValues(alpha: 0.28)),
                  ),
                  child: Icon(icon, color: lineColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Container(
              height: 220,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: lineColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: lineColor.withValues(alpha: 0.20)),
              ),
              child:
                  spots.isEmpty
                      ? const Center(child: Text('No graph data'))
                      : LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: (spots.length - 1).toDouble(),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final index = spot.x.toInt();
                                  final label =
                                      index >= 0 && index < points.length
                                          ? points[index].hourLabel
                                          : '--';
                                  return LineTooltipItem(
                                    '$label\n${spot.y.toStringAsFixed(1)}$unit',
                                    Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ) ??
                                        const TextStyle(),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 34,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= points.length) {
                                    return const SizedBox.shrink();
                                  }
                                  if (index % 2 != 0)
                                    return const SizedBox.shrink();
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      points[index].hourLabel,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            horizontalInterval: unit == '%' ? 10 : null,
                            getDrawingHorizontalLine:
                                (value) => FlLine(
                                  color: lineColor.withValues(alpha: 0.14),
                                  strokeWidth: 1,
                                ),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: lineColor,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: lineColor.withValues(alpha: 0.18),
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _toSpots(
    List<HourlyPoint> values,
    double Function(HourlyPoint) selector,
  ) {
    final spots = <FlSpot>[];
    for (var index = 0; index < values.length; index++) {
      spots.add(FlSpot(index.toDouble(), selector(values[index])));
    }
    return spots;
  }
}
