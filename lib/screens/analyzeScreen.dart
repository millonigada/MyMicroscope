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
import 'package:my_camera/screens/chatScreen.dart';
import 'package:my_camera/services/imageUtility.dart';
import 'package:my_camera/styles/theme.dart';

class AnalyzeScreen extends StatefulWidget {
  final XFile imgFile;
  final String imgPath;
  AnalyzeScreen({this.imgFile,this.imgPath});
  @override
  _AnalyzeScreenState createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {

  Future uploadFile() async {
    ImageUtility.saveImageToPreferences(ImageUtility.base64String(File(widget.imgPath).readAsBytesSync()));
  }

  showSavedToGalleryDialog(BuildContext context){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: alertDialogBackgroundColor,
            content: Container(
              height: 278,
              width: 278,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: alertDialogBackgroundColor
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset(
                    "assets/icons/SavedToGallery",
                    height: 176,
                    width: 176,
                  ),
                  Text(
                    "Saved to gallery",
                    style: TextStyle(
                      color: whiteColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 24
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
    Timer(Duration(seconds: 2), (){
      Navigator.pop(context);
      startAnalyzing(context);
    });
  }

  startAnalyzing(BuildContext context){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: alertDialogBackgroundColor,
            content: Container(
              height: 278,
              width: 278,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: alertDialogBackgroundColor
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 176,
                      width: 176,
                      child: CircularProgressIndicator()
                  ),
                  Text(
                    "Analysing",
                    style: TextStyle(
                        color: whiteColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 24
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
    Timer(Duration(seconds: 2), (){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(imgFile: widget.imgFile, imgPath: widget.imgPath,)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
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
                ]
              ),
            ),
            GestureDetector(
              onTap: (){
                showDialog(
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        backgroundColor: alertDialogBackgroundColor.withOpacity(0.88),
                        content: Container(
                          height: 177,
                          width: 319,
                          decoration: BoxDecoration(
                            color: alertDialogBackgroundColor.withOpacity(0.88),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                              "Discard this photo?",
                                style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 24
                                ),
                              ),
                              SizedBox(height: 17),
                              Text(
                                "If you go back now, you will lose this image",
                                softWrap: true,
                                style: TextStyle(
                                  color: alertDialogWarningTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400
                                ),
                              ),
                              SizedBox(height: 22),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.pop(context);
                                      startAnalyzing(context);
                                    },
                                    child: Container(
                                      height: 33,
                                      width: 132,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: whiteColor, width: 1),
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Center(
                                        child: Text(
                                            "Discard",
                                          style: TextStyle(
                                            color: redColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      uploadFile();
                                      showSavedToGalleryDialog(context);
                                    },
                                    child: Container(
                                      height: 33,
                                      width: 132,
                                      decoration: BoxDecoration(
                                          color: whiteColor,
                                        borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Save to gallery",
                                          style: TextStyle(
                                              color: blackColor,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 18
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 99,
                decoration: BoxDecoration(
                  gradient: buttonGradient
                ),
                child: Center(
                  child: Text(
                    "Analyze",
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
