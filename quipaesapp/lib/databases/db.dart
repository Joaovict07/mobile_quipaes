import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


Future<Database> openDB() async {
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

