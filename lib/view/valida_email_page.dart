import 'package:flutter/material.dart';
import 'package:api_invertexto/service/invertexto_service.dart';
import 'package:api_invertexto/view/consulta_painel.dart';

class ValidaEmailPage extends StatefulWidget {
  const ValidaEmailPage({super.key});

  @override
  State<ValidaEmailPage> createState() => _ValidaEmailPageState();
}

class _ValidaEmailPageState extends State<ValidaEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final apiService = InvertextoApiService();

  Future<Object>? _consulta;

  void consultar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _consulta = apiService.validarEmail(_emailController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Widget exibeResultado(Object dados) {
    final mapa = dados as Map<String, dynamic>;

    final formatoValido = mapa['valid_format'] as bool;
    final dominioValido = mapa['valid_mx'] as bool;
    final descartavel = mapa['disposable'] as bool;

    final resultado = [
      'Formato: ${formatoValido ? 'válido' : 'inválido'}',
      'Domínio com registros de e-mail: ${dominioValido ? 'sim' : 'não'}',
      'Endereço descartável: ${descartavel ? 'sim' : 'não'}',
    ].join('\n');

    return SelectableText(
      resultado,
      style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConsultaPainel(
      titulo: 'Validar e-mail',
      orientacao:
          'Verifique o formato, os registros de e-mail do domínio '
          'e se o endereço é descartável. '
          'A consulta não confirma a existência da caixa postal.',
      textoBotao: 'Validar e-mail',
      formKey: _formKey,
      consulta: _consulta,
      consultar: consultar,
      exibeResultado: exibeResultado,
      campos: (carregando) => [
        TextFormField(
          controller: _emailController,
          validator: InvertextoApiService.validarFormatoEmail,
          enabled: !carregando,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: 'E-mail',
            hintText: 'nome@dominio.com',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            errorMaxLines: 3,
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
