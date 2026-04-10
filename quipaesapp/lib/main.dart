import 'package:flutter/material.dart';
import 'package:quipaesapp/gestao/menu.dart';
import 'package:quipaesapp/login/esqueci_a_senha.dart';
import 'package:quipaesapp/login/login.dart' as login;
import 'package:quipaesapp/login/redefinir_senha.dart';
import 'package:quipaesapp/routes/app_routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      routes: {
        // Envolva em um Scaffold aqui ou dentro do próprio arquivo da tela
        AppRoutes.login: (context) => const Scaffold(body: login.LoginFormWidget()),
        AppRoutes.esqueciSenha: (context) => const Scaffold(body: LoginFormWidget2()),
        AppRoutes.redefinirSenha: (context) => const Scaffold(body: PasswordFormWidget()),
        AppRoutes.menu: (context) => const Scaffold(body: MenuWidget()),
      },
    );
  }
}