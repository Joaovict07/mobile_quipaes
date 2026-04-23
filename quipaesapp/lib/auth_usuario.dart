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
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: '________',
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') return true;
      if (e.code == 'user-not-found') return false;
      // invalid-credential aparece em versões novas do Firebase
      if (e.code == 'invalid-credential') return true;
      return false;
    }
  }

  Future<void> esqueceuSenha(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  User? get usuarioAtual => _auth.currentUser;

  bool get emailVerificado => _auth.currentUser?.emailVerified ?? false;
}