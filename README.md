# InverTexto

Aplicativo desenvolvido em Flutter para a disciplina de Desenvolvimento de Dispositivos Móveis. Utiliza a API do Invertexto e segue a organização em **views** (telas) e **service** (comunicação com a API).

## Funcionalidades

- **Número por extenso:** converte valores em reais para texto.
- **Busca de CEP:** consulta rua, bairro, cidade e estado.
- **Validação de CPF/CNPJ:** verifica os dígitos de documentos numéricos. Não consulta a situação cadastral.
- **Validação de e-mail:** verifica formato, registros de e-mail do domínio e se o endereço é descartável. Não confirma a existência da caixa postal.
- **Consulta de feriados:** lista feriados e pontos facultativos nacionais e estaduais por ano.

## Validações e tratamento de erros

O aplicativo verifica campos obrigatórios e formatos antes das consultas. Também apresenta mensagens de carregamento e trata falhas de conexão, tempo limite, erros da API e respostas vazias ou inválidas.

## Tecnologias

- Flutter e Dart
- Pacote `http`
- API Invertexto

## Como executar

É necessário ter Flutter, Android SDK e um aparelho Android ou emulador configurado.

1. Baixe as dependências:

```bash
flutter pub get
```

2. Crie o arquivo `config.local.json` na raiz do projeto:

```json
{
  "INVERTEXTO_TOKEN": "SEU_TOKEN_AQUI"
}
```

Gere seu token em [api.invertexto.com](https://api.invertexto.com/) e habilite as APIs `number-to-words`, `cep`, `validator`, `email-validator` e `holidays`.


3. Com o dispositivo conectado ou emulador aberto, execute:

```bash
flutter run --dart-define-from-file=config.local.json
```

As consultas precisam de conexão com a internet.

## Verificação do código

```bash
flutter analyze
```

## Gerar o APK

```bash
flutter build apk --release --dart-define-from-file=config.local.json
```

O APK será gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

O token é incorporado durante a compilação. Mantê-lo fora do repositório não impede sua extração do APK.

## Referência

Projeto baseado no material de aula **Consumo de API com Flutter — Invertexto**, ampliado com três funcionalidades.