import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quipaesapp/auth_usuario.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;
import 'package:quipaesapp/telas/esqueci_a_senha.dart';

class PasswordFormWidget extends StatefulWidget {
  const PasswordFormWidget({super.key});

  @override
  State<PasswordFormWidget> createState() => _PasswordFormWidgetState();
}

class _PasswordFormWidgetState extends State<PasswordFormWidget> {
  // Use nomes claros para os controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final email = ModalRoute.of(context)?.settings.arguments as String?;
    if(email != null) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void redefinicaoSenha(String email, String senha) async {
  if (_passwordController.text != _confirmPasswordController.text) {
    print('A senha e a confirmação da senha não são iguais!');
    return;
  }

  try {
    final existe = await AuthUsuario().emailJaExiste(email);

    if (existe) {
      // E-mail já cadastrado → redefine a senha e volta pro login
      await AuthUsuario().esqueceuSenha(email);
      print('E-mail de redefinição enviado!');
      Navigator.pushNamed(context, '/');

    } else {
      // E-mail não cadastrado → cadastra o usuário
      await AuthUsuario().cadastrar(email, senha);
      print('Usuário cadastrado com sucesso!');
      Navigator.pushNamed(context, '/');
    }

  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'weak-password':
        print('Senha muito fraca!');
        break;
      case 'invalid-email':
        print('E-mail inválido!');
        break;
      default:
        print('Erro: ${e.message}');
        break;
    }
  }
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Identificação',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorsTheme.AppColors.primary,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fundo2.png'),
            repeat: ImageRepeat.repeat,
            fit: BoxFit.scaleDown,
            opacity: 0.25,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: screenHeight * 0.25),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Código
              Center(
                child: SizedBox(
                  width:
                      screenWidth *
                      0.7, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                    // Senha
                      const Text(
                        "Nova Senha:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Digite a nova senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                    // Confirmar senha
                      const Text(
                        "Confirmar Senha:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Confirme a senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 64),

                      // Redefinir senha
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorsTheme.AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                          ),
                          onPressed: () {
                            final email = ModalRoute.of(context)!.settings.arguments as String;
                            print('Senha redefinida com sucesso');
                            redefinicaoSenha(email, _passwordController.text);
                          },
                          child: const Text(
                            'Redefinir',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}