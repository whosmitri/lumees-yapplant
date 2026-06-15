import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthResult {
  final bool sucesso;
  final User? usuario;
  final String? mensagem;

  const AuthResult({
    required this.sucesso, // deu certo?
    this.usuario, // qual usuário?
    this.mensagem, // qual mensagem mostrar?
  });
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // constante da coleção de usuários
  static const String usuarios = 'usuarios';

  // retorna o usuário atualmente autenticado
  User? get currentUser => _auth.currentUser;

  // monitora em tempo real as alterações de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // login anônimo
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  // CADASTRO (cria no Auth e salva o modelo no Firestore)
  Future<AuthResult> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      // cria o usuário no Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // guarda usuário criado
      final user = userCredential.user;

      if (user == null) {
        return const AuthResult(
          sucesso: false,
          mensagem: 'Não foi possível criar a conta.',
        );
      }

      await _firestore.collection(usuarios).doc(user.uid).set({
          'uid': user.uid,
          'nome': nome,
          'email': email,
          'id_planta': '', // inicialmente vazio para não quebrar a tela de cadastro!
      });

      return AuthResult(
        sucesso: true,
        usuario: user,
      );

    } on FirebaseAuthException catch (e) { // para capturar o erro
      // para mostrar diferentes mensagem de acordo com os erros
      switch (e.code) {
        case 'email-already-in-use':
          return const AuthResult(
            sucesso: false,
            mensagem: 'Este e-mail já está cadastrado.',
          );

        case 'invalid-email':
          return const AuthResult(
            sucesso: false,
            mensagem: 'E-mail inválido.',
          );

        case 'weak-password':
          return const AuthResult(
            sucesso: false,
            mensagem: 'A senha é muito fraca.',
          );

        default:
          return AuthResult(
            sucesso: false,
            mensagem: e.message ?? 'Erro ao criar conta.',
          );
      }
    } catch (_) {
      return const AuthResult(
        sucesso: false,
        mensagem: 'Erro inesperado ao criar conta.',
      );
    }
  }

  // LOGIN (para usuários já existentes)
  Future<AuthResult> logarUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final user = userCredential.user;

      if (user == null) {
        return const AuthResult(
          sucesso: false,
          mensagem: 'Não foi possível realizar o login.',
        );
      }

      return AuthResult(
        sucesso: true,
        usuario: user,
      );
    } on FirebaseAuthException catch (e) {
      // para mostrar diferentes mensagem de acordo com os erros
      switch (e.code) {
        case 'invalid-email':
          return const AuthResult(
            sucesso: false,
            mensagem: 'E-mail inválido.',
          );

        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return const AuthResult(
            sucesso: false,
            mensagem: 'E-mail ou senha incorretos.',
          );

        case 'user-disabled':
          return const AuthResult(
            sucesso: false,
            mensagem: 'Esta conta foi desativada.',
          );

        case 'too-many-requests':
          return const AuthResult(
            sucesso: false,
            mensagem: 'Muitas tentativas. Tente novamente mais tarde.',
          );

        default:
          return AuthResult(
            sucesso: false,
            mensagem: e.message ?? 'Erro ao realizar login.',
          );
      }
    } catch (_) {
      return const AuthResult(
        sucesso: false,
        mensagem: 'Erro inesperado ao realizar login.',
      );
    }
  }

  // LOGOUT (deslogar, sair da conta ou sign out)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}