import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/LOST.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _controller.addListener(_onVideoFinishedPlaying);
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVideoFinishedPlaying() {
    Timer(const Duration(seconds: 2), () {
      // Navigate to the homepage
      Navigator.of(context).pushReplacementNamed('/homepage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color here
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
