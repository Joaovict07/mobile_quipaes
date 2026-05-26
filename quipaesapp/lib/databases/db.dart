import 'package:excel/excel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

Future<void> importarExcelParaDB(String caminhoArquivo) async {
  final byteData = await rootBundle.load('assets/Dados_Api_Quipaes.xlsx');
  final bytes = byteData.buffer.asUint8List();
  final excel = Excel.decodeBytes(bytes);
  final db = await DatabaseHelper.openDB();

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
  static Database? _db;
  
  static Future<Database> get instance async {
    _db ??= await openDB();
    return _db!;
  }
  
  static Future<void> inicializar() async {
    await importarExcelParaDB("mobile_quipaes\quipaesapp\assets\Dados_Api_Quipaes.xlsx");
  }

  static Future<Database> openDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vendas.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vendas (
            id_compra INTEGER PRIMARY KEY AUTOINCREMENT,
            data_hora DATE,
            cpf_cliente TEXT,
            endereco_entrega TEXT,
            status_compra INTEGER,
            total_pedido REAL,
            valor_entrega REAL
          )
        ''');
      }
    );
  }

}

class ComprasRepository {
  static Future<double> getVendasMes() async {
    final db = await DatabaseHelper.instance;
    final result = await db.rawQuery('''SELECT SUM(total_pedido) as total 
    FROM vendas
    WHERE status_compra = 2
    AND strftime('%Y-%m', data_hora) = strftime('%Y-%m', 'now')''');
    return (result.first['total'] as double?) ?? 0.0;
  }

  static Future<int> getPedidosPendentes() async {
    final db = await DatabaseHelper.instance;
    final result = await db.rawQuery('''SELECT COUNT(*) as total
    FROM vendas
    WHERE status_compra = 1
    ''');
    return (result.first['total'] as int?) ?? 0;
  }

  static Future<List<Map<String, dynamic>>> getVendas7Dias() async {
    final db = await DatabaseHelper.instance;
    return await db.rawQuery('''
    SELECT
      strftime('%d/%m', data_hora) as dia,
      SUM(total_pedido) as total
    FROM vendas
    WHERE status_compra = 2
    AND data_hora >= date('now', '-7 days')
    GROUP BY strftime('%d/%m', data_hora)
    ORDER BY data_hora ASC
    ''');
  }
}