import 'package:flutter/material.dart';
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // CAMPO DE USUÁRIO
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

          const SizedBox(height: 16), // Espaçamento entre os campos
          // CAMPO DE SENHA
          TextField(
            controller: _passwordController,
            obscureText: _isPasswordHidden, // Transforma texto em bolinhas
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),

              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordHidden = !_isPasswordHidden;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(top: screenHeight * 0.05),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorsTheme.AppColors.primary
              ),
              onPressed: () {
                print('login');
              },
              child: Text('Entrar', style: TextStyle(color: Colors.white, fontSize: 16.0)),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(top: screenHeight * 0.01),
            child: 
            TextButton(
              style: TextButton.styleFrom(overlayColor: colorsTheme.AppColors.primary),
              onPressed: () {},
              child: const Text('Esqueci a senha', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            
            ),
          ),

          Padding(
            padding: EdgeInsetsGeometry.only(top: screenHeight * 0.1),
            child: 
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorsTheme.AppColors.primary,
              ), 
              onPressed: () {},
              child: const Text('Primeiro acesso', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 16.0),),
            
            ),
          ),

        ],
      ),
    );
  }
}
