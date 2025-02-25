import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoadingScreen extends StatefulWidget {
  const CustomLoadingScreen({Key? key}) : super(key: key);

  @override
  _CustomLoadingScreenState createState() => _CustomLoadingScreenState();
}

class _CustomLoadingScreenState extends State<CustomLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && !_isDisposed) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!_isDisposed) {
          _controller.reset();
          _controller.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/animation_world_spin.json',
          width: 300,
          height: 300,
          fit: BoxFit.fill,
          controller: _controller,
          onLoaded: (composition) {
            if (!_isDisposed) {
              _controller
                ..duration = composition.duration
                ..forward();
            }
          },
        ),
      ),
    );
  }
}
