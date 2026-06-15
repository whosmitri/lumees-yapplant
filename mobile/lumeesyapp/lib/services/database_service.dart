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

  // USUÁRIOS
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

  // ESPÉCIES
  Future<List<Map<String, dynamic>>> buscarEspecies() async {
    final snapshot = await _db.collection(_especies).get();

    return snapshot.docs.map((doc) {
      return doc.data();
    }).toList();
  }

  // PLANTAS
  Future<String?> cadastrarPlanta({
    required String uid,
    required String nomeApelido,
    required String idEspecie,
    required String macHardware
  }) async {
    try {
      final plantaRef = _db.collection(_plantas).doc();

      await plantaRef.set({
        'id_planta': plantaRef.id,
        'uid': uid,
        'nome_apelido': nomeApelido,
        'id_especie': idEspecie,
        'mac_hardware': macHardware,
        'ultima_leitura': {
          'timestamp': null,
          'umidade_solo_bruto': 0,
          'umidade_solo_porcentagem': 0,
          'luminosidade': 0,
          'temperatura_ar': 0,
          'umidade_ar': 0,
        },
      });

      return plantaRef.id;
    } catch (_) {
      return null;
    }
  }

  // USUÁRIOS
  Future<void> atualizarIdPlantaUsuario({
    required String uid,
    required String idPlanta,
  }) async {
    await _db.collection(_usuarios).doc(uid).update({
      'id_planta': idPlanta,
    });
  }

  // PLANTAS
  Stream<QuerySnapshot<Map<String, dynamic>>> buscarPlanta(String uid) {
    return _db
        .collection(_plantas)
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  // ESPÉCIES
  Future<Map<String, dynamic>?> obterEspeciePorId(String idEspecie) async {
    try {
      final doc = await _db
          .collection(_especies)
          .doc(idEspecie)
          .get();

      return doc.data();

    } catch (_) {
      return null;
    }
  }

  // PLANTAS
  Future<List<Map<String, dynamic>>> buscarHistoricoUltimasHoras(String idPlanta) async {
    try {
      final cincoHorasAtras = DateTime.now().subtract(const Duration(hours: 5));
      
      final snapshot = await _db
          .collection(_plantas)
          .doc(idPlanta)
          .collection('historico_leituras')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(cincoHorasAtras))
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      return [];
    }
  }
}