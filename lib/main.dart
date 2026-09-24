import 'package:flutter/material.dart';
import 'package:api_invertexto/view/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'InverTexto',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
