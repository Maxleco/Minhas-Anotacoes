import 'package:minhas_anotacoes/helper/AnotacaoHelper.dart';

class Anotacao{
  int id;
  String title;
  String description;
  String data;

  Anotacao(this.title, this.description, this.data);

  Anotacao.fromMap(Map map){
    this.id = map[AnotacaoHelper.columnId];
    this.title = map[AnotacaoHelper.columnTitulo];
    this.description = map[AnotacaoHelper.columnDescricao];
    this.data = map[AnotacaoHelper.columnData];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map ={
      AnotacaoHelper.columnTitulo: this.title,
      AnotacaoHelper.columnDescricao: this.description,
      AnotacaoHelper.columnData: this.data,
    };
    if(this.id != null){
      map[AnotacaoHelper.columnId] = this.id;
    }
    return map;
  }
}