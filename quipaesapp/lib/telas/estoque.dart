import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:quipaesapp/databases/db.dart';
import 'package:quipaesapp/routes/app_routes.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;
import '../widgets/menu_estoque.dart' as menuEstoque;

class EstoqueWidget extends StatefulWidget {
  const EstoqueWidget({super.key});

  @override
  State<EstoqueWidget> createState() => _EstoqueWidgetState();
}

class _EstoqueWidgetState extends State<EstoqueWidget> {
  int _paginaAtual = 0;
  static const int _itensPorPagina = 12;

  List<Map<String, dynamic>> _produtos = [];
  Map<String, int> _estatisticas = {'total': 0, 'baixo': 0, 'vencendo': 0};

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    final dados = await ProdutosRepository.listar();
    final stats = await ProdutosRepository.getEstatisticas();
    setState(() {
      _estatisticas = stats;
      _produtos = dados.map((e) {
        return {
          'id': e['id'],
          'produto': e['nome'],
          'categoria': e['categoria'],
          'quantidade': e['quantidade'],
          'preco': (e['preco'] as num?)?.toDouble() ?? 0.0,
          'validade': e['validade'],
        };
      }).toList();
    });
  }

  Future<void> _excluirProduto(int id) async {
    await ProdutosRepository.excluir(id);
    _carregarProdutos();
    if (mounted) Navigator.pop(context);
  }

  int get _totalPaginas =>
      _produtos.isEmpty ? 1 : (_produtos.length / _itensPorPagina).ceil();

  List<Map<String, dynamic>> get _produtosDaPagina {
    final inicio = _paginaAtual * _itensPorPagina;
    if (inicio >= _produtos.length) return [];
    final fim = (inicio + _itensPorPagina) > _produtos.length
        ? _produtos.length
        : inicio + _itensPorPagina;
    return _produtos.sublist(inicio, fim);
  }

  void _showProductOptions(BuildContext context, Map<String, dynamic> produto) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorsTheme.AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: colorsTheme.AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produto['produto'],
                          style: const TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          produto['categoria'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: 'Validade',
                      value: produto['validade'],
                    ),
                    Container(width: 1, height: 36, color: Colors.black12),
                    _buildInfoChip(
                      icon: Icons.attach_money_rounded,
                      label: 'Preço',
                      value: 'R\$ ${produto['preco'].toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildBottomSheetAction(
                icon: Icons.edit_outlined,
                label: 'Editar produto',
                color: const Color(0xFF1E293B),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              _buildBottomSheetAction(
                icon: Icons.delete_outline_rounded,
                label: 'Excluir produto',
                color: Colors.redAccent,
                onTap: () => _excluirProduto(produto['id']),
                isDestructive: true,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.black45),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheetAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: isDestructive
          ? Colors.redAccent.withOpacity(0.06)
          : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallAlert({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Estoque',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: colorsTheme.AppColors.primary,
      ),
      body: Container(
        decoration: BoxDecoration(color: colorsTheme.AppColors.background),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.12),

                // Painel de Resumo Unificado
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSmallAlert(
                                label: 'Em estoque',
                                value: _estatisticas['total'].toString(),
                                icon: Icons.inventory_2_outlined,
                                color: colorsTheme.AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(
                          color: Color(0xFFF1F5F9),
                          thickness: 1.5,
                          indent: 5,
                          endIndent: 5,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSmallAlert(
                                label: 'Estoque baixo',
                                value: _estatisticas['baixo'].toString(),
                                icon: Icons.trending_down_rounded,
                                color: const Color(0xFFEF4444),
                              ),
                              const SizedBox(height: 12),
                              _buildSmallAlert(
                                label: 'Vencendo logo',
                                value: _estatisticas['vencendo'].toString(),
                                icon: Icons.event_busy_rounded,
                                color: const Color(0xFFF59E0B),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Tabela de Produtos em Estoque
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: double.infinity,
                  height: screenHeight * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                color: colorsTheme.AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Produtos em Estoque',
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: DataTable(
                                  columnSpacing: constraints.maxWidth * 0.06,
                                  dataRowMinHeight: 52,
                                  dataRowMaxHeight: 52,
                                  headingRowHeight: 44,
                                  headingRowColor: WidgetStateProperty.all(
                                    const Color(0xFFF1F5F9),
                                  ),
                                  dividerThickness: 0.6,
                                  showCheckboxColumn: false,
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'Produto',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Categoria',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      numeric: true,
                                      label: Text(
                                        'Qtd.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: _produtosDaPagina.asMap().entries.map((
                                    entry,
                                  ) {
                                    final produto = entry.value;
                                    return DataRow(
                                      color: WidgetStateProperty.resolveWith(
                                        (states) =>
                                            states.contains(WidgetState.selected)
                                                ? colorsTheme.AppColors.primary
                                                    .withOpacity(0.05)
                                                : Colors.white,
                                      ),
                                      onSelectChanged: (_) =>
                                          _showProductOptions(context, produto),
                                      cells: [
                                        DataCell(
                                          SizedBox(
                                            width: constraints.maxWidth * 0.28,
                                            child: Text(
                                              produto['produto'],
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: constraints.maxWidth * 0.24,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(
                                                  produto['categoria'],
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                produto['categoria'],
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: _getCategoryColor(
                                                    produto['categoria'],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${produto['quantidade']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _paginaAtual > 0
                                  ? () => setState(() => _paginaAtual--)
                                  : null,
                              icon: const Icon(Icons.chevron_left, size: 18),
                              label: const Text("Voltar"),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                foregroundColor: const Color(0xFF1E293B),
                                disabledForegroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            Text(
                              "${_paginaAtual + 1} / $_totalPaginas",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _paginaAtual < _totalPaginas - 1
                                  ? () => setState(() => _paginaAtual++)
                                  : null,
                              icon: const Icon(Icons.chevron_right, size: 18),
                              label: const Text("Avançar"),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                foregroundColor: const Color(0xFF1E293B),
                                disabledForegroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AddTransactionFab(
        onRefresh: _carregarProdutos,
      ),
    );
  }

  Color _getCategoryColor(String categoria) {
    switch (categoria) {
      case 'Alimentos':
        return const Color(0xFF10B981);
      case 'Higiene':
        return const Color(0xFF3B82F6);
      case 'Limpeza':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }
}

class AddTransactionFab extends StatelessWidget {
  final VoidCallback onRefresh;
  const AddTransactionFab({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const menuEstoque.AddProductSheet(),
        );

        if (result == true) {
          onRefresh();
        }
      },
      backgroundColor: colorsTheme.AppColors.primary,
      elevation: 4,
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }
}
