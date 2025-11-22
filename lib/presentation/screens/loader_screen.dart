import 'package:flutter/material.dart';
import 'package:geo_album/presentation/components/loading.dart';
import 'package:geo_album/presentation/theme/app_theme.dart';

class LoaderScreen extends StatefulWidget {
  final Future<void> Function()? loadingFunction;
  final Widget destinationWidget;

  const LoaderScreen({
    super.key,
    this.loadingFunction,
    required this.destinationWidget,
  });

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen> {
  @override
  void initState() {
    super.initState();
    _performLoading();
  }

  Future<void> _performLoading() async {
    if (widget.loadingFunction != null) {
      await widget.loadingFunction!();
    } else {
      await Future.delayed(const Duration(seconds: 5));
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.destinationWidget),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: appGradient),
      child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Loading()])),
    );
  }
}
