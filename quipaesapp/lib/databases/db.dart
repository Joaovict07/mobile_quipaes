import 'package:excel/excel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

Future<void> importarExcelParaDB() async {
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
    final forma_pgto = row[7]?.value?.toString() ?? '';

    await db.insert(
      'vendas',
      {'data_hora': data_hora, 'cpf_cliente': cpf, 'endereco_entrega': endereco, 'status_compra': status, 'total_pedido': total_pedido, 'valor_entrega': valor_entrega, 'forma_pgto': forma_pgto},
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
    const int versaoAtual = 2;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vendas.db');
    await deleteDatabase(path);
    _db = null;
    final db = await instance;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS produtos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        categoria TEXT,
        quantidade INTEGER,
        preco REAL,
        validade TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS versao_dados (
        id INTEGER PRIMARY KEY,
        versao INTEGER
      )
    ''');

    final result = await db.rawQuery('SELECT versao FROM versao_dados LIMIT 1');
    final versaoSalva = result.isEmpty ? 0 : result.first['versao'] as int;

    if (versaoSalva < versaoAtual) {
      await db.delete('vendas');
      await importarExcelParaDB();
      await ComprasRepository.inserirDadosTeste();

      await db.delete('versao_dados');
      await db.insert('versao_dados', {'id': 1, 'versao': versaoAtual});
    }
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
            valor_entrega REAL,
            forma_pgto TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE versao_dados (
            id INTEGER PRIMARY KEY,
            versao INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            categoria TEXT,
            quantidade INTEGER,
            preco REAL,
            validade TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 1) {
          try {
            await db.execute('ALTER TABLE produtos ADD COLUMN preco REAL');
          } catch (e) {

          }
        }
      },
    );
  }
  static Future<void> limparBanco() async {
    final db = await instance;
    await db.delete('vendas');
    print('Banco limpo!');
  }
}

class ComprasRepository {
  static Future<double> getVendasMes() async {
    final db = await DatabaseHelper.instance;
    final result = await db.rawQuery('''SELECT SUM(total_pedido) as total 
    FROM vendas
    WHERE strftime('%Y-%m', data_hora) = strftime('%Y-%m', 'now')''');
    return (result.first['total'] as double?) ?? 0.0;
  }

  static Future<int> getPedidosPendentes() async {
    final db = await DatabaseHelper.instance;
    final result = await db.rawQuery('''SELECT COUNT(*) as total
    FROM vendas
    WHERE status_compra = 1 AND strftime('%Y-%m', data_hora) = strftime('%Y-%m', 'now')
    ''');
    return (result.first['total'] as int?) ?? 0;
  }

  static Future<int> getPedidos() async {
    final db = await DatabaseHelper.instance;
    final result = await db.rawQuery('''SELECT COUNT(*) as total
    FROM vendas
    WHERE strftime('%Y-%m', data_hora) = strftime('%Y-%m', 'now')
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
      WHERE status_compra != 0
      GROUP BY strftime('%d/%m', data_hora)
      ORDER BY data_hora DESC
      LIMIT 7
    ''');
  }

  static Future<List<Map<String, dynamic>>> getVendasMensal() async {
    final db = await DatabaseHelper.instance;
    return await db.rawQuery('''
      SELECT 
        CAST((strftime('%d', data_hora) - 1) / 7 AS INTEGER) as semana,
        SUM(total_pedido) as total
      FROM vendas
      WHERE status_compra != 0
      GROUP BY semana
      ORDER BY semana ASC
    ''');
  }

  static Future<List<Map<String, dynamic>>> getVendasAnual() async {
    final db = await DatabaseHelper.instance;
    return await db.rawQuery('''
      SELECT 
        strftime('%m', data_hora) as mes,
        SUM(total_pedido) as total
      FROM vendas
      WHERE status_compra != 0
      GROUP BY strftime('%m', data_hora)
      ORDER BY data_hora ASC
      LIMIT 12
    ''');
  }

  static Future<List<Map<String, dynamic>>> getHistoricoVendas() async {
      final db = await DatabaseHelper.instance;
      return await db.rawQuery('''SELECT strftime('%d/%m', data_hora) as data, total_pedido as total, status_compra as status, forma_pgto as pgto
      FROM vendas
      WHERE status_compra != 1 AND strftime('%Y-%m', data_hora) = strftime('%Y-%m', 'now')
      ORDER BY data_hora DESC
      ''');
  }

  static Future<void> inserirNovaVenda(valor, categoria, data, formaPgto) async {
    final db = await DatabaseHelper.instance;

    await db.insert('vendas', {'data_hora' : data.toIso8601String(), 'cpf_cliente': '00000000000', 'endereco_entrega': categoria, 'status_compra': 2, 'total_pedido': valor, 'valor_entrega': 5, 'forma_pgto': formaPgto}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> inserirDadosTeste() async {
    final db = await DatabaseHelper.instance;

    final dados = [
      {'data_hora': '2026-05-01 08:30:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 150.90, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-01 14:20:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 89.50, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-01 19:00:00.000000', 'cpf_cliente': '90019154003', 'endereco_entrega': 'Rua 45, 3131, São Paulo', 'status_compra': 1, 'total_pedido': 230.00, 'valor_entrega': 5, 'forma_pgto': 'Dinheiro'},
      {'data_hora': '2026-05-02 09:15:00.000000', 'cpf_cliente': '30030030030', 'endereco_entrega': 'Rua dos Peidoreiros 1', 'status_compra': 2, 'total_pedido': 217.50, 'valor_entrega': 5, 'forma_pgto': 'Débito'},
      {'data_hora': '2026-05-02 13:40:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 67.80, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-02 18:00:00.000000', 'cpf_cliente': '90472265008', 'endereco_entrega': 'Rua Conselheiro Brotero, 900', 'status_compra': 0, 'total_pedido': 95.70, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-03 10:00:00.000000', 'cpf_cliente': '46561535839', 'endereco_entrega': 'Rua São Severo, 229', 'status_compra': 2, 'total_pedido': 312.50, 'valor_entrega': 5, 'forma_pgto': 'Dinheiro'},
      {'data_hora': '2026-05-03 15:30:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 45.40, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-04 08:00:00.000000', 'cpf_cliente': '90019154003', 'endereco_entrega': 'Rua 45, 3131, São Paulo', 'status_compra': 2, 'total_pedido': 180.00, 'valor_entrega': 5, 'forma_pgto': 'Débito'},
      {'data_hora': '2026-05-04 12:20:00.000000', 'cpf_cliente': '43648210895', 'endereco_entrega': 'R. JOAO JANINI RODRIGUES', 'status_compra': 1, 'total_pedido': 33.30, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-04 20:10:00.000000', 'cpf_cliente': '30030030030', 'endereco_entrega': 'Rua dos Peidoreiros 1', 'status_compra': 2, 'total_pedido': 99.90, 'valor_entrega': 5, 'forma_pgto': 'Pix'},

      {'data_hora': '2026-05-05 09:00:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 210.00, 'valor_entrega': 5, 'forma_pgto': 'Débito'},
      {'data_hora': '2026-05-05 17:30:00.000000', 'cpf_cliente': '46561535839', 'endereco_entrega': 'Rua São Severo, 229', 'status_compra': 0, 'total_pedido': 58.90, 'valor_entrega': 5, 'forma_pgto': 'Dinheiro'},
      {'data_hora': '2026-05-06 11:00:00.000000', 'cpf_cliente': '90472265008', 'endereco_entrega': 'Rua Conselheiro Brotero, 900', 'status_compra': 2, 'total_pedido': 430.00, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-06 16:45:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 75.60, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-07 08:30:00.000000', 'cpf_cliente': '90019154003', 'endereco_entrega': 'Rua 45, 3131, São Paulo', 'status_compra': 1, 'total_pedido': 120.00, 'valor_entrega': 5, 'forma_pgto': 'Débito'},
      {'data_hora': '2026-05-07 14:00:00.000000', 'cpf_cliente': '43648210895', 'endereco_entrega': 'R. JOAO JANINI RODRIGUES', 'status_compra': 2, 'total_pedido': 88.50, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-08 10:15:00.000000', 'cpf_cliente': '30030030030', 'endereco_entrega': 'Rua dos Peidoreiros 1', 'status_compra': 2, 'total_pedido': 340.00, 'valor_entrega': 5, 'forma_pgto': 'Dinheiro'},
      {'data_hora': '2026-05-08 19:00:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 55.20, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-09 09:30:00.000000', 'cpf_cliente': '46561535839', 'endereco_entrega': 'Rua São Severo, 229', 'status_compra': 2, 'total_pedido': 199.90, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-09 15:00:00.000000', 'cpf_cliente': '90472265008', 'endereco_entrega': 'Rua Conselheiro Brotero, 900', 'status_compra': 0, 'total_pedido': 41.20, 'valor_entrega': 5, 'forma_pgto': 'Débito'},
      {'data_hora': '2026-05-10 11:30:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 278.00, 'valor_entrega': 5, 'forma_pgto': 'Dinheiro'},
      {'data_hora': '2026-05-10 20:00:00.000000', 'cpf_cliente': '90019154003', 'endereco_entrega': 'Rua 45, 3131, São Paulo', 'status_compra': 2, 'total_pedido': 92.30, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-11 08:00:00.000000', 'cpf_cliente': '43648210895', 'endereco_entrega': 'R. JOAO JANINI RODRIGUES', 'status_compra': 1, 'total_pedido': 63.70, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},

      {'data_hora': '2026-05-12 09:00:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 415.00, 'valor_entrega': 5, 'forma_pgto': 'Débito'},
      {'data_hora': '2026-05-12 14:30:00.000000', 'cpf_cliente': '30030030030', 'endereco_entrega': 'Rua dos Peidoreiros 1', 'status_compra': 2, 'total_pedido': 130.00, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-13 10:00:00.000000', 'cpf_cliente': '46561535839', 'endereco_entrega': 'Rua São Severo, 229', 'status_compra': 2, 'total_pedido': 87.40, 'valor_entrega': 5, 'forma_pgto': 'Dinheiro'},
      {'data_hora': '2026-05-13 18:00:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 1, 'total_pedido': 310.00, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-14 08:30:00.000000', 'cpf_cliente': '90472265008', 'endereco_entrega': 'Rua Conselheiro Brotero, 900', 'status_compra': 2, 'total_pedido': 560.00, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-14 13:00:00.000000', 'cpf_cliente': '90019154003', 'endereco_entrega': 'Rua 45, 3131, São Paulo', 'status_compra': 2, 'total_pedido': 44.80, 'valor_entrega': 5, 'forma_pgto': 'Débito'},
      {'data_hora': '2026-05-15 09:15:00.000000', 'cpf_cliente': '43648210895', 'endereco_entrega': 'R. JOAO JANINI RODRIGUES', 'status_compra': 0, 'total_pedido': 72.00, 'valor_entrega': 5, 'forma_pgto': 'Dinheiro'},
      {'data_hora': '2026-05-15 17:00:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 198.50, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-16 11:00:00.000000', 'cpf_cliente': '30030030030', 'endereco_entrega': 'Rua dos Peidoreiros 1', 'status_compra': 2, 'total_pedido': 320.00, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-16 20:30:00.000000', 'cpf_cliente': '46561535839', 'endereco_entrega': 'Rua São Severo, 229', 'status_compra': 2, 'total_pedido': 145.60, 'valor_entrega': 5, 'forma_pgto': 'Débito'},

      {'data_hora': '2026-05-19 08:00:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 389.00, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-19 15:30:00.000000', 'cpf_cliente': '90019154003', 'endereco_entrega': 'Rua 45, 3131, São Paulo', 'status_compra': 1, 'total_pedido': 110.00, 'valor_entrega': 5, 'forma_pgto': 'Dinheiro'},
      {'data_hora': '2026-05-20 09:00:00.000000', 'cpf_cliente': '90472265008', 'endereco_entrega': 'Rua Conselheiro Brotero, 900', 'status_compra': 2, 'total_pedido': 275.00, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-20 14:00:00.000000', 'cpf_cliente': '43648210895', 'endereco_entrega': 'R. JOAO JANINI RODRIGUES', 'status_compra': 2, 'total_pedido': 98.70, 'valor_entrega': 5, 'forma_pgto': 'Débito'},
      {'data_hora': '2026-05-21 10:30:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 430.00, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-21 19:00:00.000000', 'cpf_cliente': '30030030030', 'endereco_entrega': 'Rua dos Peidoreiros 1', 'status_compra': 0, 'total_pedido': 55.00, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-22 08:30:00.000000', 'cpf_cliente': '46561535839', 'endereco_entrega': 'Rua São Severo, 229', 'status_compra': 2, 'total_pedido': 167.30, 'valor_entrega': 5, 'forma_pgto': 'Dinheiro'},
      {'data_hora': '2026-05-22 13:00:00.000000', 'cpf_cliente': '90019154003', 'endereco_entrega': 'Rua 45, 3131, São Paulo', 'status_compra': 2, 'total_pedido': 310.00, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-23 09:00:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 1, 'total_pedido': 88.00, 'valor_entrega': 5, 'forma_pgto': 'Débito'},
      {'data_hora': '2026-05-23 16:00:00.000000', 'cpf_cliente': '90472265008', 'endereco_entrega': 'Rua Conselheiro Brotero, 900', 'status_compra': 2, 'total_pedido': 245.00, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-24 10:00:00.000000', 'cpf_cliente': '43648210895', 'endereco_entrega': 'R. JOAO JANINI RODRIGUES', 'status_compra': 2, 'total_pedido': 178.50, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-24 18:30:00.000000', 'cpf_cliente': '30030030030', 'endereco_entrega': 'Rua dos Peidoreiros 1', 'status_compra': 2, 'total_pedido': 390.00, 'valor_entrega': 5, 'forma_pgto': 'Dinheiro'},
      {'data_hora': '2026-05-25 09:30:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 512.00, 'valor_entrega': 5, 'forma_pgto': 'Débito'},
      {'data_hora': '2026-05-25 14:00:00.000000', 'cpf_cliente': '46561535839', 'endereco_entrega': 'Rua São Severo, 229', 'status_compra': 1, 'total_pedido': 67.80, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-26 08:00:00.000000', 'cpf_cliente': '90019154003', 'endereco_entrega': 'Rua 45, 3131, São Paulo', 'status_compra': 2, 'total_pedido': 299.00, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
      {'data_hora': '2026-05-26 17:00:00.000000', 'cpf_cliente': '50897126390', 'endereco_entrega': 'Rua Camatei 19, Vila Nivi, SP', 'status_compra': 2, 'total_pedido': 143.20, 'valor_entrega': 5, 'forma_pgto': 'Dinheiro'},
      {'data_hora': '2026-05-27 09:00:00.000000', 'cpf_cliente': '90472265008', 'endereco_entrega': 'Rua Conselheiro Brotero, 900', 'status_compra': 2, 'total_pedido': 330.00, 'valor_entrega': 5, 'forma_pgto': 'Crédito'},
      {'data_hora': '2026-05-27 15:30:00.000000', 'cpf_cliente': '43648210895', 'endereco_entrega': 'R. JOAO JANINI RODRIGUES', 'status_compra': 1, 'total_pedido': 78.90, 'valor_entrega': 5, 'forma_pgto': 'Pix'},
    ];

    for (final dado in dados) {
      await db.insert('vendas', dado, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}

class ProdutosRepository {
  static Future<void> inserir(Map<String, dynamic> produto) async {
    final db = await DatabaseHelper.instance;
    await db.insert(
      'produtos',
      produto,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> listar() async {
    final db = await DatabaseHelper.instance;
    return await db.query('produtos', orderBy: 'nome ASC');
  }

  static Future<void> excluir(int id) async {
    final db = await DatabaseHelper.instance;
    await db.delete('produtos', where: 'id = ?', whereArgs: [id]);
  }
}
