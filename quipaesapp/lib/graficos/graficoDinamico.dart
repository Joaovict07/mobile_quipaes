import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;

enum ViewType { semana, mes, ano }

class GraficoGestaoDinamico extends StatefulWidget {
  const GraficoGestaoDinamico({super.key});

  @override
  State<GraficoGestaoDinamico> createState() => _GraficoGestaoDinamicoState();
}

class _GraficoGestaoDinamicoState extends State<GraficoGestaoDinamico> {
  ViewType selectedView = ViewType.semana;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SELETOR DE TEMPO
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SegmentedButton<ViewType>(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: colorsTheme.AppColors.primary,
              selectedForegroundColor: Colors.white,
            ),
            segments: const [
              ButtonSegment(value: ViewType.semana, label: Text('Semana'), icon: Icon(Icons.calendar_view_week)),
              ButtonSegment(value: ViewType.mes, label: Text('Mês'), icon: Icon(Icons.calendar_view_month)),
              ButtonSegment(value: ViewType.ano, label: Text('Ano'), icon: Icon(Icons.calendar_today)),
            ],
            selected: {selectedView},
            onSelectionChanged: (newSelection) {
              setState(() {
                selectedView = newSelection.first;
              });
            },
          ),
        ),

        // GRÁFICO
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ],
          ),
          child: BarChart(
            BarChartData(
              maxY: _getMaxY(),
              barGroups: _getBarGroups(),
              titlesData: _getTitlesData(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              alignment: BarChartAlignment.spaceAround,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLabels(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10);
    String text = '';

    switch (selectedView) {
      case ViewType.semana:
        switch (value.toInt()) {
          case 0: text = 'SEG'; break;
          case 1: text = 'TER'; break;
          case 2: text = 'QUA'; break;
          case 3: text = 'QUI'; break;
          case 4: text = 'SEX'; break;
          case 5: text = 'SÁB'; break;
          case 6: text = 'DOM'; break;
        }
        break;
      case ViewType.mes:
        text = 'S${(value.toInt() + 1)}';
        break;
      case ViewType.ano:
        switch (value.toInt()) {
          case 0: text = 'JAN'; break;
          case 2: text = 'MAR'; break;
          case 4: text = 'MAI'; break;
          case 6: text = 'JUL'; break;
          case 8: text = 'SET'; break;
          case 10: text = 'NOV'; break;
        }
        break;
    }

    return SideTitleWidget(meta:meta, space: 10, child: Text(text, style: style));
  }

  // Dados
  List<BarChartGroupData> _getBarGroups() {
    if (selectedView == ViewType.semana) {
      return List.generate(7, (i) => _makeGroupData(i, (i + 1) * 200.0));
    } else if (selectedView == ViewType.mes) {
      return List.generate(4, (i) => _makeGroupData(i, (i + 1) * 2500.0));
    } else {
      return List.generate(12, (i) => _makeGroupData(i, (i + 1) * 10000.0));
    }
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: colorsTheme.AppColors.primary,
          width: 15,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  double _getMaxY() {
    if (selectedView == ViewType.semana) return 2000;
    if (selectedView == ViewType.mes) return 15000;
    return 150000;
  }

  FlTitlesData _getTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: _buildBottomLabels,
          reservedSize: 38,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => Text(
            value >= 1000 ? '${(value / 1000).toInt()}k' : value.toInt().toString(),
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}