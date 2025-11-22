import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geo_album/data/providers/gallery_provider.dart';
import 'package:geo_album/presentation/theme/app_theme.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_cropper_aurora/image_cropper_aurora.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path/path.dart' as p;
import 'package:geo_album/domain/utils/image_item.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageViewScreen extends StatefulWidget {
  final ImageItem imageItem;
  final Function(ImageItem) onNavigateToImage;
  static String tag = "ImageViewScreen";

  const ImageViewScreen({
    super.key,
    required this.imageItem,
    required this.onNavigateToImage,
  });

  @override
  State<StatefulWidget> createState() => ImageViewScreenState();
}

class ImageViewScreenState extends State<ImageViewScreen> {
  void _renamePhoto() async {
    TextEditingController nameController = TextEditingController();
    String currentName = p.basenameWithoutExtension(
      widget.imageItem.originalFile.path,
    );
    String extension = p.extension(widget.imageItem.originalFile.path);
    nameController.text = currentName;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          'Переименовать фото',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Введите новое имя',
            hintStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('Отмена', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                await _performRename(nameController.text, extension);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _performRename(String newName, String extension) async {
    try {
      final File originalFile = widget.imageItem.originalFile;
      final String directory = p.dirname(originalFile.path);
      final String newPath = p.join(directory, '$newName$extension');

      final File newFile = File(newPath);
      if (await newFile.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Файл с таким именем уже существует')),
        );
        return;
      }

      final File renamedFile = await originalFile.rename(newPath);

      final provider = Provider.of<GalleryProvider>(context, listen: false);
      provider.refreshImageItem(widget.imageItem, renamedFile);

      if (!mounted) return;

      widget.onNavigateToImage(
        ImageItem(
          originalFile: renamedFile,
          latitude: widget.imageItem.latitude,
          longitude: widget.imageItem.longitude,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Файл успешно переименован')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при переименовании файла: $e')),
      );
    }
  }

  Future<void> _resizeImage() async {
    try {
      final String filePath = widget.imageItem.originalFile.path;

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        uiSettings: [
          AuroraUiSettings(
            context: context,
            hasRightRotation: true,
            hasLeftRotation: true,
            gridColor: Colors.black,
            scrimColor: Colors.black,
            gridInnerColor: Colors.red,
            gridCornerColor: Colors.amber,
          ),
        ],
      );

      if (croppedFile != null) {
        File croppedImageFile = File(croppedFile.path);

        final provider = Provider.of<GalleryProvider>(context, listen: false);

        final originalDir = p.dirname(widget.imageItem.originalFile.path);
        final originalName = p.basenameWithoutExtension(
          widget.imageItem.originalFile.path,
        );
        final extension = p.extension(widget.imageItem.originalFile.path);
        final String newPath = p.join(
          originalDir,
          '${originalName}_resized$extension',
        );

        final bytes = await croppedImageFile.readAsBytes();
        final newFile = File(newPath);
        await newFile.writeAsBytes(bytes);

        provider.refreshImageItem(widget.imageItem, newFile);

        if (!mounted) return;

        widget.onNavigateToImage(
          ImageItem(
            originalFile: newFile,
            latitude: widget.imageItem.latitude,
            longitude: widget.imageItem.longitude,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Размер изображения успешно изменен')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при изменении размера изображения: $e')),
      );
    }
  }

  void _openUri() async {
    final filePath = widget.imageItem.originalFile.path;
    final uri = Uri.file(filePath);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось открыть файл')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при открытии файла: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: appGradient),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.open_in_browser, color: Colors.white),
                onPressed: _openUri,
              ),
              IconButton(
                icon: Icon(
                  Icons.image_aspect_ratio_outlined,
                  color: Colors.white,
                ),
                onPressed: _resizeImage,
              ),
              Expanded(
                child: Text(
                  p.basename(widget.imageItem.originalFile.path),
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: _renamePhoto,
              ),
            ],
          ),
          centerTitle: true,
          shape: Border(
            bottom: BorderSide(color: Colors.transparent, width: 1.0),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: PhotoView(
            imageProvider: FileImage(widget.imageItem.originalFile),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.5,
            maxScale: PhotoViewComputedScale.contained * 4.0,
            heroAttributes: PhotoViewHeroAttributes(
              tag: widget.imageItem.originalFile.path,
            ),
            backgroundDecoration: BoxDecoration(gradient: appGradient),
          ),
        ),
      ),
    );
  }
}
