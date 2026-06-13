/*
* verificar se o GPS está ativado
* verificar permissões
* solicitar permissões quando necessário
* obter a localização atual
* retornar a posição atual do usuário
*/

import 'package:geolocator/geolocator.dart';

class LocationService {
  // obtém a localização atual do usuário
  Future<Position> getCurrentLocation() async {
    // verifica se o serviço de localização está ativado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // se o serviço de localização estiver deativado
    if (!serviceEnabled) {
      throw Exception('O serviço de localização está desativado.');
    }

    // verifica a permissão
    LocationPermission permission = await Geolocator.checkPermission();

    // solicita caso necessário
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // usuário recusou novamente
    if (permission == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }

    // usuário recusou permanentemente
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão negada permanentemente. Ative nas configurações do dispositivo.',
      );
    }

    // se deu tudo certo
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

  }
}