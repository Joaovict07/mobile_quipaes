import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quipaesapp/auth_usuario.dart';
import 'package:quipaesapp/routes/app_routes.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Login',
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
          // Evita erro de teclado cobrindo os campos
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                // 1. Espaçamento para não ficar colado na AppBar
                SizedBox(height: screenHeight * 0.1),

                // 2. LOGO NO TOPO
                Image.asset(
                  'assets/logo2.png',
                  width: screenWidth * 0.30,
                  height: screenHeight * 0.30,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

                // 3. CAMPO DE USUÁRIO
                TextField(
                  controller: _userController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Usuário',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 4. CAMPO DE SENHA
                TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordHidden,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordHidden = !_isPasswordHidden,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // 5. BOTÃO ENTRAR
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.05),
                  child: SizedBox(
                    width:
                        screenWidth * 0.20, // Botão ocupa a largura permitida
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorsTheme.AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () async {
                        try {
                          await AuthUsuario().login(_userController.text, _passwordController.text);
                          Navigator.pushNamed(context, AppRoutes.menu);
                        }on FirebaseAuthException catch(e) {
                          switch(e.code) {
                            case 'user-not-found':
                              print("Usuário não encontrado!");
                              break;
                            case 'wrong-password':
                              print("Senha incorreta!");
                              break;
                            case 'invalid-credential':
                              print("Email ou senha incorretos!");
                              break;
                            default:
                              print("Erro: ${e.message}");
                              break;
                          }
                        }
                      },
                      child: const Text(
                        'Entrar',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                  ),
                ),

                // 6. ESQUECI A SENHA
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.01),

                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.esqueciSenha),
                    child: const Text(
                      'Esqueci a senha',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 7. PRIMEIRO ACESSO
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.05),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorsTheme.AppColors.primary,
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.esqueciSenha),
                    child: const Text(
                      'Primeiro acesso',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40), // Espaço extra no fim
              ],
            ),
          ),
        ),
      ),
    );
  }
}
