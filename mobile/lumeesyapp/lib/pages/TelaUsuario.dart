import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaUsuario extends StatefulWidget {
  const TelaUsuario({super.key});

  @override
  State<TelaUsuario> createState() => _TelaUsuarioState();
}

class _TelaUsuarioState extends State<TelaUsuario> {
  final LocationService _locationService = LocationService();

  // USUÁRIO

  final TextEditingController nomeController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController senhaController =
  TextEditingController();

  // PLANTA

  final TextEditingController plantaController =
  TextEditingController();

  final TextEditingController especieController =
  TextEditingController();

  final TextEditingController macController =
  TextEditingController();

  // CONFIGURAÇÕES

  bool notificacoes = true;

  bool localizacao = true;

  bool carregando = false;

  @override
  void initState() {
    super.initState();

    carregarDados();
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();

    plantaController.dispose();
    especieController.dispose();
    macController.dispose();

    super.dispose();
  }

  Future<void> carregarDados() async {

    try {

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      emailController.text = user.email ?? '';

      final usuarioDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (!usuarioDoc.exists) return;

      final usuario = usuarioDoc.data()!;

      nomeController.text =
          usuario['nome'] ?? '';

      notificacoes =
          usuario['notificacoes'] ?? true;

      localizacao =
          usuario['localizacao'] ?? true;

      final idPlanta =
      usuario['id_planta'];

      if (idPlanta != null &&
          idPlanta.toString().isNotEmpty) {

        final plantaDoc = await FirebaseFirestore.instance
            .collection('plantas')
            .doc(idPlanta)
            .get();

        if (plantaDoc.exists) {

          final planta = plantaDoc.data()!;

          plantaController.text =
              planta['nome_apelido'] ?? '';

          especieController.text =
              planta['id_especie']?.toString() ?? '';

          macController.text =
              planta['mac_hardware'] ?? '';
        }
      }

      if (mounted) {
        setState(() {});
      }

    } catch (e) {

      debugPrint(
        'Erro ao carregar usuário: $e',
      );
    }
  }

  Future<void> salvarPerfil() async {

    try {

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({
        'nome': nomeController.text.trim(),
        'email': emailController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Perfil atualizado!',
          ),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    }
  }

  Future<void> salvarPlanta() async {

    try {

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final usuarioDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (!usuarioDoc.exists) return;

      final idPlanta =
      usuarioDoc.data()?['id_planta'];

      if (idPlanta == null ||
          idPlanta.toString().isEmpty) {

        throw Exception(
          'Usuário não possui planta cadastrada.',
        );
      }

      await FirebaseFirestore.instance
          .collection('plantas')
          .doc(idPlanta)
          .update({

        'nome_apelido':
        plantaController.text.trim(),

        'id_especie':
        especieController.text.trim(),

        'mac_hardware':
        macController.text.trim(),

      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Planta atualizada!',
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> salvarPreferencias() async {

    try {

      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({

        'notificacoes':
        notificacoes,

        'localizacao':
        localizacao,

      });

    } catch (e) {

      debugPrint(e.toString());

    }
  }

  Future<void> logout() async {

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/autenticacao',
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Usuário"),
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Column(

                children: [
                  // PERFIL
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.auxSand,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Perfil',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        TextField(
                          controller: nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: senhaController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Nova senha',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: salvarPerfil,
                            icon: const Icon(Icons.save),
                            label: const Text(
                              'Salvar Perfil',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.auxOlive,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // PLANTA
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Row(
                          children: [
                            Icon(
                              Icons.local_florist,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Planta',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        TextField(
                          controller: plantaController,
                          decoration: const InputDecoration(
                            labelText: 'Nome da planta',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.eco),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: especieController,
                          decoration: const InputDecoration(
                            labelText: 'Espécie',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.grass),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: macController,
                          decoration: const InputDecoration(
                            labelText: 'MAC Address',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.memory),
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: salvarPlanta,
                            icon: const Icon(Icons.save),
                            label: const Text(
                              'Salvar Planta',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.auxOlive,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // CONFIGURAÇÕES
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.auxSand,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Row(
                          children: [
                            Icon(
                              Icons.settings,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Configurações',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        SwitchListTile(
                          title: const Text('Permitir localização'),
                          subtitle: const Text(
                            'Utilizar a localização do dispositivo',
                          ),
                          value: localizacao,
                          activeColor: AppTheme.auxOlive,
                          onChanged: (value) async {

                            try {

                              if (value) {
                                await _locationService.getCurrentLocation();
                              }

                              setState(() {
                                localizacao = value;
                              });

                              await salvarPreferencias();

                            } catch (e) {

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                ),
                              );
                            }
                          },
                        ),

                        const Divider(),

                        SwitchListTile(
                          title: const Text('Receber notificações'),
                          subtitle: const Text(
                            'Alertas sobre sua planta',
                          ),
                          value: notificacoes,
                          activeColor: AppTheme.auxOlive,
                          onChanged: (value) async {

                            setState(() {
                              notificacoes = value;
                            });

                            await salvarPreferencias();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  // LOGOUT
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Sair da conta',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.auxDanger,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],

              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: const AppBottomNavigation(
        currentIndex: 4,
      ),
    );
  }
}