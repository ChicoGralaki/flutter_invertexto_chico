import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:io';
import 'dart:async';

class InvertextoApiService {
  final String _token = const String.fromEnvironment('INVERTEXTO_TOKEN');

  Future<Map<String, dynamic>> convertePorExtenso(String valor) async {
    final numero = valor.trim().replaceAll(',', '.');

    if (numero.isEmpty) {
      throw Exception('Digite um valor para converter.');
    }

    if (!RegExp(r'^\d{1,12}(\.\d{1,2})?$').hasMatch(numero)) {
      throw Exception(
        'Use até 12 dígitos inteiros e 2 casas decimais, '
        'sem separador de milhar. Exemplo: 1250,50.',
      );
    }

    if (_token.trim().isEmpty) {
      throw Exception('Token da API não configurado.');
    }

    final uri = Uri.https('api.invertexto.com', '/v1/number-to-words', {
      'token': _token,
      'number': numero,
      'language': 'pt',
      'currency': 'BRL',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        switch (response.statusCode) {
          case 400:
          case 422:
            throw Exception('A API não aceitou o valor informado.');
          case 401:
          case 403:
            throw Exception('Verifique o token e a permissão para esta API.');
          case 404:
            throw Exception('O recurso solicitado não foi encontrado.');
          case 429:
            throw Exception(
              'Limite de consultas atingido. Tente novamente mais tarde.',
            );
          default:
            throw Exception(
              'Não foi possível concluir a consulta '
              '(erro ${response.statusCode}).',
            );
        }
      }

      if (response.body.trim().isEmpty) {
        throw Exception('A API retornou uma resposta vazia.');
      }

      final dados = json.decode(response.body);

      if (dados is! Map<String, dynamic>) {
        throw Exception('A API retornou uma resposta inesperada.');
      }

      final texto = dados['text'];

      if (texto is! String || texto.trim().isEmpty) {
        throw Exception('A API não retornou o valor por extenso.');
      }

      return dados;
    } on TimeoutException {
      throw Exception('A consulta demorou demais. Tente novamente.');
    } on SocketException {
      throw Exception('Não foi possível conectar. Verifique sua internet.');
    } on http.ClientException {
      throw Exception('Falha na comunicação com a API. Tente novamente.');
    } on FormatException {
      throw Exception('A API retornou dados em formato inválido.');
    }
  }

  Future<Map<String, dynamic>> buscaCEP(String valor) async {
    final entrada = valor.trim();

    if (entrada.isEmpty) {
      throw Exception('Digite um CEP.');
    }

    if (!RegExp(r'^\d{5}-?\d{3}$').hasMatch(entrada)) {
      throw Exception('Digite um CEP com 8 dígitos. Exemplo: 01001-000.');
    }

    final cep = entrada.replaceAll('-', '');

    if (_token.trim().isEmpty) {
      throw Exception('Token da API não configurado.');
    }

    final uri = Uri.https('api.invertexto.com', '/v1/cep/$cep', {
      'token': _token,
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        switch (response.statusCode) {
          case 400:
          case 422:
            throw Exception('A API não aceitou o CEP informado.');
          case 401:
          case 403:
            throw Exception(
              'Verifique o token e a permissão para consultar CEP.',
            );
          case 404:
            throw Exception('CEP não encontrado.');
          case 429:
            throw Exception(
              'Limite de consultas atingido. Tente novamente mais tarde.',
            );
          default:
            throw Exception(
              'Não foi possível consultar o CEP '
              '(erro ${response.statusCode}).',
            );
        }
      }

      if (response.body.trim().isEmpty) {
        throw Exception('A API retornou uma resposta vazia.');
      }

      final dados = json.decode(response.body);

      if (dados is! Map<String, dynamic> || dados.isEmpty) {
        throw Exception('A API não retornou dados válidos para este CEP.');
      }

      final cidade = dados['city'];
      final estado = dados['state'];

      if (cidade is! String ||
          cidade.trim().isEmpty ||
          estado is! String ||
          estado.trim().isEmpty) {
        throw Exception(
          'A resposta do CEP não contém cidade e estado válidos.',
        );
      }

      return dados;
    } on TimeoutException {
      throw Exception('A consulta demorou demais. Tente novamente.');
    } on SocketException {
      throw Exception('Não foi possível conectar. Verifique sua internet.');
    } on http.ClientException {
      throw Exception('Falha na comunicação com a API. Tente novamente.');
    } on FormatException {
      throw Exception('A API retornou dados em formato inválido.');
    }
  }

  static const estados = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  static String? validarFormatoDocumento(String? valor) {
    final texto = (valor ?? '').trim();

    if (texto.isEmpty) {
      return 'Digite um CPF ou CNPJ numérico.';
    }

    final cpf = RegExp(r'^(\d{11}|\d{3}\.\d{3}\.\d{3}-\d{2})$');

    final cnpj = RegExp(r'^(\d{14}|\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2})$');

    if (!cpf.hasMatch(texto) && !cnpj.hasMatch(texto)) {
      return 'Use CPF com 11 dígitos ou CNPJ numérico com 14, '
          'com ou sem pontuação.';
    }

    return null;
  }

  static String? validarFormatoEmail(String? valor) {
    final texto = (valor ?? '').trim();

    if (texto.isEmpty) {
      return 'Digite um e-mail.';
    }

    if (texto.length > 254 || texto.split('@').length != 2) {
      return 'Informe um e-mail como nome@dominio.com.';
    }

    final partes = texto.split('@');
    final nome = partes.first;
    final dominio = partes.last;

    final nomeValido = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+$");

    final parteDominioValida = RegExp(
      r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$',
    );

    if (nome.isEmpty ||
        nome.length > 64 ||
        nome.startsWith('.') ||
        nome.endsWith('.') ||
        nome.contains('..') ||
        !nomeValido.hasMatch(nome) ||
        !dominio.contains('.') ||
        dominio
            .split('.')
            .any(
              (parte) =>
                  parte.isEmpty ||
                  parte.length > 63 ||
                  !parteDominioValida.hasMatch(parte),
            )) {
      return 'Informe um e-mail válido, sem espaços.';
    }

    return null;
  }

  static String? validarAno(String? valor) {
    final texto = (valor ?? '').trim();

    if (texto.isEmpty) {
      return 'Digite o ano.';
    }

    final ano = int.tryParse(texto);

    if (!RegExp(r'^\d{4}$').hasMatch(texto) ||
        ano == null ||
        ano < 1900 ||
        ano > 2100) {
      return 'Informe um ano entre 1900 e 2100.';
    }

    return null;
  }

  // Tratamento compartilhado
  Future<dynamic> _consultarExtra(
    List<String> caminho, [
    Map<String, String> parametros = const {},
  ]) async {
    if (_token.trim().isEmpty) {
      throw Exception('Token da API não configurado.');
    }

    final uri = Uri(
      scheme: 'https',
      host: 'api.invertexto.com',
      pathSegments: ['v1', ...caminho],
      queryParameters: {'token': _token.trim(), ...parametros},
    );

    final client = http.Client();

    try {
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        switch (response.statusCode) {
          case 400:
          case 422:
            throw Exception('A API não aceitou os dados informados.');
          case 401:
          case 403:
            throw Exception('Verifique o token e a permissão para esta API.');
          case 404:
            throw Exception('Nenhum dado encontrado para esta consulta.');
          case 429:
            throw Exception(
              'Limite de consultas atingido. Tente novamente mais tarde.',
            );
          default:
            throw Exception(
              'Não foi possível concluir a consulta '
              '(erro ${response.statusCode}).',
            );
        }
      }

      final corpo = utf8.decode(response.bodyBytes);

      if (corpo.trim().isEmpty) {
        throw Exception('A API retornou uma resposta vazia.');
      }

      final dados = json.decode(corpo);

      if (dados == null) {
        throw Exception('A API não retornou dados.');
      }

      return dados;
    } on TimeoutException {
      throw Exception('A consulta demorou demais. Verifique sua conexão.');
    } on SocketException {
      throw Exception('Não foi possível conectar. Verifique sua internet.');
    } on http.ClientException {
      throw Exception(
        'Falha de comunicação. Verifique sua conexão e tente novamente.',
      );
    } on HandshakeException {
      throw Exception(
        'Falha na conexão segura. Confira a data do aparelho e a rede.',
      );
    } on FormatException {
      throw Exception('A API retornou dados em formato inválido.');
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> validarDocumento(String valor) async {
    final erro = validarFormatoDocumento(valor);

    if (erro != null) {
      throw Exception(erro);
    }

    final numero = valor.replaceAll(RegExp(r'[^0-9]'), '');
    final tipo = numero.length == 11 ? 'cpf' : 'cnpj';

    final dados = await _consultarExtra(
      ['validator'],
      {'value': numero, 'type': tipo},
    );

    if (dados is! Map<String, dynamic> || dados['valid'] is! bool) {
      throw Exception('A API não informou a validade do documento.');
    }

    return {...dados, 'type': tipo.toUpperCase()};
  }

  Future<Map<String, dynamic>> validarEmail(String valor) async {
    final erro = validarFormatoEmail(valor);

    if (erro != null) {
      throw Exception(erro);
    }

    final dados = await _consultarExtra(['email-validator', valor.trim()]);

    if (dados is! Map<String, dynamic> ||
        dados['valid_format'] is! bool ||
        dados['valid_mx'] is! bool ||
        dados['disposable'] is! bool) {
      throw Exception('A API não retornou uma validação completa do e-mail.');
    }

    return dados;
  }

  Future<List<Map<String, dynamic>>> consultarFeriados(
    String valor, {
    String estado = '',
  }) async {
    final erro = validarAno(valor);

    if (erro != null) {
      throw Exception(erro);
    }

    final uf = estado.trim().toUpperCase();

    if (uf.isNotEmpty && !estados.contains(uf)) {
      throw Exception('Selecione um estado válido.');
    }

    final dados = await _consultarExtra(
      ['holidays', valor.trim()],
      {if (uf.isNotEmpty) 'state': uf},
    );

    if (dados is! List) {
      throw Exception('A API retornou uma lista de feriados inválida.');
    }

    final feriados = <Map<String, dynamic>>[];

    for (final item in dados) {
      if (item is! Map<String, dynamic>) {
        throw Exception('A API retornou um feriado inválido.');
      }

      final data = item['date'];
      final nome = item['name'];

      if (data is! String ||
          !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(data) ||
          nome is! String ||
          nome.trim().isEmpty) {
        throw Exception('A API retornou um feriado incompleto.');
      }

      final dataConvertida = DateTime.tryParse(data);

      if (dataConvertida == null ||
          dataConvertida.toIso8601String().substring(0, 10) != data) {
        throw Exception('A API retornou uma data inválida.');
      }

      feriados.add(item);
    }

    feriados.sort(
      (a, b) => (a['date'] as String).compareTo(b['date'] as String),
    );

    return feriados;
  }
}
