import 'package:excel/excel.dart';
import 'package:quipaesapp/databases/db.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:flutter/services.dart';

Future<void> importarExcelParaDB(String caminhoArquivo) async {
  final byteData = await rootBundle.load('assets/Dados_Api_Quipaes.xlsx');
  final bytes = byteData.buffer.asUint8List();
  final excel = Excel.decodeBytes(bytes);
  final db = await openDB();

  // Pega a primeira aba
  final sheet = excel.tables[excel.tables.keys.first]!;

  // Pula a linha 0 (cabeçalho) e itera as demais
  for (int i = 1; i < sheet.maxRows; i++) {
    final row = sheet.row(i);

    final data_hora = row[1]?.value?.toString() ?? '';
    final cpf = row[2]?.value?.toString() ?? '';
    final endereco = row[3]?.value?.toString() ?? '';
    final status = row[4]?.value?.toString() ?? '';
    final total_pedido = double.tryParse(row[5]?.value?.toString() ?? '0') ?? 0;
    final valor_entrega = double.tryParse(row[6]?.value?.toString() ?? '0') ?? 0;

    await db.insert(
      'vendas',
      {'data_hora': data_hora, 'cpf_cliente': cpf, 'endereco_entrega': endereco, 'status_compra': status, 'total_pedido': total_pedido, 'valor_entrega': valor_entrega},
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }
}

class DatabaseHelper {
  static Future<void> inicializar() async {
    await importarExcelParaDB("C:\Labs\mobile_quipaes\mobile_quipaes\quipaesapp\lib\databases\Dados_Api_Quipaes.xlsx");
  }
}