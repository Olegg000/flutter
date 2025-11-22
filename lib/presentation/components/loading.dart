import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geo_album/presentation/components/space_box.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  static const List<Widget> settingStatuses = <Widget>[
    Text('Загрузка...', style: TextStyle(color: Colors.white)),
    Text('Ожидайте...', style: TextStyle(color: Colors.white)),
    Text('Почти готово...', style: TextStyle(color: Colors.white)),
    Text('Осталось немного...', style: TextStyle(color: Colors.white)),
  ];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (Timer time) {
      setState(() {
        if (_currentIndex < 4) {
          _currentIndex = (_currentIndex + 1);
        } else {
          _currentIndex = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(children: [
        const CircularProgressIndicator(),
        const SpaceBox(12.0),
        settingStatuses[_currentIndex],
      ])),
      backgroundColor: Colors.transparent,
    );
  }
}
