import 'package:flutter/material.dart';
import 'package:api_invertexto/service/invertexto_service.dart';
import 'package:api_invertexto/view/consulta_painel.dart';

class FeriadosPage extends StatefulWidget {
  const FeriadosPage({super.key});

  @override
  State<FeriadosPage> createState() => _FeriadosPageState();
}

class _FeriadosPageState extends State<FeriadosPage> {
  final _formKey = GlobalKey<FormState>();

  final _anoController = TextEditingController(
    text: DateTime.now().year.toString(),
  );

  final apiService = InvertextoApiService();

  Future<Object>? _consulta;
  String _estado = '';

  void consultar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _consulta = apiService.consultarFeriados(
        _anoController.text,
        estado: _estado,
      );
    });
  }

  @override
  void dispose() {
    _anoController.dispose();
    super.dispose();
  }

  String textoDoCampo(dynamic valor) {
    if (valor is String && valor.trim().isNotEmpty) {
      return valor.trim();
    }

    return 'Não informado';
  }

  Widget exibeResultado(Object dados) {
    final feriados = dados as List<Map<String, dynamic>>;

    if (feriados.isEmpty) {
      return const Text(
        'Nenhum feriado encontrado para esta consulta.',
        style: TextStyle(color: Colors.white, fontSize: 18),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${feriados.length} datas encontradas',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...feriados.map((feriado) {
          final partes = (feriado['date'] as String).split('-');
          final data = '${partes[2]}/${partes[1]}/${partes[0]}';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF202020),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              '$data — ${feriado['name']}\n'
              'Tipo: ${textoDoCampo(feriado['type'])}\n'
              'Abrangência: ${textoDoCampo(feriado['level'])}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                height: 1.5,
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConsultaPainel(
      titulo: 'Consultar feriados',
      orientacao:
          'Consulte feriados e pontos facultativos de 1900 a 2100. '
          'Selecione uma UF para incluir também as datas estaduais.',
      textoBotao: 'Consultar feriados',
      formKey: _formKey,
      consulta: _consulta,
      consultar: consultar,
      exibeResultado: exibeResultado,
      campos: (carregando) => [
        TextFormField(
          controller: _anoController,
          validator: InvertextoApiService.validarAno,
          enabled: !carregando,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: 'Ano',
            hintText: '2026',
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
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _estado,
          isExpanded: true,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: const InputDecoration(
            labelText: 'Estado',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: '', child: Text('Somente nacionais')),
            ...InvertextoApiService.estados.map(
              (uf) => DropdownMenuItem(value: uf, child: Text(uf)),
            ),
          ],
          onChanged: carregando
              ? null
              : (valor) {
                  setState(() {
                    _estado = valor ?? '';
                    _consulta = null;
                  });
                },
        ),
      ],
    );
  }
}
