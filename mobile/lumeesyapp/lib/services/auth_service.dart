import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // retorna o usuário atualmente autenticado
  User? get currentUser => _auth.currentUser;

  // escuta alterações de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // login anônimo
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  // método de sair da conta (deslogar ou sign out)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}