import 'dart:convert';

import 'package:http/http.dart' as http;

// CONFIGURAÇÃO
class ApiConfig {
  static const String baseUrl =
    "http://127.0.0.1:8000/lumees-api/v1";
}

class ApiService {
  ApiService._();

  // MÉTODOS AUXILIARES

  static Uri _uri(String endpoint) {
    return Uri.parse("${ApiConfig.baseUrl}$endpoint");
  }

  static Map<String, String> get _headers => {
        "Content-Type": "application/json",
      };

  
  // IA

  static Future<Map<String, dynamic>> analisarPlanta() async {

    /* BASE FIREBASE
    final planta = await FirebaseService.obterPlantaSelecionada();

    final idPlanta = planta.id;
    final idEspecie = planta.idEspecie;
    final estacaoAno = await LocalizacaoService.obterEstacaoAtual();
    */

    // MOCK
    const idPlanta = "planta_001";
    const idEspecie = "suculenta";
    const estacaoAno = "Inverno";

    final response = await http.post(
      _uri("/ia/analise"),
      headers: _headers,
      body: jsonEncode({
        "id_planta": idPlanta,
        "id_especie": idEspecie,
        "estacao_ano": estacaoAno,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return body;
    }

    throw Exception(body["detail"] ?? "Erro ao consultar Lee IA.");
  }

}