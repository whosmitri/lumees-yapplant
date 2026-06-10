import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TelaPrincipalWidget(),
  ));
}

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

/// ===============================================================
/// TELA PRINCIPAL
/// ===============================================================
class TelaPrincipalWidget extends StatefulWidget {
  const TelaPrincipalWidget({super.key});

  @override
  State<TelaPrincipalWidget> createState() => _TelaPrincipalWidgetState();
}

class _TelaPrincipalWidgetState extends State<TelaPrincipalWidget> {
  int _currentIndex = 0;
  Position? _posicao;
  String _estacao = "Carregando...";

  // Cores do App centralizadas para facilitar
  final Color _bgCor = const Color(0xFFFBFDF0);
  final Color _textoCor = const Color(0xFF17180D);
  final Color _inativoCor = const Color(0xFFB1B59B);

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
      backgroundColor: _bgCor,
      appBar: AppBar(
        backgroundColor: _bgCor,
        elevation: 2,
        title: Text(
          'Bem-vindo!!',
          style: GoogleFonts.interTight(fontSize: 22, color: _textoCor),
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
                color: _bgCor,
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
              const Expanded(
                child: Center(
                  child: Image(
                    // O caminho da imagem já está ajustado para sua pasta!
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
        selectedItemColor: _textoCor,
        unselectedItemColor: _inativoCor,
        backgroundColor: _bgCor,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.sparkles), label: 'IA'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
    );
  }
}

/// ===============================================================
/// WIDGET DE CARD REUTILIZÁVEL
/// ===============================================================
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}