class Usuario {
  final String id;
  final String authId;
  final String nome;
  final int pontos;
  final bool premium;

  Usuario({
    required this.id,
    required this.authId,
    required this.nome,
    required this.pontos,
    required this.premium,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      authId: json['auth_id'] ?? '',
      nome: json['nome'] ?? '',
      pontos: json['pontos'] ?? 0,
      premium: json['premium'] ?? false,
    );
  }
}