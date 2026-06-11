import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';

/// ===============================================================
/// MODELOS
/// ===============================================================
class UltimaLeitura {
  final DateTime timestamp;
  final double umidadeSoloBruto;
  final double umidadeSoloPorcentagem;
  final double luminosidade;
  final double temperaturaAr;
  final double umidadeAr;

  UltimaLeitura({
    required this.timestamp,
    required this.umidadeSoloBruto,
    required this.umidadeSoloPorcentagem,
    required this.luminosidade,
    required this.temperaturaAr,
    required this.umidadeAr,
  });
}

class Planta {
  final String idPlanta;
  final String nomeApelido;
  final String idEspecie;
  final UltimaLeitura ultimaLeitura;

  Planta({
    required this.idPlanta,
    required this.nomeApelido,
    required this.idEspecie,
    required this.ultimaLeitura,
  });
}

/// ===============================================================
/// MOCK SERVICE (SIMULA O FIREBASE)
/// ===============================================================
class PlantaServiceMock {
  static Stream<Planta> getPlantaStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield Planta(
        idPlanta: "planta_01",
        nomeApelido: "Minha Planta",
        idEspecie: "suculenta",
        ultimaLeitura: UltimaLeitura(
          timestamp: DateTime.now(),
          umidadeSoloBruto: 300,
          umidadeSoloPorcentagem: 20,
          luminosidade: 3000,
          temperaturaAr: 23,
          umidadeAr: 45,
        ),
      );
    }
  }
}

/// ===============================================================
/// LÓGICA DE ESTAÇÃO DO ANO
/// ===============================================================
String obterEstacaoDoAno(Position posicao) {
  final mes = DateTime.now().month;
  if (posicao.latitude < 0) {
    if (mes >= 3 && mes <= 5) return 'Outono';
    if (mes >= 6 && mes <= 8) return 'Inverno';
    if (mes >= 9 && mes <= 11) return 'Primavera';
    return 'Verão';
  } else {
    if (mes >= 3 && mes <= 5) return 'Primavera';
    if (mes >= 6 && mes <= 8) return 'Verão';
    if (mes >= 9 && mes <= 11) return 'Outono';
    return 'Inverno';
  }
}

class TelaPrincipalWidget extends StatefulWidget {
  const TelaPrincipalWidget({super.key});

  @override
  State<TelaPrincipalWidget> createState() => _TelaPrincipalWidgetState();
}

class _TelaPrincipalWidgetState extends State<TelaPrincipalWidget> {
  int _currentIndex = 0;
  Position? _posicao;
  String _estacao = "Carregando...";

  @override
  void initState() {
    super.initState();
    _pegarLocalizacao();
  }

  Future<void> _pegarLocalizacao() async {
    LocationPermission perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      setState(() {
        _posicao = pos;
        _estacao = obterEstacaoDoAno(pos);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainIvory, // Puxando do seu tema
      appBar: AppBar(
        backgroundColor: AppTheme.mainIvory, // Mesma cor do fundo
        elevation: 0, // Tiramos a sombra para fundir 100% com o fundo
        scrolledUnderElevation: 0, // Evita mudança de cor ao rolar (Material 3)
        title: Text(
          'Bem-vindo!!',
          style: GoogleFonts.interTight(fontSize: 22, color: AppTheme.mainDark),
        ),
      ),
      body: StreamBuilder<Planta>(
        stream: PlantaServiceMock.getPlantaStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final leitura = snapshot.data!.ultimaLeitura;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: AppTheme.mainIvory,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoCard(title: 'Umidade\ndo Solo', value: '${leitura.umidadeSoloPorcentagem.toStringAsFixed(0)}%'),
                    _InfoCard(title: 'Luminosidade', value: '${leitura.luminosidade.toInt()}'),
                    _InfoCard(title: 'Umidade\ndo Ar', value: '${leitura.umidadeAr.toInt()}%'),
                    _InfoCard(title: 'Temperatura', value: '${leitura.temperaturaAr.toInt()}ºC'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Estação: $_estacao",
                style: GoogleFonts.inter(fontSize: 16, color: AppTheme.mainDark),
              ),
              const SizedBox(height: 20),
              const Expanded(
                child: Center(
                  child: Image(
                    image: AssetImage('assets/images/estados_planta/estado-normal.png'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: AppTheme.mainDark, // Ícone selecionado escuro
        unselectedItemColor: AppTheme.auxOlive, // Ícone inativo num verde mais discreto
        backgroundColor: AppTheme.mainIvory,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 8, // Mantém a sombrinha no menu inferior
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Principal'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.sparkles), label: 'IA'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuário'),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title, 
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.mainDark), // Texto escuro
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: AppTheme.mainGreen, // Valores em destaque com o seu verde!
          ),
        ),
      ],
    );
  }
}