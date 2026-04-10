import 'package:flutter/material.dart';
import 'package:quipaesapp/routes/app_routes.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;
import 'package:quipaesapp/graficos/graficoSemanal.dart' as graficoSemanal;

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
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
          'Painel',
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
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.12),

                // Botões de Navegação
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMenuCard(
                      title: 'Vendas',
                      icon: Icons.point_of_sale, 
                      screenWidth: screenWidth,
                    ),
                    SizedBox(
                      width: screenWidth * 0.05,
                    ), 
                    _buildMenuCard(
                      title: 'Estoque',
                      icon: Icons.inventory_2,
                      screenWidth: screenWidth,
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.05),

                // BigNumbers
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(
                      12,
                    ), 
                  ),
                  child: SizedBox(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Vendas Mês Atual:',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'R\$ 1.250',
                                  style: TextStyle(
                                    color: Color(
                                      0xFF1E293B,
                                    ), 
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          color: Colors.black12,
                          thickness: 1,
                          indent: 24, 
                          endIndent: 24, 
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Alertas de estoque:',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  '12', 
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),
              
              //Gráfico
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: screenWidth * 1.5,
                    height: screenHeight * 0.40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            vertical: 10
                          ),

                          child: Text('Vendas nos últimos 7 dias', style: TextStyle(color: Colors.black54, fontSize: 16.0)),
                        ),
                        
                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            vertical: screenHeight * 0.05,
                            horizontal: screenWidth * 0.05,
                          ),
                          child: graficoSemanal.VendasBarChartSemana(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
