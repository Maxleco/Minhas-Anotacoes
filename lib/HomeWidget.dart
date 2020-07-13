import 'package:flutter/material.dart';
import 'package:minhas_anotacoes/helper/AnotacaoHelper.dart';
import 'package:minhas_anotacoes/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  AnotacaoHelper _db = AnotacaoHelper();
  List<Anotacao> _listAnotacao = List<Anotacao>();

  //-------------------------------------------------------------------
  void _showScreenDelete({Anotacao anotacao}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("Esta Anotação sera apagada."),
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text("CANCELAR"),
            ),
            FlatButton(
              onPressed: (){
                _removerAnotacao(anotacao);
                Navigator.of(context).pop();
              },
              child: Text("EXCLUIR"),
            ),
          ],
        );
      },
    );
  }

  void _showScreenCrud({Anotacao anotacao}) {
    String textTitleSalarAtualizar = "";
    if (anotacao == null) {
      _titleController.text = "";
      _descriptionController.text = "";
      textTitleSalarAtualizar = "Salvar";
    } else {
      _titleController.text = anotacao.title;
      _descriptionController.text = anotacao.description;
      textTitleSalarAtualizar = "Atualizar";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$textTitleSalarAtualizar Anotação"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Título",
                  hintText: "Digite título...",
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Descrição",
                  hintText: "Digite descrição...",
                ),
              ),
            ],
          ),
          actions: <FlatButton>[
            FlatButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text(textTitleSalarAtualizar),
              onPressed: () {
                _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //* -------------------------------------------------------------------
  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async {
    String title = _titleController.text;
    String description = _descriptionController.text;

    if (anotacaoSelecionada == null) {
      //Salvar
      Anotacao anotacao = Anotacao(
        title,
        description,
        DateTime.now().toString(),
      );
      //int resultado = await _db.salvarAnotacao(anotacao);
      await _db.salvarAnotacao(anotacao);
    } else {
      //Atualizar
      anotacaoSelecionada.title = title;
      anotacaoSelecionada.description = description;
      anotacaoSelecionada.data = DateTime.now().toString();
      // int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
      await _db.atualizarAnotacao(anotacaoSelecionada);
    }

    _titleController.clear();
    _descriptionController.clear();

    _listaDeAnotacoes();
  }

  // -------------------------------------------------------------------
  String _formatarData(String data) {
    initializeDateFormatting("pt_BR");
    DateTime dataConvertida = DateTime.parse(data);
    //var formatter = DateFormat("d/M/y");
    var formatter = DateFormat.yMd("pt_BR");

    String dataFomatada = formatter.format(dataConvertida);
    return dataFomatada;
  }

  //* -------------------------------------------------------------------
  _listaDeAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    List<Anotacao> listAux = List<Anotacao>();
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listAux.add(anotacao);
    }
    setState(() {
      _listAnotacao = listAux;
    });
    //print(anotacoesRecuperadas.toString());
  }

  //* -------------------------------------------------------------------
  _removerAnotacao(Anotacao anotacao) async {
    await _db.removerAnotacoes(anotacao);
    _listaDeAnotacoes();
  }

  @override
  void initState() {
    super.initState();
    _listaDeAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Antações"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _listAnotacao.length,
              itemBuilder: (context, index) {
                final anotacao = _listAnotacao[index];
                String data = _formatarData(anotacao.data);

                return Card(
                  child: ListTile(
                    title: Text(anotacao.title),
                    subtitle: Text(data + " - " + anotacao.description),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 15,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ),
                          onTap: () {
                            _showScreenCrud(anotacao: anotacao);
                          },
                        ),
                        GestureDetector(                          
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 0,
                              left: 3,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Icon(
                              Icons.do_not_disturb_on,
                              color: Colors.red,
                            ),
                          ),
                          onTap: (){
                            _showScreenDelete(anotacao: anotacao);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showScreenCrud();
        },
      ),
    );
  }
}
