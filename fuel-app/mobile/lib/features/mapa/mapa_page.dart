import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/posto.dart';
import '../postos/posto_form.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  GoogleMapController? _mapController;
  LatLng? _minhaPosicao;
  Set<Marker> _markers = {};
  List<Posto> _postosVisiveis = [];
  bool _carregando = true;
  late final RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    try {
      final pos = await LocationService.getPosition();
      if (!mounted) return;
      setState(() {
        _minhaPosicao = LatLng(pos.latitude, pos.longitude);
      });
      await _carregarPostos(pos);
      _escutarRealtime();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _carregarPostos(Position pos) async {
    final delta = 0.05;
    final dados = await SupabaseService.listarPostosPorRegiao(
      minLat: pos.latitude - delta,
      maxLat: pos.latitude + delta,
      minLng: pos.longitude - delta,
      maxLng: pos.longitude + delta,
    );
    final postos = dados.map((d) => Posto.fromJson(d)).toList();
    _atualizarMarcadores(postos);
  }

  void _atualizarMarcadores(List<Posto> postos) {
    final novos = postos.map((p) {
      return Marker(
        markerId: MarkerId(p.id.toString()),
        position: LatLng(p.lat, p.lng),
        infoWindow: InfoWindow(
          title: p.nome,
          snippet: 'R\$ ${p.gasolina.toStringAsFixed(2)} — Gasolina',
          onTap: () => _mostrarAtualizarPreco(p),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          p.gasolina < 5.70
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
      );
    }).toSet();

    if (mounted) {
      setState(() {
        _markers = novos;
        _postosVisiveis = postos;
      });
    }
  }

  void _escutarRealtime() {
    _channel = SupabaseService.escutarPostos((postos) {
      _atualizarMarcadores(postos.map((d) => Posto.fromJson(d)).toList());
    });
  }

  void _mostrarAtualizarPreco(Posto posto) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(posto.nome,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Preço atual: R\$ ${posto.gasolina.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Novo preço da gasolina',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final preco = double.tryParse(
                      controller.text.replaceAll(',', '.'));
                  if (preco == null || preco <= 0) return;
                  try {
                    await SupabaseService.atualizarPreco(posto.id, preco);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preço atualizado! +10 pontos'),
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
                  }
                },
                child: const Text('Salvar preço'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel.unsubscribe();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_minhaPosicao == null) {
      return const Scaffold(
        body: Center(child: Text('Não foi possível obter localização')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _minhaPosicao!,
              zoom: 15,
            ),
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            zoomControlsEnabled: false,
          ),

          // Barra de busca topo
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar posto...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),

          // Botão de localização
          Positioned(
            bottom: 200,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'gps',
              backgroundColor: Colors.white,
              onPressed: () {
                if (_minhaPosicao != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(_minhaPosicao!),
                  );
                }
              },
              child: const Icon(Icons.my_location, color: AppTheme.primary),
            ),
          ),

          // Botão adicionar posto
          Positioned(
            bottom: 140,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'add',
              backgroundColor: AppTheme.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostoForm(
                      posicaoInicial: _minhaPosicao!,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),

          // Lista de postos próximos (bottom sheet)
          DraggableScrollableSheet(
            initialChildSize: 0.22,
            minChildSize: 0.1,
            maxChildSize: 0.6,
            builder: (_, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Postos próximos',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _postosVisiveis.length,
                        itemBuilder: (_, i) {
                          final p = _postosVisiveis[i];
                          return ListTile(
                            leading: const Icon(Icons.local_gas_station,
                                color: AppTheme.primary),
                            title: Text(p.nome),
                            subtitle: Text('${p.cidade} - ${p.estado}'),
                            trailing: Text(
                              'R\$ ${p.gasolina.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  LatLng(p.lat, p.lng),
                                  17,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}