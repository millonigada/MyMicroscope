import 'package:flutter/material.dart';
import 'package:my_camera/constants/colors.dart';
import 'package:my_camera/screens/cameraScreen.dart';
import 'package:my_camera/screens/galleryScreen.dart';

import 'TestScreen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  Widget menuButton({BuildContext context, Function onTap, String text}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: whiteColor,
          ),
          width: MediaQuery.of(context).size.width-40,
          height: 70,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: blackColor,
                fontSize: 36,
                fontWeight: FontWeight.w400
              ),
            ),
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: blackColor,
      body: Container(
        margin: EdgeInsets.only(left: 55, right: 55),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            menuButton(
                context: context,
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>TestScreen()));
                },
                text: "Configuration"
            ),
            menuButton(
              context: context,
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CameraScreen(selectedMenuButtonIndex: 0)));
              },
              text: "Observation"
            ),
            menuButton(
                context: context,
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CameraScreen(selectedMenuButtonIndex: 1)));
                },
                text: "Size Distribution"
            ),
            menuButton(
                context: context,
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>GalleryScreen()));
                },
                text: "Microworld"
            )
          ],
        ),
      ),
    );
  }
}
