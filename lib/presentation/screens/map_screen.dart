import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geo_album/data/providers/cached_tile_provider.dart';
import 'package:geo_album/data/providers/gallery_provider.dart';
import 'package:geo_album/domain/utils/image_item.dart';
import 'package:geo_album/presentation/components/space_box.dart';
import 'package:geo_album/domain/utils/logger.dart';
import 'package:geo_album/presentation/screens/settings.dart';
import 'package:geo_album/presentation/theme/app_theme.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  final VoidCallback onNavigateToGallery;
  final Function(ImageItem) onNavigateToImage;
  final ImageItem? centerOnItem;

  const MapScreen({
    super.key,
    required this.images,
    required this.onNavigateToGallery,
    required this.onNavigateToImage,
    this.centerOnItem,
  });

  final List<ImageItem> images;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  CachedTileProvider? _cachedTileProvider;
  bool _isInitialized = false;
  bool _isMapReady = false;
  String? _errorMessage;
  static String tag = "MapScreen";
  String? _currentMapType;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    setupMapListners();
    _initTileProvider();
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.centerOnItem != oldWidget.centerOnItem &&
        widget.centerOnItem != null) {
      if (_isMapReady) {
        final provider = Provider.of<GalleryProvider>(context, listen: false);

        _mapController.move(
          latlong.LatLng(
            widget.centerOnItem!.latitude!,
            widget.centerOnItem!.longitude!,
          ),
          provider.mapZoom,
        );
      }
    }
  }

  void setupMapListners() {
    _mapController.mapEventStream.listen((MapEvent event) {
      if (!mounted) return;

      setState(() {});

      if (event is MapEventRotateEnd || event is MapEventMoveEnd) {
        final provider = Provider.of<GalleryProvider>(context, listen: false);
        provider.saveMapState(
          zoom: _mapController.camera.zoom,
          rotation: _mapController.camera.rotation,
        );
      }

      final galleryProvider =
          Provider.of<GalleryProvider>(context, listen: false);
      final newMapType = galleryProvider.mapType;

      if (_currentMapType != newMapType) {
        _currentMapType = newMapType;
        _recreateTileProvider(newMapType);
      }
    });
  }

  Future<void> _recreateTileProvider(String mapType) async {
    try {
      final tileUrl = getMapUrl(mapType);
      final provider = await CachedTileProvider.create(tileUrl: tileUrl);

      _cachedTileProvider?.despose();

      if (mounted) {
        setState(() {
          _cachedTileProvider = provider;
          _isInitialized = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      AppLogger.error("Failed", error: e, tag: tag);
      if (mounted) {
        setState(() {
          _errorMessage = "Не удалось загрузить карту";
          _isInitialized = false;
        });
      }
    }
  }

  Future<void> _initTileProvider() async {
    try {
      final galleryProvider =
          Provider.of<GalleryProvider>(context, listen: false);
      final tileUrl = getMapUrl(galleryProvider.mapType);
      final provider = await CachedTileProvider.create(tileUrl: tileUrl);

      if (mounted) {
        setState(() {
          _cachedTileProvider = provider;
          _isInitialized = true;
        });
      }
    } catch (e) {
      AppLogger.error("something wrong happend", error: e);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _cachedTileProvider?.despose();
    super.dispose();
  }

  List<Marker> _buildMarkers() {
    return widget.images.map((imageItem) {
      return Marker(
        point: latlong.LatLng(imageItem.latitude!, imageItem.longitude!),
        width: 80.0,
        height: 80.0,
        child: GestureDetector(
          onTap: () {
            widget.onNavigateToImage(imageItem);
          },
          child: CircleAvatar(
            radius: 40.0,
            backgroundColor: Colors.blueAccent,
            child: ClipOval(
              child: (imageItem.miniFile != null &&
                      imageItem.miniFile!.existsSync())
                  ? Image.file(
                      imageItem.miniFile!,
                      fit: BoxFit.cover,
                      cacheWidth: 75,
                      cacheHeight: 75,
                      gaplessPlayback: true,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        decoration: const BoxDecoration(gradient: appGradient),
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Center(
            child: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      );
    }
    final galleryProvider = Provider.of<GalleryProvider>(context);
    final mapType = galleryProvider.mapType;
    final tileUrl = getMapUrl(mapType);

    if (_errorMessage != null) {
      return Container(
        decoration: const BoxDecoration(gradient: appGradient),
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(_errorMessage!, style: TextStyle(color: Colors.white)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _isInitialized = false;
                    });
                    _initTileProvider();
                  },
                  child: Text("Повторить"),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      );
    }

    final markers = _buildMarkers();

    latlong.LatLng inicialCenter;
    double initialZoom = galleryProvider.mapZoom;

    inicialCenter = latlong.LatLng(54.314192, 48.403132);

    return Container(
      decoration: const BoxDecoration(gradient: appGradient),
      child: Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                maxZoom: 18.0,
                minZoom: 3.0,
                initialCenter: inicialCenter,
                initialZoom: initialZoom,
                onMapReady: () {
                  if (!mounted) return;

                  setState(() {
                    _isMapReady = true;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: 'com.example.geo_album',
                  tileProvider: _cachedTileProvider,
                  maxNativeZoom: 19,
                  maxZoom: 18,
                  errorTileCallback: (tile, error, stackTrace) {
                    AppLogger.warning(
                      "File load error: ${tile.coordinates}",
                      tag: tag,
                    );
                  },
                ),
                MarkerLayer(markers: markers),
              ],
            ),
            if (_isMapReady)
              Positioned(
                right: 16.0,
                bottom: 64.0,
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add),
                      color: _mapController.camera.zoom >= 18.0
                          ? Colors.grey
                          : Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: _mapController.camera.zoom >= 18.0
                            ? Colors.grey[700]
                            : Colors.blueAccent,
                      ),
                      onPressed: _mapController.camera.zoom >= 18.0
                          ? () {}
                          : () {
                              _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom + 1,
                              );
                            },
                    ),
                    SizedBox(height: 8),
                    IconButton(
                      icon: Icon(Icons.remove),
                      color: _mapController.camera.zoom <= 3.0
                          ? Colors.grey
                          : Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: _mapController.camera.zoom <= 3.0
                            ? Colors.grey[700]
                            : Colors.blueAccent,
                      ),
                      onPressed: _mapController.camera.zoom <= 3.0
                          ? () {}
                          : () {
                              _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom - 1,
                              );
                            },
                    ),
                    SpaceBox(16),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Зум: ${_mapController.camera.zoom.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SpaceBox(32),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          SpaceBoxW(40),
          Spacer(),
          Text("Карта фотографий", style: TextStyle(color: Colors.white)),
          Spacer(),
          SpaceBoxW(40),
        ],
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
    );
  }
}
