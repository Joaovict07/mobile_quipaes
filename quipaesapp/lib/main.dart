import 'package:flutter/material.dart';
import 'package:quipaesapp/gestao/menu.dart';
import 'package:quipaesapp/gestao/vendas.dart';
import 'package:quipaesapp/login/esqueci_a_senha.dart';
import 'package:quipaesapp/login/login.dart' as login;
import 'package:quipaesapp/login/redefinir_senha.dart';
import 'package:quipaesapp/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

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
        AppRoutes.login: (context) => const Scaffold(body: login.LoginFormWidget()),
        AppRoutes.esqueciSenha: (context) => const Scaffold(body: LoginFormWidget2()),
        AppRoutes.redefinirSenha: (context) => const Scaffold(body: PasswordFormWidget()),
        AppRoutes.menu: (context) => const Scaffold(body: MenuWidget()),
        AppRoutes.vendas: (context) => const Scaffold(body: VendasWidget()),
      },
    );
  }
}