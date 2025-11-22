import 'package:flutter/material.dart';
import 'package:geo_album/data/providers/gallery_provider.dart';
import 'package:geo_album/domain/models/status.dart';
import 'package:geo_album/presentation/components/bottom_bar.dart';
import 'package:geo_album/presentation/screens/loader_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher_aurora/url_launcher_aurora.dart';

void main() {
  UrlLauncherAurora.registerWith();
  runApp(
    ChangeNotifierProvider(
      create: (context) => GalleryProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const LoaderScreen(
        destinationWidget: AppBottomNavigationBar(
          initialStatus: Status.gallery,
        ),
      ),
    );
  }
}
