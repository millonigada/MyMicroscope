import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_camera/services/videoUtility.dart';

class VideoScreen extends StatefulWidget {
  final XFile videoFile;
  final String videoPath;
  VideoScreen({this.videoFile,this.videoPath});
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {

  VideoPlayerController videoPlayerController;
  ChewieController chewieController;

  Future uploadFile() async {
    var storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child("videos/${widget.videoFile.hashCode}")
        .putFile(File(widget.videoPath));
    String downloadUrl = await snapshot.ref.getDownloadURL();
    VideoUtility.saveVideoToPreferences(downloadUrl);
    await FirebaseFirestore.instance
        .collection("videos")
        .doc('${widget.videoFile.hashCode}')
        .set({"url": downloadUrl, "docId": '${widget.videoFile.hashCode}'});
    debugPrint('Succesfully added video.');
  }

  // Future uploadFile() async {
  //   VideoUtility.saveVideoToPreferences(VideoUtility.base64String(File(widget.videoPath).readAsBytesSync()));
  // }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
    chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: false,
      autoInitialize: true,
    );

    Widget chewieWidget = Chewie(
      controller: chewieController,
    );


    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: (){
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
                  child: chewieWidget
              ),
            ],
          ),
        ),
      ),
    );
  }

}
