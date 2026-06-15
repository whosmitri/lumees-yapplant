import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TabLogin extends StatefulWidget {
  const TabLogin({super.key});

  @override
  State<TabLogin> createState() => TabLoginState();
}

class TabLoginState extends State<TabLogin> {

  bool mostrarSenha = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // TÍTULO
          Text(
            'Bem-vindo de volta',
            style: AppTheme.titleMedium,
          ),

          const SizedBox(height: 4),

          Text(
            'Faça login para continuar.',
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 24),

          // EMAIL
          _campoTexto(
            label: 'E-mail',
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // SENHA
          _campoTexto(
            label: 'Senha',

            obscureText: !mostrarSenha,

            suffixIcon: IconButton(
              icon: Icon(
                mostrarSenha
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),

              onPressed: () {
                setState(() {
                  mostrarSenha = !mostrarSenha;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // BOTÃO
          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: () {},

              child: const Text(
                'Entrar',
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _campoTexto({
    required String label,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,

      decoration: InputDecoration(
        labelText: label,

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.all(24),

        suffixIcon: suffixIcon,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: AppTheme.mainGreen,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: AppTheme.auxDanger,
            width: 2,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: AppTheme.auxDanger,
            width: 2,
          ),
        ),
      ),
    );
  }
}