import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/botao_padrao.dart';
import '../../widgets/input_padrao.dart';

class PostoForm extends StatefulWidget {
  final LatLng posicaoInicial;

  const PostoForm({super.key, required this.posicaoInicial});

  @override
  State<PostoForm> createState() => _PostoFormState();
}

class _PostoFormState extends State<PostoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cidade = TextEditingController();
  final _estado = TextEditingController();
  final _gasolina = TextEditingController();
  final _etanol = TextEditingController();
  final _diesel = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nome.dispose();
    _cidade.dispose();
    _estado.dispose();
    _gasolina.dispose();
    _etanol.dispose();
    _diesel.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await SupabaseService.criarPosto({
        'nome': _nome.text.trim(),
        'cidade': _cidade.text.trim(),
        'estado': _estado.text.trim().toUpperCase(),
        'lat': widget.posicaoInicial.latitude,
        'lng': widget.posicaoInicial.longitude,
        'gasolina': double.parse(_gasolina.text.replaceAll(',', '.')),
        'etanol': _etanol.text.isNotEmpty
            ? double.parse(_etanol.text.replaceAll(',', '.'))
            : null,
        'diesel': _diesel.text.isNotEmpty
            ? double.parse(_diesel.text.replaceAll(',', '.'))
            : null,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Posto cadastrado! +20 pontos'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Posto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informações do posto',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              InputPadrao(
                label: 'Nome do posto',
                controller: _nome,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: InputPadrao(
                      label: 'Cidade',
                      controller: _cidade,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: InputPadrao(
                      label: 'UF',
                      controller: _estado,
                      validator: (v) =>
                          v == null || v.length != 2 ? 'Ex: SP' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Preços',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              InputPadrao(
                label: 'Gasolina (R\$)',
                controller: _gasolina,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Obrigatório';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) {
                    return 'Número inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InputPadrao(
                label: 'Etanol (R\$) — opcional',
                controller: _etanol,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              InputPadrao(
                label: 'Diesel (R\$) — opcional',
                controller: _diesel,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppTheme.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Lat: ${widget.posicaoInicial.latitude.toStringAsFixed(5)} '
                      '| Lng: ${widget.posicaoInicial.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BotaoPadrao(
                texto: 'Cadastrar posto',
                onPressed: _salvar,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}