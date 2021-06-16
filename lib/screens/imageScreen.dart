import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_camera/services/imageUtility.dart';

class ImageScreen extends StatefulWidget {
  final XFile imgFile;
  final String imgPath;
  ImageScreen({this.imgFile,this.imgPath});
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {

  // Future uploadFile() async {
  //   var storage = FirebaseStorage.instance;
  //   TaskSnapshot snapshot = await storage
  //       .ref()
  //       .child("images/${widget.imgFile.hashCode}")
  //       .putFile(File(widget.imgPath));
  //   String downloadUrl = await snapshot.ref.getDownloadURL();
  //   debugPrint('douwload url: $downloadUrl');
  //   await FirebaseFirestore.instance
  //       .collection("images")
  //       .doc('${widget.imgFile.hashCode}')
  //       .set({"url": downloadUrl, "docId": '${widget.imgFile.hashCode}'});
  // }

  Future uploadFile() async {
    ImageUtility.saveImageToPreferences(ImageUtility.base64String(File(widget.imgPath).readAsBytesSync()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: (){
                    // imgList.add(File(widget.imgPath));
                    uploadFile();
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.save_outlined,
                    color: Colors.lightGreenAccent,
                  ),
                  label: Text('SAVE', style: TextStyle(color: Colors.white),),
                ),
                TextButton.icon(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red,
                  ),
                  label: Text('DISCARD', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            Container(
              child: Image.file(File(widget.imgPath))
            ),
          ],
        ),
      ),
    );
  }

}
