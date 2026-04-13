import 'package:flutter/material.dart';
enum StatusVenda { concluida, cancelada }

class Venda {
  final String cliente;
  final String data;
  final double valor;
  final StatusVenda status;

  Venda({required this.cliente, required this.data, required this.valor, required this.status});
}

class HistoricoVendasWidget extends StatelessWidget {
  const HistoricoVendasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados
    final List<Venda> ultimasVendas = [
      Venda(cliente: "João Silva", data: "12/04 - 14:20", valor: 150.00, status: StatusVenda.concluida),
      Venda(cliente: "Maria Oliveira", data: "12/04 - 13:10", valor: 85.50, status: StatusVenda.cancelada),
      Venda(cliente: "Padaria Central", data: "12/04 - 11:45", valor: 320.00, status: StatusVenda.concluida),
      Venda(cliente: "Carlos Andrade", data: "11/04 - 18:30", valor: 45.00, status: StatusVenda.concluida),
      Venda(cliente: "Loja do Bairro", data: "11/04 - 16:00", valor: 120.00, status: StatusVenda.cancelada),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Últimas Vendas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 16),
          ...ultimasVendas.map((venda) => _buildVendaItem(venda)).toList(),
        ],
      ),
    );
  }

  Widget _buildVendaItem(Venda venda) {
    final bool isCancelada = venda.status == StatusVenda.cancelada;
    final Color statusColor = isCancelada ? Colors.red.shade400 : Colors.green.shade400;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCancelada ? Icons.close : Icons.arrow_upward,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venda.cliente,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  venda.data,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "R\$ ${venda.valor.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCancelada ? Colors.red.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}