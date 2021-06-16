import 'package:flutter/material.dart';
import 'cameraScreen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  loadScreen(BuildContext context) async {
    Timer(Duration(seconds: 2), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CameraScreen())));
  }

  @override
  void initState() {
    super.initState();
    loadScreen(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CameraScreen())),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue,
                Colors.blueAccent
              ]
            )
          ),
          child: Center(
            child: Image(
              image: AssetImage("assets/images/micro.png"),
            )
          ),
        ),
      ),
    );
  }
}
