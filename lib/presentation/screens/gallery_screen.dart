import 'package:flutter/material.dart';
import 'package:geo_album/data/providers/gallery_provider.dart';
import 'package:geo_album/domain/utils/image_item.dart';
import 'package:geo_album/presentation/theme/app_theme.dart';
import 'package:provider/provider.dart';

class GalleryScreen extends StatelessWidget {
  final VoidCallback onNavigateToMap;
  final Function(ImageItem) onNavigateToImage;

  const GalleryScreen({
    super.key,
    required this.onNavigateToMap,
    required this.onNavigateToImage,
  });

  @override
  Widget build(BuildContext context) {
    final galleryProvider = Provider.of<GalleryProvider>(context);

    return Container(
      decoration: const BoxDecoration(gradient: appGradient),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              SizedBox(width: 40),
              Spacer(),
              Text("Ваша галлерея", style: TextStyle(color: Colors.white)),
              Spacer(),
              SizedBox(width: 40),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: galleryProvider.isLoading && galleryProvider.images.isEmpty
            ? Center(
                child: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
                backgroundColor: Colors.transparent,
              ))
            : galleryProvider.images.isEmpty
                ? Center(child: Text("Фотографий не найдено"))
                : Center(
                    child: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: galleryProvider.images.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = galleryProvider.images[index];
                          return GestureDetector(
                            onTap: () {
                              if (item.originalFile.existsSync()) {
                                onNavigateToImage(item);
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: item.miniFile != null &&
                                      item.miniFile!.existsSync()
                                  ? Image.file(
                                      item.miniFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
