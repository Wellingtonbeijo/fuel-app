import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/botao_padrao.dart';
import '../../widgets/input_padrao.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _loading = false;
  bool _isCadastro = false;
  final _nome = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    _nome.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = context.read<AuthService>();
    String? erro;

    if (_isCadastro) {
      erro = await auth.cadastrar(
        nome: _nome.text.trim(),
        email: _email.text.trim(),
        senha: _senha.text,
      );
    } else {
      erro = await auth.login(
        email: _email.text.trim(),
        senha: _senha.text,
      );
    }

    setState(() => _loading = false);

    if (erro != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.local_gas_station,
                    size: 60, color: AppTheme.primary),
                const SizedBox(height: 16),
                Text(
                  _isCadastro ? 'Criar conta' : 'Bem-vindo de volta',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isCadastro
                      ? 'Cadastre-se e comece a economizar'
                      : 'Entre para ver os menores preços',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                if (_isCadastro) ...[
                  InputPadrao(
                    label: 'Nome completo',
                    controller: _nome,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Informe seu nome' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                InputPadrao(
                  label: 'E-mail',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'E-mail inválido' : null,
                ),
                const SizedBox(height: 16),
                InputPadrao(
                  label: 'Senha',
                  controller: _senha,
                  obscure: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 24),
                BotaoPadrao(
                  texto: _isCadastro ? 'Criar conta' : 'Entrar',
                  onPressed: _submit,
                  loading: _loading,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isCadastro = !_isCadastro),
                    child: Text(
                      _isCadastro
                          ? 'Já tem conta? Entrar'
                          : 'Não tem conta? Cadastre-se',
                      style: const TextStyle(color: AppTheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}