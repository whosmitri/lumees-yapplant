import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // retorna o usuário atualmente autenticado
  // User? get currentUser => _auth.currentUser;

  // monitora em tempo real as alterações de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // login anônimo
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  // CADASTRO (cria no Auth e salva o modelo no Firestore)
  Future<User?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      // cria o usuário no Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // guarda usuário criado
      User? user = userCredential.user;

      if (user != null) {
        // salva o modelo de dados no Cloud Firestore
        await _firestore.collection('usuarios').doc(user.uid).set({
          'uid': user.uid,
          'nome': nome,
          'email': email,
          'id_planta': '', // inicialmente vazio para não quebrar a tela de cadastro!
        });
      }
      return user;
    } catch (e) {
      print("Erro ao cadastrar usuário: $e");
      return null;
    }
  }

  // método de sair da conta (deslogar ou sign out)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}