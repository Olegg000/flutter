import 'package:flutter/material.dart';

class SpaceBox extends StatelessWidget {
  final double height;
  const SpaceBox(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

class SpaceBoxW extends StatelessWidget {
  final double width;
  const SpaceBoxW(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
