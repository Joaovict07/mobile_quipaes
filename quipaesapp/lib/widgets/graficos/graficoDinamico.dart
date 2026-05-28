import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;
import 'package:quipaesapp/databases/db.dart';
import 'package:intl/intl.dart';

enum ViewType { mes, ano }

final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

class GraficoGestaoDinamico extends StatefulWidget {
  final VoidCallback? onVendaSalva;
  final VoidCallback? onVendaCancelada;
  const GraficoGestaoDinamico({super.key, this.onVendaSalva, this.onVendaCancelada});

  @override
  State<GraficoGestaoDinamico> createState() => _GraficoGestaoDinamicoState();
}

class _GraficoGestaoDinamicoState extends State<GraficoGestaoDinamico> {
  ViewType selectedView = ViewType.mes;

  List<Map<String, dynamic>> _dadosMes = [];
  List<Map<String, dynamic>> _dadosAno = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final mes = await ComprasRepository.getVendasMensal();
    final ano = await ComprasRepository.getVendasAnual();

    setState(() {
      _dadosMes = mes;
      _dadosAno = ano;
      _carregando = false;
    });
  }

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
              ButtonSegment(value: ViewType.mes, label: Text('Mês', style: TextStyle(fontSize: 13)), icon: Icon(Icons.calendar_view_month)),
              ButtonSegment(value: ViewType.ano, label: Text('Ano', style: TextStyle(fontSize: 13)), icon: Icon(Icons.calendar_today)),
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
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  // Define a cor de fundo como cinza claro
                  getTooltipColor: (BarChartGroupData group) => Colors.grey.shade200,

                  /* Nota: Se a sua versão do fl_chart for mais antiga e der erro na linha
       acima, apague o 'getTooltipColor' e use:
       tooltipBgColor: Colors.grey.shade200,
    */

                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,

                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    // Usando o formatador que você já tem no código
                    String valorFormatado = formatadorMoeda.format(rod.toY);

                    return BarTooltipItem(
                      valorFormatado,
                      const TextStyle(
                        color: Colors.black, // Define a cor do texto como preto
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
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
      case ViewType.mes:
        text = 'S${(value.toInt() + 1)}';
        break;
      case ViewType.ano:
        switch (value.toInt()) {
          case 01: text = 'JAN'; break;
          case 02: text = 'FEV'; break;
          case 03: text = 'MAR'; break;
          case 04: text = 'ABR'; break;
          case 05: text = 'MAI'; break;
          case 06: text = 'JUN'; break;
          case 07: text = 'JUL'; break;
          case 08: text = 'AGO'; break;
          case 09: text = 'SET'; break;
          case 10: text = 'OUT'; break;
          case 11: text = 'NOV'; break;
          case 12: text = 'DEZ'; break;
        }
        break;
    }

    return SideTitleWidget(meta: meta, space: 10, child: Text(text, style: style));
  }

  // Dados
  List<BarChartGroupData> _getBarGroups() {
    if (selectedView == ViewType.mes) {
      return _dadosMes.map<BarChartGroupData>((item) {
        final semana = (item['semana'] as int?) ?? 0;
        final total = (item['total'] as num?)?.toDouble() ?? 0.0;
        return _makeGroupData(semana, total);
      }).toList();
    } else {
      return _dadosAno.map<BarChartGroupData>((item) {
        final mes = int.tryParse(item['mes'].toString()) ?? 0;
        final total = (item['total'] as num?)?.toDouble() ?? 0.0;
        return _makeGroupData(mes, total);
      }).toList();
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
    double maxTotal = 0.0;

    if (selectedView == ViewType.mes) {
      for (var item in _dadosMes) {
        final total = (item['total'] as num?)?.toDouble() ?? 0.0;
        if (total > maxTotal) maxTotal = total;
      }
    } else {
      for (var item in _dadosAno) {
        final total = (item['total'] as num?)?.toDouble() ?? 0.0;
        if (total > maxTotal) maxTotal = total;
      }
    }

    // Retorna um mínimo de 100 se estiver vazio, caso contrário adiciona 20% de margem
    return maxTotal == 0.0 ? 100.0 : maxTotal * 1.2;
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
          showTitles: false,
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