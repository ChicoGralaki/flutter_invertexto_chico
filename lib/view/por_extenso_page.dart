import 'package:flutter/material.dart';
import 'package:api_invertexto/service/invertexto_service.dart';

class PorExtensoPage extends StatefulWidget {
  const PorExtensoPage({super.key});

  @override
  State<PorExtensoPage> createState() => _PorExtensoPageState();
}

class _PorExtensoPageState extends State<PorExtensoPage> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final apiService = InvertextoApiService();

  Future<Map<String, dynamic>>? _consulta;

  String? validarValor(String? valor) {
    final numero = (valor ?? '').trim().replaceAll(',', '.');

    if (numero.isEmpty) {
      return 'Digite um valor.';
    }

    if (!RegExp(r'^\d{1,12}(\.\d{1,2})?$').hasMatch(numero)) {
      return 'Use até 12 dígitos inteiros e 2 casas decimais, '
          'sem separador de milhar.';
    }

    return null;
  }

  void consultar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _consulta = apiService.convertePorExtenso(_valorController.text);
    });
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Número por extenso'),
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
                      'Converta um valor em reais por extenso.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _valorController,
                      validator: validarValor,
                      enabled: !carregando,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Valor em reais',
                        hintText: 'Exemplo: 1250,50',
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
                      child: const Text('Converter'),
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
                      SelectableText(
                        snapshot.data!['text'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
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
