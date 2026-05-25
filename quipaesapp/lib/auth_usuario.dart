import 'package:firebase_auth/firebase_auth.dart';

class AuthUsuario {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential> login(String email, String senha) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
    print('Usuário logado!');
    return cred;
  }

  Future<UserCredential> cadastrar(String email, String senha) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
    await cred.user?.sendEmailVerification();
    print('Usuário cadastrado!');
    print('Email de verificação foi enviado!');
    return cred;
  }

  Future<bool> emailJaExiste(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  Future<void> esqueceuSenha(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  User? get usuarioAtual => _auth.currentUser;

  bool get emailVerificado => _auth.currentUser?.emailVerified ?? false;
}