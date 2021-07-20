import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_camera/constants/colors.dart';
import 'package:my_camera/services/imageUtility.dart';
import 'package:my_camera/styles/theme.dart';

class ChatScreen extends StatefulWidget {
  final XFile imgFile;
  final String imgPath;
  ChatScreen({this.imgFile,this.imgPath});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
                child: Image.file(File(widget.imgPath))
            ),
            Positioned(
              top: 75,
              left: 25,
              child: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: SvgPicture.asset(
                  "assets/icons/Back.svg",
                  width: 12,
                  height: 24,
                  color: whiteColor,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 93,
              child: Image(
                image: AssetImage(
                  "assets/images/emoGirlLargeNormal.png"
                ),
              ),
            ),
            Positioned(
              right: 90,
              bottom: 345,
              child: SvgPicture.asset(
                "assets/images/ChatBubble.svg"
              )
            ),
            Positioned(
                right: 113,
                bottom: 434,
                child: Text("CORRECT ANSWER!", softWrap: true, style: TextStyle(
                  color: blackColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w400
                ),)
            ),
            Positioned(
                bottom: 33,
                child: Container(
                  height: 53,
                  width: 352,
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                      )
                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

}
