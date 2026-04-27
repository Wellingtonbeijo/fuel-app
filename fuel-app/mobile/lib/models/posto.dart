class Posto {
  final int id;
  final String nome;
  final String cidade;
  final String estado;
  final double lat;
  final double lng;
  final double gasolina;
  final double? etanol;
  final double? diesel;
  final String? updatedAt;

  Posto({
    required this.id,
    required this.nome,
    required this.cidade,
    required this.estado,
    required this.lat,
    required this.lng,
    required this.gasolina,
    this.etanol,
    this.diesel,
    this.updatedAt,
  });

  factory Posto.fromJson(Map<String, dynamic> json) {
    return Posto(
      id: json['id'],
      nome: json['nome'] ?? '',
      cidade: json['cidade'] ?? '',
      estado: json['estado'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      gasolina: (json['gasolina'] as num).toDouble(),
      etanol: json['etanol'] != null ? (json['etanol'] as num).toDouble() : null,
      diesel: json['diesel'] != null ? (json['diesel'] as num).toDouble() : null,
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'cidade': cidade,
    'estado': estado,
    'lat': lat,
    'lng': lng,
    'gasolina': gasolina,
    'etanol': etanol,
    'diesel': diesel,
  };

  double distanciaKm(double userLat, double userLng) {
    const double grau = 111.0;
    final dLat = (lat - userLat) * grau;
    final dLng = (lng - userLng) * grau;
    return (dLat * dLat + dLng * dLng).toDouble();
  }
}