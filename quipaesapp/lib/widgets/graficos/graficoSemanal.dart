import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class VendasBarChartSemana extends StatelessWidget {
  final List<Map<String, dynamic>> dados;

  const VendasBarChartSemana({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    final barGroups = dados.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final total = (item['total'] as num?)?.toDouble() ?? 0.0;
      final cores = [
        Color(0xFFAFC8E8),
        Color(0xFF7FADE0),
        Color(0xFF4F8ED6),
        Color(0xFF2F6FC4),
        Color(0xFF1F5AA8),
        Color(0xFF174A8C),
        Color(0xFF0F3870),
      ];
      return generateGroupData(index, total, cores[index % cores.length]);
    }).toList();

    final maxY = dados.isEmpty ? 1000.0 : dados
        .map((e) => (e['total'] as num?)?.toDouble() ?? 0.0)
        .reduce((a, b) => a > b ? a : b) * 1.2;

    return AspectRatio(
      aspectRatio: 2,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black,
              tooltipPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              tooltipMargin: 4,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  'R\$ ${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => getBottomTitles(value, meta),
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  BarChartGroupData generateGroupData(int x, double y, Color barColor) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    final style = const TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    final index = value.toInt();
    final label = (index >= 0 && index < dados.length)
        ? dados[index]['dia'].toString()
        : '';

    return SideTitleWidget(meta: meta, space: 8, child: Text(label, style: style));
  }
}