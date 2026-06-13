/* RETORNO DO SUNRISE-SUNSET API:
{
  "results": {
    "sunrise": "2026-06-13T09:33:00+00:00",
    "sunset": "2026-06-13T20:28:00+00:00",
    "solar_noon": "...",
    ...
  },
  "status": "OK"
}

usar apenas: "sunrise" e "sunset"
*/


import 'dart:convert';
import 'package:http/http.dart' as http;

class TimeService {
  Future<String> getDayPeriod(
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.parse(
      'https://api.sunrise-sunset.org/json'
      '?lat=$latitude'
      '&lng=$longitude'
      '&formatted=0',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro ao consultar Sunrise-Sunset API.');
    }

    final json = jsonDecode(response.body);

    if (json['status'] != 'OK') {
      throw Exception('Resposta inválida da API.');
    }

    final results = json['results'];

    // converte os horários UTC da API para o fuso horário local do aparelho
    final sunrise = DateTime.parse(results['sunrise']).toLocal();
    final sunset = DateTime.parse(results['sunset']).toLocal();
    final now = DateTime.now();

    // se o momento atual for após o nascer do sol E antes do pôr do sol, é Dia
    if (now.isAfter(sunrise) && now.isBefore(sunset)) {
      return 'Dia';
    }

    // caso contrário, é Noite (antes de amanhecer ou após escurecer)
    return 'Noite';
  }
}