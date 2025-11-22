import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geo_album/domain/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CachedTileProvider extends TileProvider {
  final String tileUrl;
  final Duration maxTileAge;
  final Directory cacheDir;
  final HttpClient httpClient;

  static final tag = "CachedTileProvider";

  CachedTileProvider._({
    required this.tileUrl,
    required this.maxTileAge,
    required this.cacheDir,
    required this.httpClient,
  });

  static Future<CachedTileProvider> create({
    required String tileUrl,
    Duration maxAge = const Duration(days: 30),
  }) async {
    final cacheDir = await _getCacheDirectory();

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    AppLogger.info("Tile cache directory: ${cacheDir.path}", tag: tag);

    return CachedTileProvider._(
      tileUrl: tileUrl,
      maxTileAge: maxAge,
      cacheDir: cacheDir,
      httpClient: HttpClient(),
    );
  }

  @override
  ImageProvider<Object> getImage(
    TileCoordinates coordinates,
    TileLayer options,
  ) {
    final url = getTileUrl(coordinates, options);
    final cacheFile = getCacheFile(coordinates);

    return CachedTileImageProvider._(
      url: url,
      maxTileAge: maxTileAge,
      cacheFile: cacheFile,
      httpClient: httpClient,
    );
  }

  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    String url = options.urlTemplate!
        .replaceAll('{z}', coordinates.z.toString())
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString());

    if (url.contains('{s}')) {
      final servers = ['a', 'b', 'c'];
      final randomServer = servers[DateTime.now().millisecondsSinceEpoch % 3];
      url = url.replaceAll('{s}', randomServer);
    }

    return url;
  }

  static Future<Directory> _getCacheDirectory() async {
    final appSupportDir = await getApplicationSupportDirectory();
    return Directory(p.join(appSupportDir.path, 'map_tiles'));
  }

  File getCacheFile(TileCoordinates coords) {
    final fileName = '${coords.z}_${coords.x}_${coords.y}.png';
    return File(p.join(cacheDir.path, fileName));
  }

  Future<void> clearCache() async {
    try {
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
        AppLogger.info("Cache sucessfully cleaned!", tag: tag);
      }
    } catch (e) {
      AppLogger.error("Failed to clear cache", error: e, tag: tag);
    }
  }

  static Future<void> clearGlobalCache() async {
    try {
      final cacheDir = await _getCacheDirectory();

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }

      AppLogger.info("Cache cleared successfully", tag: tag);
    } catch (e) {
      AppLogger.error("Failed to clear cache", error: e, tag: tag);
    }
  }

  Future<int> getCachedSize() async {
    try {
      int totalSize = 0;
      if (await cacheDir.exists()) {
        final files = cacheDir.listSync(recursive: true);
        for (var file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
      return totalSize;
    } catch (e) {
      AppLogger.error("Failed to calculate tiles", tag: tag);
      return 0;
    }
  }

  void despose() {
    httpClient.close(force: true);
  }
}

class CachedTileImageProvider extends ImageProvider<CachedTileImageProvider> {
  final String url;
  final Duration maxTileAge;
  final File cacheFile;
  final HttpClient httpClient;
  static String tag = "CachedTileImageProvider";

  CachedTileImageProvider._({
    required this.url,
    required this.maxTileAge,
    required this.cacheFile,
    required this.httpClient,
  });

  @override
  Future<CachedTileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedTileImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    CachedTileImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: url,
    );
  }

  Future<Codec> _loadAsync(
    CachedTileImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    try {
      if (await cacheFile.exists()) {
        final stat = await cacheFile.stat();
        final age = DateTime.now().difference(stat.modified);

        if (age < maxTileAge) {
          final bytes = await cacheFile.readAsBytes();
          final buffer = await ImmutableBuffer.fromUint8List(bytes);
          return decode(buffer);
        } else {
          AppLogger.info("Tile age was expected, getting new tile", tag: tag);
        }
      }

      final request = await httpClient.getUrl(Uri.parse(url)).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          AppLogger.error(
            "TimeOut Expection for tile",
            error: TimeoutException,
          );
          throw TimeoutException;
        },
      );

      final response = await request.close().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          AppLogger.error(
            "TimeOut Expection for tile",
            error: TimeoutException,
          );
          throw TimeoutException;
        },
      );

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);

        await cacheFile.writeAsBytes(bytes);

        final buffer = await ImmutableBuffer.fromUint8List(bytes);

        return decode(buffer);
      } else {
        throw HttpException;
      }
    } catch (e) {
      AppLogger.error(
        "Failed to get new cache tile. Trying use old cache for $url",
        tag: tag,
        error: e,
      );

      if (await cacheFile.exists()) {
        AppLogger.warning("Using old cached version of tile $url", tag: tag);
        final bytes = await cacheFile.readAsBytes();
        final buffer = await ImmutableBuffer.fromUint8List(bytes);
        return decode(buffer);
      }

      rethrow;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CachedTileImageProvider && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
