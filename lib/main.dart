import 'package:flutter/material.dart';
import 'package:my_camera/constants/keys.dart';
import 'package:my_camera/screens/cameraScreen.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_camera/screens/splashScreen.dart';
import 'package:my_camera/styles/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //cameras = await availableCameras();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  print("Contains key: ${prefs.containsKey(cameraKey)}");
  if(!prefs.containsKey(cameraKey)){
    print("called inside if");
    prefs.setInt(cameraKey, 0);
    print("Pref val: ${prefs.getInt(cameraKey)}");
  } else {
    print("Pref val: ${prefs.getInt(cameraKey)}");
  }
  runApp(CameraApp());
}

class CameraApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Camera',
      theme: mainTheme,
      home: SplashScreen(),
    );
  }
}
