import 'package:flutter/material.dart';
import 'package:my_camera/constants/colors.dart';
import 'package:my_camera/screens/cameraScreen.dart';
import 'package:my_camera/screens/galleryScreen.dart';
import 'package:my_camera/screens/microworldScreen.dart';
import 'package:my_camera/styles/theme.dart';

import 'TestScreen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  Widget menuButton({BuildContext context, Function onTap, String text, String imagePath}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: buttonGradient
          ),
          width: 170,
          height: 170,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 98,
                  width: 98,
                  child: Image(
                    image: AssetImage(
                      imagePath
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: backgroundGradient
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // menuButton(
            //     context: context,
            //     onTap: (){
            //       Navigator.push(context, MaterialPageRoute(builder: (context)=>TestScreen()));
            //     },
            //     text: "Configuration"
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                menuButton(
                  context: context,
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>CameraScreen(selectedMenuButtonIndex: 0)));
                  },
                  text: "Observation",
                  imagePath: "assets/images/observation.png"
                ),
                menuButton(
                    context: context,
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CameraScreen(selectedMenuButtonIndex: 1)));
                    },
                    text: "Size Distribution",
                    imagePath: "assets/images/sizedist.png"
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                menuButton(
                    context: context,
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>MicroworldScreen()));
                    },
                    text: "Microworld",
                    imagePath: "assets/images/microworld.png"
                ),
                menuButton(
                    context: context,
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>GalleryScreen()));
                    },
                    text: "Gallery",
                    imagePath: "assets/images/gallery.png"
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
