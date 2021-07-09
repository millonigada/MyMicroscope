import 'package:flutter/material.dart';
import 'package:my_camera/constants/colors.dart';
import 'cameraScreen.dart';
import 'dart:async';
import 'menuScreen.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  loadScreen(BuildContext context) async {
    Timer(Duration(seconds: 2), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MenuScreen())));
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
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MenuScreen())),
        child: Container(
          decoration: BoxDecoration(
            color: whiteColor
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     Colors.blue,
            //     Colors.blueAccent
            //   ]
            // )
          ),
          child: Center(
            child: Image(
              image: AssetImage("assets/images/SplashScreen.png"),
            )
          ),
        ),
      ),
    );
  }
}
