import 'package:flutter/material.dart';

class ConsultaPainel extends StatelessWidget {
  final String titulo;
  final String orientacao;
  final String textoBotao;
  final GlobalKey<FormState> formKey;
  final Future<Object>? consulta;
  final List<Widget> Function(bool carregando) campos;
  final VoidCallback consultar;
  final Widget Function(Object dados) exibeResultado;

  const ConsultaPainel({
    super.key,
    required this.titulo,
    required this.orientacao,
    required this.textoBotao,
    required this.formKey,
    required this.consulta,
    required this.campos,
    required this.consultar,
    required this.exibeResultado,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(titulo),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<Object>(
            future: consulta,
            builder: (context, snapshot) {
              final carregando =
                  snapshot.connectionState == ConnectionState.waiting;

              return Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      orientacao,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    const SizedBox(height: 20),
                    ...campos(carregando),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: carregando ? null : consultar,
                      child: Text(textoBotao),
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
                    ] else if (consulta != null && snapshot.hasError)
                      Text(
                        snapshot.error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                      )
                    else if (consulta != null && snapshot.hasData)
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
