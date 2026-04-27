import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // ── POSTOS ──────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> listarPostos() async {
    final response = await client
        .from('postos')
        .select()
        .order('gasolina', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> listarPostosPorRegiao({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) async {
    final response = await client
        .from('postos')
        .select()
        .gte('lat', minLat)
        .lte('lat', maxLat)
        .gte('lng', minLng)
        .lte('lng', maxLng)
        .order('gasolina', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> criarPosto(Map<String, dynamic> dados) async {
    await client.from('postos').insert(dados);
  }

  static Future<void> atualizarPreco(int postoId, double preco) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');

    // Atualiza o preço no posto
    await client
        .from('postos')
        .update({'gasolina': preco, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', postoId);

    // Salva no histórico
    await client.from('historico_precos').insert({
      'posto_id': postoId,
      'preco': preco,
      'usuario_id': userId,
      'tipo_combustivel': 'gasolina',
    });

    // Adiciona pontos ao usuário
    await client.rpc('incrementar_pontos', params: {'uid': userId, 'qtd': 10});
  }

  // ── USUÁRIO ─────────────────────────────────────────────

  static Future<Map<String, dynamic>?> buscarPerfil(String userId) async {
    final response = await client
        .from('usuarios')
        .select()
        .eq('auth_id', userId)
        .maybeSingle();
    return response;
  }

  static Future<List<Map<String, dynamic>>> ranking() async {
    final response = await client
        .from('usuarios')
        .select('nome, pontos')
        .order('pontos', ascending: false)
        .limit(10);
    return List<Map<String, dynamic>>.from(response);
  }

  // ── HISTÓRICO ────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> historicoPrecos(int postoId) async {
    final response = await client
        .from('historico_precos')
        .select()
        .eq('posto_id', postoId)
        .order('created_at', ascending: false)
        .limit(30);
    return List<Map<String, dynamic>>.from(response);
  }

  // ── REALTIME ─────────────────────────────────────────────

  static RealtimeChannel escutarPostos(Function(List<Map<String, dynamic>>) onUpdate) {
    return client
        .channel('postos-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'postos',
          callback: (_) async {
            final postos = await listarPostos();
            onUpdate(postos);
          },
        )
        .subscribe();
  }
}