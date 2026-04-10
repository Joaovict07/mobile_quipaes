import 'package:flutter/material.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;
import 'package:quipaesapp/routes/app_routes.dart';

class LoginFormWidget2 extends StatefulWidget {
  const LoginFormWidget2({super.key});

  @override
  State<LoginFormWidget2> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget2> {
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
        iconTheme: IconThemeData(
          color: Colors.white
        ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.1),

                // 2. LOGO NO TOPO
                Image.asset(
                  'assets/logo2.png',
                  width: screenWidth * 0.30,
                  height: screenHeight * 0.30,
                  fit: BoxFit.contain,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                        child: Text(
                          "Digite seu e-mail:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // CAMPO DE USUÁRIO
                      TextField(
                        controller: _userController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Email',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.05),
                        child: Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorsTheme.AppColors.primary,
                            ),
                            onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.redefinirSenha)
                            ,
                            child: const Text(
                              'Avançar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
