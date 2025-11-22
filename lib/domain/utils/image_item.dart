import 'dart:io';

class ImageItem {
  final File originalFile;
  File? miniFile;
  final double? latitude;
  final double? longitude;

  ImageItem(
      {required this.originalFile,
      this.miniFile,
      this.latitude,
      this.longitude});
}
