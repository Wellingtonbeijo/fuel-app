import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/posto.dart';

class PostoList extends StatefulWidget {
  const PostoList({super.key});

  @override
  State<PostoList> createState() => _PostoListState();
}

class _PostoListState extends State<PostoList> {
  List<Posto> _postos = [];
  bool _carregando = true;
  late final RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _carregarPostos();
    _channel = SupabaseService.escutarPostos((dados) {
      if (mounted) {
        setState(() {
          _postos = dados.map((d) => Posto.fromJson(d)).toList();
        });
      }
    });
  }

  Future<void> _carregarPostos() async {
    final dados = await SupabaseService.listarPostos();
    if (mounted) {
      setState(() {
        _postos = dados.map((d) => Posto.fromJson(d)).toList();
        _carregando = false;
      });
    }
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postos — Menor Preço')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarPostos,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _postos.length,
                itemBuilder: (_, i) {
                  final p = _postos[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.local_gas_station,
                              color: AppTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.nome,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Text('${p.cidade} — ${p.estado}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'R\$ ${p.gasolina.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Text('gasolina',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}