import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lista_de_compras/screens/home_page/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen()
    );
  }
}
