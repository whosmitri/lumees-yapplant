/*
DatabaseService
│
├── Usuários
│   ├── usuarioPossuiPlanta()
│   ├── buscarUsuario()
│   └── atualizarUsuario()
│
├── Plantas
│   ├── buscarPlanta()
│   ├── atualizarPlanta()
│   ├── buscarUltimaLeitura()
│   └── adicionarHistorico()
│
└── Espécies
    ├── buscarEspecie()
    └── buscarLimites()
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _usuarios = 'usuarios';
  static const String _plantas = 'plantas';
  static const String _especies = 'especies_catalogo';

  Future<bool> usuarioPossuiPlanta(String uid) async {
    try {
      final userDoc =
          await _db.collection(_usuarios).doc(uid).get();

      if (!userDoc.exists) {
        return false;
      }

      final data = userDoc.data();

      if (data == null) {
        return false;
      }

      final idPlanta =
          (data['id_planta'] ?? '').toString().trim();

      return idPlanta.isNotEmpty;

    } catch (_) {
      return false;
    }
  }
}