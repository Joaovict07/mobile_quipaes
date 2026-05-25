import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;

class VendasBarChartSemana extends StatelessWidget {
  const VendasBarChartSemana({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2, 
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 4000, 
          
          barTouchData: BarTouchData(
            enabled:
                true, 
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors
                  .black,
              tooltipPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              tooltipMargin: 4,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY
                      .toInt()
                      .toString(), 
                  const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),

          // Configuração dos títulos (Eixos)
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getBottomTitles,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),

          // Configuração da grade
          gridData: const FlGridData(show: true, drawVerticalLine: false),

          // Configuração da borda
          borderData: FlBorderData(show: false),

          // OS DADOS DAS BARRAS
          barGroups: [
            generateGroupData(0, 1000, Color(0xFFAFC8E8)), // x: 0, y: 10
            generateGroupData(1, 1800, Color(0xFF7FADE0)), // x: 1, y: 18
            generateGroupData(2, 4000, Color(0xFF4F8ED6)), // x: 2, y: 4
            generateGroupData(3, 1100, Color(0xFF2F6FC4)), // x: 3, y: 11
            generateGroupData(4, 1500, Color(0xFF1F5AA8)),
            generateGroupData(5, 2000, Color(0xFF174A8C)),
          ],
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
    const style = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('SEG', style: style);
        break;
      case 1:
        text = const Text('TER', style: style);
        break;
      case 2:
        text = const Text('QUA', style: style);
        break;
      case 3:
        text = const Text('QUI', style: style);
        break;
      case 4:
        text = const Text('SEX', style: style);
        break;
      case 5:
        text = const Text('SAB', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(meta: meta, space: 4, child: text);
  }
}
