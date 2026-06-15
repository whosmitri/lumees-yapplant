import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CardAddPlanta extends StatefulWidget {
  const CardAddPlanta({super.key});

  @override
  State<CardAddPlanta> createState() => _CardAddPlantaState();
}

class _CardAddPlantaState extends State<CardAddPlanta> {

  String? especie;

  String nome = '';
  String macAddress = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),

      decoration: const BoxDecoration(
        color: AppTheme.mainIvory,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      child: SafeArea(
        top: false,

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // BARRA SUPERIOR
              Center(
                child: Container(
                  width: 48,
                  height: 5,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // TÍTULO
              Text(
                'Cadastro de Planta',
                style: AppTheme.titleMedium,
              ),

              const SizedBox(height: 32),

              // ESPÉCIE
              Text(
                'Selecione qual é sua planta',
                style: AppTheme.titleSmall,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: especie,

                decoration: _decoracaoCampo(),

                hint: const Text(
                  'Selecione sua planta',
                ),

                items: const [
                  DropdownMenuItem(
                    value: 'samambaia',
                    child: Text('Samambaia'),
                  ),

                  DropdownMenuItem(
                    value: 'jiboia',
                    child: Text('Jibóia'),
                  ),

                  DropdownMenuItem(
                    value: 'costela',
                    child: Text('Costela-de-Adão'),
                  ),
                ],

                onChanged: (value) {
                  setState(() {
                    especie = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // NOME
              Text(
                'Nome da sua plantinha',
                style: AppTheme.titleSmall,
              ),

              const SizedBox(height: 12),

              _campoTexto(
                label: 'Ex.: Olly',
                onChanged: (value) => nome = value,
              ),

              const SizedBox(height: 24),

              // MAC ADDRESS
              Text(
                'Seu MAC Address único (informado no cartão)',
                style: AppTheme.titleSmall,
              ),

              const SizedBox(height: 12),

              _campoTexto(
                label: 'AA:BB:CC:DD:EE:FF',
                onChanged: (value) => macAddress = value,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {},

                  child: const Text(
                    'Cadastrar planta',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required String label,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      onChanged: onChanged,

      decoration: _decoracaoCampo(
        label: label,
      ),
    );
  }

  InputDecoration _decoracaoCampo({
    String? label,
  }) {
    return InputDecoration(

      labelText: label,

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.all(24),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),

      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
        borderSide: BorderSide(
          color: AppTheme.mainGreen,
          width: 2,
        ),
      ),

      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
        borderSide: BorderSide(
          color: AppTheme.auxDanger,
          width: 2,
        ),
      ),

      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
        borderSide: BorderSide(
          color: AppTheme.auxDanger,
          width: 2,
        ),
      ),
    );
  }
}