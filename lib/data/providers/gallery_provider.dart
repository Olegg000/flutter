import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geo_album/domain/utils/exif_helper.dart';
import 'package:geo_album/domain/utils/image_item.dart';
import 'package:geo_album/domain/utils/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as im;
import 'package:shared_preferences/shared_preferences.dart';

class GalleryProvider with ChangeNotifier {
  bool _isLoading = true;
  List<ImageItem> _images = [];
  Directory? _miniFilesDir;

  double _mapZoom = 9.0;
  double _mapRotation = 0;

  double get mapZoom => _mapZoom;
  double get mapRotation => _mapRotation;

  bool get isLoading => _isLoading;
  List<ImageItem> get images => _images;

  static String tag = "GalleryProvider";

  String _mapType = 'O';

  String get mapType => _mapType;

  GalleryProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final tempDir = await getTemporaryDirectory();
      _miniFilesDir = Directory('$tempDir/miniPictures');
      if (!await _miniFilesDir!.exists()) {
        await _miniFilesDir!.create(recursive: true);
      }
      await _loadimages();
    } catch (e) {
      AppLogger.error("Error with init gallery", error: e, tag: tag);
    }
  }

  Future<void> saveMapState({
    required double zoom,
    required double rotation,
  }) async {
    if (_mapZoom != zoom || _mapRotation != rotation) {
      _mapRotation = rotation;
      _mapZoom = zoom;
    }
  }

  Future<void> _loadimages() async {
    _isLoading = true;
    notifyListeners();

    List<ImageItem> loadedImages = [];

    try {
      final dirictories = await getExternalStorageDirectories(
        type: StorageDirectory.pictures,
      );

      if (dirictories != null && dirictories.isNotEmpty) {
        final picturesDirictory = dirictories[0];
        if (await picturesDirictory.exists()) {
          final files = picturesDirictory.listSync();
          AppLogger.info("Find ${files.length} files", tag: tag);

          for (final file in files) {
            final originalPath = file.path;
            final path = originalPath.toLowerCase();
            if (path.endsWith(".jpg") ||
                path.endsWith(".jpeg") ||
                path.endsWith(".png")) {
              final coords = await _readExif(File(originalPath));
              loadedImages.add(
                ImageItem(
                  originalFile: File(originalPath),
                  latitude: coords['latitude'],
                  longitude: coords['longitude'],
                ),
              );
            }
          }

          AppLogger.info("Loaded ${loadedImages.length} images", tag: tag);

          for (var item in loadedImages) {
            _getOrCreateMiniImageItem(item);
          }
        }
      }
    } catch (e) {
      AppLogger.error("Error wia load images", error: e, tag: tag);
    }

    _images = loadedImages;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearMiniatures() async {
    try {
      if (_miniFilesDir != null && await _miniFilesDir!.exists()) {
        await _miniFilesDir!.delete(recursive: true);
        _miniFilesDir =
            Directory('${(await getTemporaryDirectory()).path}/miniPictures');
        await _miniFilesDir!.create(recursive: true);

        for (final img in _images) {
          img.miniFile = null;
          _getOrCreateMiniImageItem(img);
        }

        notifyListeners();
      }
    } catch (e) {
      AppLogger.error("Failed to clear miniatures", error: e, tag: tag);
    }
  }

  Future<void> _getOrCreateMiniImageItem(ImageItem item) async {
    final originalPath = item.originalFile.path;
    final miniName = '${originalPath.hashCode}.jpg';
    final miniFile = File(p.join(_miniFilesDir!.path, miniName));

    item.miniFile = miniFile;

    if (await miniFile.exists()) {
      return;
    }

    try {
      final imageBytes = await item.originalFile.readAsBytes();
      final miniBytes = await compute(_resizeImage, imageBytes);
      if (miniBytes != null) {
        await miniFile.writeAsBytes(miniBytes);
        notifyListeners();
        AppLogger.info("Create image $miniName", tag: tag);
      }
    } catch (e) {
      AppLogger.error('Failed to create or get mini-image + $e', tag: tag);
    }
  }

  Future<Map<String, double?>> _readExif(File imageFile) async {
    try {
      final Map<String, double?> coords = await compute(
        parseExifInBackground,
        imageFile,
      );
      return coords;
    } catch (e) {
      AppLogger.error("Error reading ${imageFile.path}", error: e, tag: tag);
    }
    return {'latitude': null, 'longitude': null};
  }

  void refreshImageItem(ImageItem oldItem, File newFile) {
    final index = _images.indexOf(oldItem);
    if (index != -1) {
      ImageItem newItem = ImageItem(
        originalFile: newFile,
        latitude: oldItem.latitude,
        longitude: oldItem.longitude,
      );

      _images[index] = newItem;

      _getOrCreateMiniImageItem(_images[index]);

      notifyListeners();
    }
  }

  Future<void> updateMapType(String newMapType) async {
    _mapType = newMapType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('map_type', newMapType);
    notifyListeners(); // Уведомляем всех слушателей об изменении
  }
}

Uint8List? _resizeImage(Uint8List imageBytes) {
  try {
    final image = im.decodeImage(imageBytes);
    if (image != null) {
      final mini = im.copyResize(image, width: 200);
      return Uint8List.fromList(im.encodeJpg(mini, quality: 85));
    }
  } catch (e) {
    AppLogger.error(
      "Failed to resize image",
      error: e,
      tag: GalleryProvider.tag,
    );
  }
  return null;
}
