import 'package:flutter/material.dart';
import 'package:quipaesapp/databases/db.dart';

enum StatusVenda { concluida, cancelada }

class Venda {
  final String cliente;
  final String data;
  final double valor;
  StatusVenda status;

  Venda({
    required this.cliente,
    required this.data,
    required this.valor,
    required this.status,
  });
}

class HistoricoVendasWidget extends StatefulWidget {
  const HistoricoVendasWidget({super.key});

  @override
  State<HistoricoVendasWidget> createState() => _HistoricoVendasWidgetState();
}

class _HistoricoVendasWidgetState extends State<HistoricoVendasWidget> {
  List<Map<String, dynamic>> _historico = [];
  bool _carregando = true;
  int _paginaAtual = 0;
  static const int _itensPorPagina = 5;

  @override
  void initState() {
    super.initState();
    // DatabaseHelper.limparBanco().then((_) => _carregarDados());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final historico = await ComprasRepository.getHistoricoVendas();

    setState(() {
      _historico = historico;
      carregarVendas();
      _carregando = false;
    });
  }

  // Mock de Vendas
  final List<Venda> _todasVendas = [];

  int get _totalPaginas => (_todasVendas.length / _itensPorPagina).ceil();

  void carregarVendas() {
    _todasVendas.clear();
    for (int i = 0; i < _historico.length; i++) {
      _todasVendas.add(new Venda(cliente: 'Delivery - ${_historico[i]['pgto']}', data: _historico[i]['data'], status: _historico[i]['status'] == 0 ? StatusVenda.cancelada : StatusVenda.concluida, valor: _historico[i]['total']));
    }
  }

  List<Venda> get _vendasDaPagina {
    final inicio = _paginaAtual * _itensPorPagina;
    final fim = (inicio + _itensPorPagina).clamp(0, _todasVendas.length);
    return _todasVendas.sublist(inicio, fim);
  }

  // Abre o dialog de detalhes/cancelamento
  void _abrirDetalhes(Venda venda) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Detalhes da Venda",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detalheRow(Icons.person_outline, "Cliente", venda.cliente),
              const SizedBox(height: 12),
              _detalheRow(Icons.access_time, "Data", venda.data),
              const SizedBox(height: 12),
              _detalheRow(
                Icons.attach_money,
                "Valor",
                "R\$ ${venda.valor.toStringAsFixed(2)}",
              ),
              const SizedBox(height: 12),
              _detalheRow(
                venda.status == StatusVenda.cancelada
                    ? Icons.cancel_outlined
                    : Icons.check_circle_outline,
                "Status",
                venda.status == StatusVenda.cancelada
                    ? "Cancelada"
                    : "Concluída",
                valueColor: venda.status == StatusVenda.cancelada
                    ? Colors.red
                    : Colors.green,
              ),

              // Aviso se já estiver cancelada
              if (venda.status == StatusVenda.cancelada) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Esta venda já foi cancelada.",
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            // Botão Fechar
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text("Fechar"),
            ),

            // Botão Cancelar Venda — só aparece se estiver concluída
            if (venda.status == StatusVenda.concluida)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmarCancelamento(venda);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Cancelar Venda"),
              ),
          ],
        );
      },
    );
  }

  void _confirmarCancelamento(Venda venda) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirmar Cancelamento",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          content: Text(
            "Deseja cancelar a venda de R\$ ${venda.valor.toStringAsFixed(2)} para ${venda.cliente}?\n\nEssa ação não pode ser desfeita.",
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text("Voltar"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => venda.status = StatusVenda.cancelada);
                Navigator.of(context).pop();
                _mostrarFeedback("Venda cancelada com sucesso.");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarFeedback(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _detalheRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Últimas Vendas",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 25),

          ..._vendasDaPagina.map((venda) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: OutlinedButton(
                onPressed: () => _abrirDetalhes(venda), // <-- abre o dialog
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: const Color(0xFF1E293B),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            venda.cliente,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        venda.status == StatusVenda.cancelada
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "Cancelada",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  ),
                                ),
                              )
                            : Text(
                                "R\$ ${venda.valor.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.green,
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              venda.data,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        _buildStatusBadge(venda.status),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          Row(
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
                style: const TextStyle(color: Colors.grey, fontSize: 13),
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
        ],
      ),
    );
  }
}

Widget _buildStatusBadge(StatusVenda status) {
  Color color;
  switch (status) {
    case StatusVenda.cancelada:
      color = Colors.red;
      break;
    default:
      color = Colors.green;
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
  );
}
