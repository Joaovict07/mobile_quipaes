import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;
import 'package:quipaesapp/login/login.dart' as login;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Login',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: colorsTheme.AppColors.primary,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fundo2.png'),
              repeat: ImageRepeat.repeat,
              fit: BoxFit.scaleDown,
              opacity: 0.25, 
            ),
          ),
          child: Column(
            
            children: [

              const SizedBox(height: 30), 
              
              Image.asset(
                'assets/logo2.png',
                width: screenWidth * 0.30,
                height: screenHeight * 0.30,
                fit: BoxFit.contain,
              ),
              
            
              const SizedBox(height: 50), 
              
    
              const login.LoginFormWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

