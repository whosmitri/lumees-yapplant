import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import '../theme/app_theme.dart';

class TabSignup extends StatefulWidget {
  const TabSignup({super.key});

  @override
  State<TabSignup> createState() => TabSignupState();
}

class TabSignupState extends State<TabSignup> {

  // instanciando serviço
  final AuthService _authService = AuthService();

  String nome = '';
  String email = '';
  String senha = '';
  String confirmarSenha = '';

  bool mostrarSenha = false;
  bool mostrarConfirmarSenha = false;

  bool carregando = false;

  Future<void> _cadastrar() async {
    // primeiro valida os campos
    if (!_validarFormulario()) return;

    setState(() {
      carregando = true;
    });

    final resultado = await _authService.cadastrarUsuario(
      nome: nome,
      email: email,
      senha: senha,
    );

    if (!mounted) return;

    setState(() {
      carregando = false;
    });

    if (!resultado.sucesso) {
      _mostrarMensagem(resultado.mensagem!);
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/add_planta',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // TÍTULO
          Text(
            'Crie sua conta',
            style: AppTheme.titleMedium,
          ),

          const SizedBox(height: 4),

          Text(
            'Vamos começar preenchendo os campos abaixo:',
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 24),

          // NOME
          _campoTexto(
            label: 'Nome de usuário',
            onChanged: (value) => nome = value,
          ),

          const SizedBox(height: 16),

          // EMAIL
          _campoTexto(
            label: 'E-mail',
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => email = value,
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

            onChanged: (value) => senha = value,
          ),

          const SizedBox(height: 16),

          // CONFIRMAR SENHA
          _campoTexto(
            label: 'Confirmar senha',
            obscureText: !mostrarConfirmarSenha,
            suffixIcon: IconButton(
              icon: Icon(
                mostrarConfirmarSenha
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  mostrarConfirmarSenha =
                      !mostrarConfirmarSenha;
                });
              },
            ),

            onChanged: (value) => confirmarSenha = value,
          ),

          const SizedBox(height: 24),

          // BOTÃO
          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: carregando ? null : _cadastrar,

              child: const Text('Criar Conta'),
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
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,

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

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  bool _validarFormulario() {
    if (nome.trim().isEmpty) {
      _mostrarMensagem(
        'Informe o nome de usuário.',
      );
      return false;
    }

    if (email.trim().isEmpty) {
      _mostrarMensagem(
        'Informe o e-mail.',
      );
      return false;
    }

    if (!email.contains('@')) {
      _mostrarMensagem(
        'Informe um e-mail válido.',
      );
      return false;
    }

    if (senha.length < 6) {
      _mostrarMensagem(
        'A senha deve possuir no mínimo 6 caracteres.',
      );
      return false;
    }

    if (senha != confirmarSenha) {
      _mostrarMensagem(
        'As senhas não coincidem.',
      );
      return false;
    }

    return true;
  }
}