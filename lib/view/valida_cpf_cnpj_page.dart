import 'package:flutter/material.dart';
import 'package:api_invertexto/service/invertexto_service.dart';
import 'package:api_invertexto/view/consulta_painel.dart';

class ValidaCpfCnpjPage extends StatefulWidget {
  const ValidaCpfCnpjPage({super.key});

  @override
  State<ValidaCpfCnpjPage> createState() => _ValidaCpfCnpjPageState();
}

class _ValidaCpfCnpjPageState extends State<ValidaCpfCnpjPage> {
  final _formKey = GlobalKey<FormState>();
  final _documentoController = TextEditingController();
  final apiService = InvertextoApiService();

  Future<Object>? _consulta;

  void consultar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _consulta = apiService.validarDocumento(_documentoController.text);
    });
  }

  @override
  void dispose() {
    _documentoController.dispose();
    super.dispose();
  }

  Widget exibeResultado(Object dados) {
    final mapa = dados as Map<String, dynamic>;
    final valido = mapa['valid'] as bool;
    final tipo = mapa['type'] as String;
    final formatado = mapa['formatted'];

    var resultado = '$tipo ${valido ? 'válido' : 'inválido'}.\n';

    resultado += valido
        ? 'Os dígitos verificadores conferem.'
        : 'Os dígitos verificadores não conferem.';

    if (formatado is String && formatado.trim().isNotEmpty) {
      resultado += '\nDocumento: $formatado';
    }

    return SelectableText(
      resultado,
      style: TextStyle(
        color: valido ? Colors.greenAccent : Colors.orangeAccent,
        fontSize: 20,
        height: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConsultaPainel(
      titulo: 'Validar CPF/CNPJ',
      orientacao:
          'Informe um CPF ou CNPJ numérico, com ou sem pontuação. '
          'A consulta verifica os dígitos do documento; '
          'não comprova cadastro ou situação na Receita Federal.',
      textoBotao: 'Validar documento',
      formKey: _formKey,
      consulta: _consulta,
      consultar: consultar,
      exibeResultado: exibeResultado,
      campos: (carregando) => [
        TextFormField(
          controller: _documentoController,
          validator: InvertextoApiService.validarFormatoDocumento,
          enabled: !carregando,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: 'CPF ou CNPJ numérico',
            hintText: '11 ou 14 dígitos',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            errorMaxLines: 4,
          ),
          onFieldSubmitted: (_) {
            if (!carregando) {
              consultar();
            }
          },
          onChanged: (_) {
            if (_consulta != null) {
              setState(() {
                _consulta = null;
              });
            }
          },
        ),
      ],
    );
  }
}
