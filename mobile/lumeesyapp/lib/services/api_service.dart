import 'dart:convert';

import 'package:http/http.dart' as http;

// CONFIGURAÇÃO
class ApiConfig {
  static const String baseUrl =
    "https://lumees-yapplant.onrender.com/lumees-api/v1";
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
  // Agora a função exige os 3 parâmetros reais!
  static Future<Map<String, dynamic>> analisarPlanta({
    required String idPlanta,
    required String idEspecie,
    required String estacaoAno,
  }) async {

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