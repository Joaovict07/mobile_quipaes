import 'package:flutter/material.dart';
import 'package:quipaesapp/telas/menu.dart';
import 'package:quipaesapp/telas/vendas.dart';
import 'package:quipaesapp/login/esqueci_a_senha.dart';
import 'package:quipaesapp/telas/login.dart' as login;
import 'package:quipaesapp/login/primeiro_acesso.dart';
import 'package:quipaesapp/telas/estoque.dart';
import 'package:quipaesapp/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quipaesapp/databases/db.dart';


void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await DatabaseHelper.inicializar();
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
        AppRoutes.estoque: (context) => const Scaffold(body: EstoqueWidget()),
      },
    );
  }
}