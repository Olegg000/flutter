import 'package:flutter/material.dart';
import 'package:geo_album/domain/models/status.dart';
import 'package:geo_album/domain/utils/image_item.dart';
import 'package:geo_album/presentation/screens/image_view_screen.dart';
import 'package:geo_album/presentation/screens/settings.dart';
import 'package:geo_album/data/providers/gallery_provider.dart';
import 'package:geo_album/presentation/screens/gallery_screen.dart';
import 'package:geo_album/presentation/screens/map_screen.dart';
import 'package:geo_album/presentation/theme/app_theme.dart';
import 'package:provider/provider.dart';

class AppBottomNavigationBar extends StatefulWidget {
  final Status initialStatus;

  const AppBottomNavigationBar({
    super.key,
    this.initialStatus = Status.loading,
  });

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  int _selectedIndex = 1; // (0 настройки, 1 галерея, 2 карта)
  ImageItem? _selectedImageItem;

  void _goToGallery() {
    setState(() {
      _selectedIndex = 1;
      _selectedImageItem = null;
    });
  }

  void _goToMap() {
    setState(() {
      _selectedIndex = 2;
      _selectedImageItem = null;
    });
  }

  void _viewImage(ImageItem imageItem) {
    setState(() {
      _selectedImageItem = imageItem;
    });
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      final galleryProvider = context.read<GalleryProvider>();
      final imagesWithLocation = galleryProvider.images
          .where((item) => item.latitude != null && item.longitude != null)
          .toList();

      if (imagesWithLocation.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Фотографий c гео-метками не найдено"),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    setState(() {
      _selectedIndex = index;
      _selectedImageItem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final galleryProvider = context.watch<GalleryProvider>();

    final imagesWithLocation = galleryProvider.images
        .where((item) => item.latitude != null && item.longitude != null)
        .toList();

    final List<Widget> pages = <Widget>[
      const SettingsScreen(),
      GalleryScreen(onNavigateToMap: _goToMap, onNavigateToImage: _viewImage),
      MapScreen(
        images: imagesWithLocation,
        onNavigateToGallery: _goToGallery,
        centerOnItem: null,
        onNavigateToImage: _viewImage,
      ),
    ];

    final Widget currentPage = _selectedImageItem != null
        ? ImageViewScreen(
            imageItem: _selectedImageItem!,
            onNavigateToImage: _viewImage,
          )
        : pages[_selectedIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: appGradient),
        child: Center(child: currentPage),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Настройки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album_outlined),
            label: 'Галерея',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Карта',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amber[700],
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
