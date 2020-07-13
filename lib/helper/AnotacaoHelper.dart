import 'package:minhas_anotacoes/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotacaoHelper {
  static final String nameDB = "banco_minhas_anotacoes.db";
  static final String nameTable = "anotacao";
  static final String columnId = "id";
  static final String columnTitulo = "titulo";
  static final String columnDescricao = "descricao";
  static final String columnData = "data";

  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database _db;

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }
  AnotacaoHelper._internal();

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initializeDB();
      return _db;
    }
  }

  //* Criando o Banco de Dados
  _onCreate(Database db, int version) async {
    String sql = "CREATE TABLE anotacao " +
        "(id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "titulo VARCHAR, " +
        "descricao TEXT, " +
        "data TEXT)";
    await db.execute(sql);
  }

  Future<Database> initializeDB() async {
    final pathDB = await getDatabasesPath();
    final localDB = join(pathDB, nameDB);

    Database db = await openDatabase(
      localDB,
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
    Database database = await db;
    int id = await database.insert(
      nameTable,
      anotacao.toMap(),
    );
    return id;
  }

  Future<int> atualizarAnotacao(Anotacao anotacao) async {
    Database database = await db;
    int qtdAtualizada = await database.update(
      nameTable,
      anotacao.toMap(),
      where: "id = ?",
      whereArgs: [anotacao.id],
    );
    return qtdAtualizada;
  }

  Future<List> recuperarAnotacoes() async {
    var dataBase = await db;
    String sql = "SELECT * FROM $nameTable ORDER BY $columnData DESC ";
    List anotacoes = await dataBase.rawQuery(sql);
    return anotacoes;
  }

  Future<int> removerAnotacoes(Anotacao anotacao) async {
    var dataBase = await db;
    int qtdDeletada = await dataBase.delete(
      nameTable,
      where: "id = ?",
      whereArgs: [anotacao.id]
    );
    return qtdDeletada;
  }
}
