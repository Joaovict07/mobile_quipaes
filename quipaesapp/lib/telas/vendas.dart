import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:quipaesapp/routes/app_routes.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;
import 'package:quipaesapp/widgets/graficos/graficoDinamico.dart'
    as graficoDinamico;
import 'package:quipaesapp/widgets/graficos/historicoVendas.dart'
    as historicoVendas;
import '../widgets/menu_vendas.dart' as menuVendas;
import 'package:quipaesapp/databases/db.dart';
import 'package:intl/intl.dart';

class VendasWidget extends StatefulWidget {
  const VendasWidget({super.key});

  @override
  State<VendasWidget> createState() => _VendasWidgetState();
}

class _VendasWidgetState extends State<VendasWidget> {
  double _vendasMes = 0.0;
  int _pedidos = 0;
  List<Map<String, dynamic>> _vendas7Dias = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  final formatadorMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  Future<void> _carregarDados() async {
    final vendas = await ComprasRepository.getVendasMes();
    final pedidos = await ComprasRepository.getPedidos();

    setState(() {
      _vendasMes = vendas;
      _pedidos = pedidos;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Vendas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorsTheme.AppColors.primary,
      ),
      body: Container(
        decoration: BoxDecoration(color: colorsTheme.AppColors.background),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.12),

                // BigNumbers
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Vendas:',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14.0,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  _carregando
                                      ? '...'
                                      : formatadorMoeda.format(_vendasMes),
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                        ),
                        const VerticalDivider(
                          color: Colors.black12,
                          thickness: 1,
                          indent: 24,
                          endIndent: 24,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Quantidade de vendas:',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                _carregando ? '...' : _pedidos.toString(),
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                // Gráfico
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsGeometry.only(top: 1),

                          child: Text(
                            'Gráfico de Vendas',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16.0,
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: screenWidth * 0.05,
                          ),
                          child: graficoDinamico.GraficoGestaoDinamico(),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                //Historico de Vendas
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: screenWidth * 0.9,
                  child: historicoVendas.HistoricoVendasWidget(),
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AddTransactionFab(
        onVendaSalva: () => _carregarDados(),
      ),
    );
  }
}

Widget _buildMenuCard({
  required String title,
  required IconData icon,
  required double screenWidth,
}) {
  return Container(
    width: screenWidth * 0.35,
    height: 100, // Dá mais volume vertical
    decoration: BoxDecoration(
      color: colorsTheme.AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class AddTransactionFab extends StatelessWidget {
  final VoidCallback? onVendaSalva;
  const AddTransactionFab({super.key, this.onVendaSalva});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => menuVendas.AddTransactionSheet(
            onVendaSalva: onVendaSalva,
          ),
        );
      },
      backgroundColor: colorsTheme.AppColors.primary,
      child: const Icon(Icons.add_rounded, color: Colors.white),
    );
  }
}
