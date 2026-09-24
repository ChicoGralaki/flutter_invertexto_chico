import 'package:flutter/material.dart';
import 'package:api_invertexto/service/invertexto_service.dart';

class BuscaCepPage extends StatefulWidget {
  const BuscaCepPage({super.key});

  @override
  State<BuscaCepPage> createState() => _BuscaCepPageState();
}

class _BuscaCepPageState extends State<BuscaCepPage> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final apiService = InvertextoApiService();

  Future<Map<String, dynamic>>? _consulta;

  String? validarCEP(String? valor) {
    final cep = (valor ?? '').trim();

    if (cep.isEmpty) {
      return 'Digite um CEP.';
    }

    if (!RegExp(r'^\d{5}-?\d{3}$').hasMatch(cep)) {
      return 'Digite 8 dígitos, com ou sem hífen. Exemplo: 01001-000.';
    }

    return null;
  }

  void consultar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _consulta = apiService.buscaCEP(_cepController.text);
    });
  }

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  String textoDoCampo(dynamic valor) {
    if (valor is String && valor.trim().isNotEmpty) {
      return valor.trim();
    }

    return 'Não informado';
  }

  Widget exibeResultado(Map<String, dynamic> dados) {
    final endereco = [
      'Rua: ${textoDoCampo(dados['street'])}',
      'Bairro: ${textoDoCampo(dados['neighborhood'])}',
      'Cidade: ${textoDoCampo(dados['city'])}',
      'Estado: ${textoDoCampo(dados['state'])}',
    ].join('\n');

    return SelectableText(
      endereco,
      style: const TextStyle(color: Colors.white, fontSize: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Busca CEP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _consulta,
            builder: (context, snapshot) {
              final carregando =
                  snapshot.connectionState == ConnectionState.waiting;

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Consulte um endereço pelo CEP.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _cepController,
                      validator: validarCEP,
                      enabled: !carregando,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'CEP',
                        hintText: 'Exemplo: 01001000',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        errorMaxLines: 3,
                      ),
                      onChanged: (_) {
                        if (_consulta != null) {
                          setState(() {
                            _consulta = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: carregando ? null : consultar,
                      child: const Text('Buscar CEP'),
                    ),
                    const SizedBox(height: 24),
                    if (carregando) ...[
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Consultando...',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ] else if (_consulta != null && snapshot.hasError)
                      Text(
                        snapshot.error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                        style: const TextStyle(color: Colors.redAccent),
                      )
                    else if (_consulta != null && snapshot.hasData)
                      exibeResultado(snapshot.data!),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
