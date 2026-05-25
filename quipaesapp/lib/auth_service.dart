// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_usuario.dart';

class AuthService {
  Future<String?> redefinicaoSenha(String email, [String? senha]) async {
    try {
      final existe = await AuthUsuario().emailJaExiste(email);

      if (existe) {
        return 'reset'; // sinaliza que enviou email de redefinição
      } else {
        return 'cadastro'; // sinaliza que cadastrou
      }
    } on FirebaseAuthException catch (e) {
      return e.code; // retorna o erro
    }
  }
}