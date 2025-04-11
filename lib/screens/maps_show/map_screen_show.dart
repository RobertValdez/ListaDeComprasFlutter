import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late Future<String> _mbtilesPath;
  Database? _database;

  @override
  void initState() {
    super.initState();
    _mbtilesPath = _prepareMbtilesFile();
    _obtenerUbicacion();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 1.0,
      upperBound: 1.3, // Hace que el icono crezca un poco al seleccionar
    );
  }

  Future<String> _prepareMbtilesFile() async {
    final dir = await getApplicationDocumentsDirectory();
    const String nomMbTilesFile = "lista_compras_2025-03-28_130440.mbtiles";
    final mbtilesFile = File('${dir.path}/$nomMbTilesFile');

    if (!await mbtilesFile.exists()) {
      final ByteData data = await rootBundle.load(
        'assets/maps/$nomMbTilesFile',
      );
      await mbtilesFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    _database = await openDatabase(mbtilesFile.path);
    return mbtilesFile.path;
  }

  //LatLng? _lastSnackBarMessage;
  bool _snackBarAlreadyShow(LatLng point) {
    if (selectedMarker?.latitude == point.latitude &&
        selectedMarker?.longitude == point.longitude) {
      return true; // ya está mostrado // Abre
    }

    _scaffoldMessengerKey.currentState
        ?.hideCurrentSnackBar(); // Cierra el snackbar anterior
    return false; //Cierra
  }

  bool _selectMarker(LatLng point) {
    bool valAlreadyShowSnackBar = _snackBarAlreadyShow(point);
    if (mounted) {
      setState(() {
        selectedMarker = point;
      });
    }
    _animationController.forward(from: 1.0); // Reinicia la animación
    return valAlreadyShowSnackBar;
  }

  @override
  void dispose() {
    _database?.close();

    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(title: const Text("Mapa Offline")),
        body: GestureDetector(
          onTap: () {
            _scaffoldMessengerKey.currentState
                ?.hideCurrentSnackBar(); // Cierra el snackbar al tocar fuera
            if (mounted) {
              setState(() => selectedMarker = null); // Deselecciona el marcador
            }
          },
          child: FutureBuilder<String>(
            future: _mbtilesPath,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              return FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    18.222610,
                    -71.124255,
                  ), // Coordenadas iniciales
                  initialZoom: 18.0, // Nivel de zoom inicial
                  //maxZoom: 15.0, // Bloquea la ampliación del zoom
                  minZoom: 15.0, // Bloquea la reducción del zoom
                  initialRotation: 0.0, // Rotación inicial
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag
                            .drag, // Desactiva todas las interacciones
                  ),
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      const LatLng(
                        18.220885,
                        -71.125491,
                      ), // Esquina inferior izquierda
                      const LatLng(
                        18.223793,
                        -71.123681,
                      ), // Esquina superior derecha
                    ),
                  ),
                ),
                children: [
                  TileLayer(tileProvider: MBTilesTileProvider(_database!)),
                  MarkerLayer(
                    markers: [
                      if (_miUbicacion != null)
                        Marker(
                          point: LatLng(18.222081, -71.124550),
                          child: Icon(
                            Icons.my_location,
                            color: const Color.fromARGB(255, 8, 70, 120),
                            size: 35,
                          ),
                        ),
                      _createMarker(
                        context,
                        LatLng(18.222081, -71.124362),
                        "Galletas dulce: 1 paquete de limon Wafer",
                        "Alt: 1 paquete de fresa Wafer",
                        false,
                      ),
                      _createMarker(
                        context,
                        LatLng(18.222005, -71.124201),
                        "Pampitas: 1 Paquete, pequeñitas de 8 Oz",
                        "Alt: 1 Paquete, pequeñitas de 20 Oz",
                        false,
                      ),
                      _createMarker(
                        context,
                        LatLng(18.222336, -71.124163),
                        "Queso Gouda Importado Rebanado: 2 unidades",
                        "Alt: No comprar",
                        true,
                      ),
                      _createMarker(
                        context,
                        LatLng(18.222336, -71.124463),
                        "Mantequilla de Mani crujiente: 1",
                        "Alt: Mermelada de fresa: 1",
                        true,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  LatLng? selectedMarker;
  late AnimationController _animationController;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Marker _createMarker(
    BuildContext context,
    LatLng point,
    String title,
    String content,
    bool marked,
  ) {
    bool isSelected = selectedMarker == point;

    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          // Evitar mostrar múltiples SnackBars si ya está seleccionado
          if (_selectMarker(point) != true) {
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(days: 1),
                margin: const EdgeInsets.only(bottom: 500, left: 20, right: 20),
                content: _buildSnackBarContent(title, content, marked),
              ),
            );
          }
        },

        // 👇 Aquí va solo la parte visual del marcador
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? _animationController.value : 1.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(
                          (255 * 0.3).round(),
                        ), // Opacidad 30% - Base circular azul
                        shape: BoxShape.circle,
                      ),
                    ),
                  Icon(
                    marked ? Icons.where_to_vote : Icons.location_on,
                    color: marked ? Colors.green : Colors.red,
                    size: isSelected ? 45 : 40,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSnackBarContent(String title, String content, bool marked) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color.fromARGB(255, 229, 236, 255),
                child: Icon(
                  marked ? Icons.check_circle : Icons.info,
                  color: marked ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    Text(
                      content,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                  if (mounted) {
                    setState(() => selectedMarker = null);
                  }
                },
                child: const Text(
                  "Cerrar",
                  style: TextStyle(color: Colors.red, fontSize: 16.0),
                ),
              ),
              TextButton(
                onPressed: () {
                  _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                  if (mounted) {
                    setState(() => selectedMarker = null);
                  }
                  // Aquí iría lógica para guardar en base de datos, etc.
                },
                child: Text(
                  marked ? "Desmarcar" : "Marcar",
                  style: TextStyle(
                    color: marked ? Colors.red : Colors.green,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LatLng? _miUbicacion;

  Future<void> _obtenerUbicacion() async {
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    LocationPermission permiso = await Geolocator.checkPermission();

    if (!servicioActivo ||
        permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        return;
      }
    }

    Position posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        _miUbicacion = LatLng(posicion.latitude, posicion.longitude);
      });
    }
  }
}

class MBTilesTileProvider extends TileProvider {
  final Database database;

  MBTilesTileProvider(this.database);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return MBTilesImageProvider(
      database: database,
      zoom: coordinates.z.round(),
      x: coordinates.x.round(),
      y:
          (1 << coordinates.z.round()) -
          1 -
          coordinates.y.round(), // Conversión de TMS a OSM
    );
  }
}

class MBTilesImageProvider extends ImageProvider<MBTilesImageProvider> {
  final Database database;
  final int zoom, x, y;

  MBTilesImageProvider({
    required this.database,
    required this.zoom,
    required this.x,
    required this.y,
  });

  @override
  Future<MBTilesImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<MBTilesImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    MBTilesImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(codec: _loadAsync(key), scale: 1.0);
  }

  Future<Codec> _loadAsync(MBTilesImageProvider key) async {
    final tileData = await _getTileData(key.zoom, key.x, key.y);
    if (tileData == null) {
      return instantiateImageCodec(
        Uint8List(0),
      ); // Devolver un tile vacío en caso de error
    }
    return instantiateImageCodec(tileData);
  }

  Future<Uint8List?> _getTileData(int zoom, int x, int y) async {
    final result = await database.rawQuery(
      'SELECT tile_data FROM tiles WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?',
      [zoom, x, y],
    );
    return result.isNotEmpty ? result.first['tile_data'] as Uint8List : null;
  }
}
