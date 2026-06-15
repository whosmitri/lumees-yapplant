import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/air_humidity_chart.dart';
import '../widgets/light_chart.dart';
import '../widgets/soil_humidity_chart.dart';
import '../widgets/temperature_chart.dart';

class TelaDashboardWidget extends StatefulWidget {
  const TelaDashboardWidget({super.key});

  @override
  State<TelaDashboardWidget> createState() => _TelaDashboardWidgetState();
}

class _TelaDashboardWidgetState extends State<TelaDashboardWidget> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  bool _carregando = true;
  String? _erro;

  // Listas locais contendo os tipos exatos dos seus gráficos estruturados na hora
  List<SoilHumidityData> _dadosSolo = [];
  List<LightData> _dadosLuminosidade = [];
  List<TemperatureData> _dadosTemperatura = [];
  List<AirHumidityData> _dadosAr = [];

  StreamSubscription? _plantaSubscription;

  @override
  void initState() {
    super.initState();
    _inicializarDashboard();
  }

  @override
  void dispose() {
    _plantaSubscription?.cancel();
    super.dispose();
  }

  Future<void> _inicializarDashboard() async {
    final usuario = _authService.currentUser;
    if (usuario == null) {
      setState(() {
        _erro = 'Usuário não autenticado.';
        _carregando = false;
      });
      return;
    }

    // Escuta em tempo real para pegar o id_planta correto do usuário
    _plantaSubscription = _databaseService.buscarPlanta(usuario.uid).listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        setState(() {
          _erro = 'Nenhuma planta cadastrada.';
          _carregando = false;
        });
        return;
      }

      final dadosPlanta = snapshot.docs.first.data();
      final idPlanta = dadosPlanta['id_planta'] as String?;

      if (idPlanta == null || idPlanta.isEmpty) {
        setState(() {
          _erro = 'Planta sem ID válido.';
          _carregando = false;
        });
        return;
      }

      // Busca o histórico das últimas 5 horas
      final historico = await _databaseService.buscarHistoricoUltimasHoras(idPlanta);

      // Limpar e reconstruir as listas para os gráficos
      final List<SoilHumidityData> solo = [];
      final List<LightData> luz = [];
      final List<TemperatureData> temp = [];
      final List<AirHumidityData> ar = [];

      for (var leitura in historico) {
        final timestamp = leitura['timestamp'] as Timestamp?;
        if (timestamp == null) continue;

        // Formata a hora para exibir no gráfico (ex: "14h")
        final horaTexto = '${timestamp.toDate().hour}h';

        solo.add(SoilHumidityData(
          hour: horaTexto,
          humidity: (leitura['umidade_solo_porcentagem'] ?? 0).toDouble(),
        ));

        luz.add(LightData(
          hour: horaTexto,
          lux: (leitura['luminosidade'] ?? 0).toDouble(),
        ));

        temp.add(TemperatureData(
          hour: horaTexto,
          temperature: (leitura['temperatura_ar'] ?? 0).toDouble(),
        ));

        ar.add(AirHumidityData(
          hour: horaTexto,
          humidity: (leitura['umidade_ar'] ?? 0).toDouble(),
        ));
      }

      if (!mounted) return;

      setState(() {
        _dadosSolo = solo;
        _dadosLuminosidade = luz;
        _dadosTemperatura = temp;
        _dadosAr = ar;
        _erro = null;
        _carregando = false;
      });
    }, onError: (err) {
      setState(() {
        _erro = 'Erro ao carregar dados em tempo real.';
        _carregando = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth >= 900;
    final double cardWidth = isWideScreen ? 520 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
      ),
      body: SafeArea(
        child: _construirConteudo(cardWidth),
      ),
      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 1,
      ),
    );
  }

  Widget _construirConteudo(double cardWidth) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }

    if (_dadosSolo.isEmpty) {
      return const Center(
        child: Text('Nenhuma leitura registrada nas últimas 5 horas.'),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              SizedBox(
                width: cardWidth,
                child: SoilHumidityChart(data: _dadosSolo),
              ),
              SizedBox(
                width: cardWidth,
                child: LightChart(data: _dadosLuminosidade),
              ),
              SizedBox(
                width: cardWidth,
                child: TemperatureChart(data: _dadosTemperatura),
              ),
              SizedBox(
                width: cardWidth,
                child: AirHumidityChart(data: _dadosAr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}