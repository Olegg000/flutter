import 'package:flutter/material.dart';
import 'package:geo_album/data/providers/cached_tile_provider.dart';
import 'package:geo_album/data/providers/gallery_provider.dart';
import 'package:geo_album/presentation/components/space_box.dart';
import 'package:geo_album/presentation/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getMapUrl(String mapType) {
  switch (mapType) {
    case 'O':
      return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    case 'S':
      return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    case 'T':
      return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Terrain_Base/MapServer/tile/{z}/{y}/{x}';
    default:
      return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static Future<String> getMapTypeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('map_type') ?? 'O';
  }

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedMapType = 'O';
  bool isLoading = false;
  bool _isInit = false;

  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedMapType = _prefs.getString('map_type') ?? 'O';
      _isInit = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
        builder: (context, galleryProvider, child) {
      if (!_isInit) {
        return Container(
            decoration: const BoxDecoration(gradient: appGradient),
            child: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
              backgroundColor: Colors.transparent,
            ));
      }
      final screenWidth = MediaQuery.of(context).size.width;
      final isTablet = screenWidth > 600;
      final padding = isTablet ? 24.0 : 16.0;
      final fontSize = isTablet ? 20.0 : 18.0;
      final buttonHeight = isTablet ? 56.0 : 48.0;

      final textToShowMapOpenStrit = "Обычная карта";
      final textToShowMapOpenStritSputnik = "Спутниковый вид";
      final textToShowMapOpenStritTerrain = "Рельеф";

      return Container(
        decoration: const BoxDecoration(gradient: appGradient),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Настройки',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('О приложении'),
                      content: Text(
                        'Geo Album\n\n'
                        'Приложение для просмотра фотографий с геометками\n\n'
                        'Всего фото: ${galleryProvider.images.length}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Хорошо'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            backgroundColor: Colors.transparent,
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: appGradient),
            child: ListView(
              padding: EdgeInsets.all(padding),
              children: [
                Card(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Тип карты',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SpaceBox(8),
                        RadioListTile<String>(
                          title: Text(textToShowMapOpenStrit),
                          value: 'O',
                          groupValue: selectedMapType,
                          onChanged: (value) async {
                            if (value == null) return;
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            await Provider.of<GalleryProvider>(context,
                                    listen: false)
                                .updateMapType(value);
                            setState(() {
                              selectedMapType = value;
                            });
                            await _prefs.setString('map_type', value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Карта изменена на $textToShowMapOpenStrit',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(textToShowMapOpenStritSputnik),
                          value: 'S',
                          groupValue: selectedMapType,
                          onChanged: (value) async {
                            if (value == null) return;
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            await Provider.of<GalleryProvider>(context,
                                    listen: false)
                                .updateMapType(value);
                            setState(() {
                              selectedMapType = value;
                            });
                            await _prefs.setString('map_type', value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Карта изменена на $textToShowMapOpenStritSputnik',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(textToShowMapOpenStritTerrain),
                          value: 'T',
                          groupValue: selectedMapType,
                          onChanged: (value) async {
                            if (value == null) return;
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            await Provider.of<GalleryProvider>(context,
                                    listen: false)
                                .updateMapType(value);
                            setState(() {
                              selectedMapType = value;
                            });
                            await _prefs.setString('map_type', value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Карта изменена на $textToShowMapOpenStritTerrain',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        SpaceBox(24),
                        Text(
                          'Управление кэшем',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SpaceBox(16),
                        ElevatedButton.icon(
                          icon: Icon(Icons.map_outlined),
                          label: Text('Очистить кэш карты'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: Size(double.infinity, buttonHeight),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();

                                  setState(() {
                                    isLoading = true;
                                  });

                                  await CachedTileProvider.clearGlobalCache();

                                  setState(() {
                                    isLoading = false;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Кэш карты очищен')),
                                  );
                                },
                        ),
                        SpaceBox(12),
                        ElevatedButton.icon(
                          icon: Icon(Icons.image_outlined),
                          label: Text('Очистить миниатюрые фото'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              182,
                              136,
                              133,
                            ),
                            minimumSize: Size(double.infinity, buttonHeight),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();

                                  setState(() {
                                    isLoading = true;
                                  });

                                  await galleryProvider.clearMiniatures();

                                  setState(() {
                                    isLoading = false;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Миниатюрные фото очищены'),
                                    ),
                                  );
                                },
                        ),
                        if (isLoading == true)
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Center(
                                child: Scaffold(
                              body: Center(
                                child: CircularProgressIndicator(),
                              ),
                              backgroundColor: Colors.transparent,
                            )),
                          ),
                        SpaceBox(24),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Статистика',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SpaceBox(16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Всего фото',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            Text(
                              '${galleryProvider.images.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SpaceBox(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'С геометками',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            Text(
                              '${galleryProvider.images.where((img) => img.latitude != null).length}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SpaceBox(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Без геометок',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            Text(
                              '${galleryProvider.images.length - galleryProvider.images.where((img) => img.latitude != null).length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SpaceBox(16),
                        Text(
                          'Адаптивность',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        SpaceBox(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Тип устройства'),
                            Text(
                              isTablet ? 'Планшет' : 'Телефон',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SpaceBox(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ширина экрана'),
                            Text(
                              '${screenWidth.toInt()} px',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SpaceBox(isTablet ? 48 : 24),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      );
    });
  }
}
