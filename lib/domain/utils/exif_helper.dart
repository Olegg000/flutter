import 'dart:io';

import 'package:exif/exif.dart';

Future<Map<String, double?>> parseExifInBackground(File imageFile) async {
  final fileBytes = await imageFile.readAsBytes();
  final data = await readExifFromBytes(fileBytes);

  if (data.isEmpty) {
    return {'latitude': null, 'longitude': null};
  }

  final gpsLatitude = data['GPS GPSLatitude'];
  final gpsLongitude = data['GPS GPSLongitude'];
  final gpsLatitudeRef = data['GPS GPSLatitudeRef'];
  final gpsLongitudeRef = data['GPS GPSLongitudeRef'];

  if (gpsLongitudeRef != null &&
      gpsLatitudeRef != null &&
      gpsLongitude != null &&
      gpsLatitude != null) {
    final List<dynamic> latitudeDms = gpsLatitude.values.toList();
    final List<dynamic> longitudeDms = gpsLongitude.values.toList();
    final double latitude = convertDMSToDecimal(latitudeDms);
    final double longitude = convertDMSToDecimal(longitudeDms);

    final double finalLatitude =
        gpsLatitudeRef.values.toString() == 'S' ? -latitude : latitude;
    final double finalLongitude =
        gpsLongitudeRef.values.toString() == 'W' ? -longitude : longitude;

    return {'latitude': finalLatitude, 'longitude': finalLongitude};
  }

  return {'latitude': null, 'longitude': null};
}

double convertDMSToDecimal(List<dynamic> dms) {
  if (dms.length != 3) {
    throw Exception("Invalid DMS format");
  }

  final double degrees =
      dms[0].numerator.toDouble() / dms[0].denominator.toDouble();
  final double minutes =
      dms[1].numerator.toDouble() / dms[1].denominator.toDouble();
  final double seconds =
      dms[2].numerator.toDouble() / dms[2].denominator.toDouble();
  return degrees + (minutes / 60) + (seconds / 3600);
}
