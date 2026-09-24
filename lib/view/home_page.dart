import 'package:flutter/material.dart';
import 'package:api_invertexto/view/por_extenso_page.dart';
import 'package:api_invertexto/view/busca_cep_page.dart';
import 'package:api_invertexto/view/valida_cpf_cnpj_page.dart';
import 'package:api_invertexto/view/valida_email_page.dart';
import 'package:api_invertexto/view/feriados_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget itemMenu(String titulo, IconData icone, VoidCallback aoTocar) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: aoTocar,
        child: Row(
          children: [
            Icon(icone, color: Colors.white, size: 50),
            const SizedBox(width: 30),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('InverTexto'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              itemMenu('Por Extenso', Icons.edit, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PorExtensoPage(),
                  ),
                );
              }),
              itemMenu('Busca CEP', Icons.home, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuscaCepPage()),
                );
              }),
              itemMenu('Validar CPF/CNPJ', Icons.badge, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ValidaCpfCnpjPage(),
                  ),
                );
              }),
              itemMenu('Validar e-mail', Icons.email, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ValidaEmailPage(),
                  ),
                );
              }),
              itemMenu('Consultar feriados', Icons.calendar_month, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeriadosPage()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
