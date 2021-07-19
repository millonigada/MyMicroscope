import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:my_camera/constants/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:my_camera/services/imageUtility.dart';
import 'package:my_camera/services/videoUtility.dart';

class SingleImage extends StatefulWidget {
  
  // final String url;
  // final String docId;
  final Image image;
  final String base64string;
  SingleImage({this.image, this.base64string});

  @override
  _SingleImageState createState() => _SingleImageState();
}

class _SingleImageState extends State<SingleImage> {

  TextEditingController _textEditingController = TextEditingController();
  List<Map> tempMap = [
    {
      "text": "right",
      "image": "assets/images/emoGirlExcited.jpeg",
      "reply": "Yay! That's correct!",
    },
    {
      "text": "somewhat right",
      "image": "assets/images/emoGirlHappy.jpeg",
      "reply": "You're close, the correct answer is blah blah",
    },
    {
      "text": "somewhat wrong",
      "image": "assets/images/emoGirlSad.jpeg",
      "reply": "Not Quite, you should have said blah blah",
    },
    {
      "text": "wrong",
      "image": "assets/images/emoGirlCrying.jpeg",
      "reply": "No! You dont seem to have grasped this concept.",
    }
  ];

  deleteImage(BuildContext context){
    ImageUtility.removeImageFromPreferences(widget.base64string);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
      return GalleryScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black87,
      body: ListView(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Divider(height: 20, color: whiteColor,),
          Container(
            margin: EdgeInsets.only(left: 10,right: 10),
            //height: MediaQuery.of(context).size.height/1.5,
            child: widget.image,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              "Some question about the image?",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 18
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(8)
            ),
            height: 40,
            margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            padding: EdgeInsets.only(left: 10, right: 10, top: 5),
            child: Center(
              child: TextField(
                controller: _textEditingController,
                onSubmitted: (text){
                  int index=2;
                  for(int i=0;i<tempMap.length;i++){
                    if(text==tempMap[i]["text"]){
                      index = i;
                      break;
                    }
                  }
                  showDialog(context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          backgroundColor: Colors.grey[850],
                          content: Container(
                            width: 0.8*MediaQuery.of(context).size.width,
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.transparent
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 100,
                                  child: Image(
                                    image: AssetImage(
                                        tempMap[index]["image"]
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Flexible(
                                    child: Text(
                                      tempMap[index]["reply"],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: whiteColor,
                                      ),
                                      softWrap: true,
                                      maxLines: 5,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                  );
                },
                decoration: new InputDecoration.collapsed(
                  hintText: "Your answer",
                ),
                //maxLines: 7
              ),
            ),
          ),
          TextButton.icon(
              onPressed: (){
                deleteImage(context);
              },
              icon: Icon(
                  Icons.delete,
                color: Colors.red,
              ),
              label: Text('Delete', style: TextStyle(color: Colors.white),)
          ),
        ],
      ),
    );;
  }
}

// class SingleVideo extends StatelessWidget {
//
//   final String url;
//   SingleVideo({this.url});
//
//   Widget createChewieWidget(String url){
//     VideoPlayerController videoPlayerController = VideoPlayerController.file(File(url));
//     ChewieController chewieController = ChewieController(
//       videoPlayerController: videoPlayerController,
//       autoPlay: false,
//       looping: false,
//       autoInitialize: true,
//     );
//     return Chewie(controller: chewieController);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black87,
//       body: Hero(
//         tag: url,
//         child: Container(
//           child: createChewieWidget(url),
//         ),
//       ),
//     );;
//   }
// }

class GalleryScreen extends StatefulWidget {

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with TickerProviderStateMixin {

  var storage = FirebaseStorage.instance;
  var imgList;
  var videoList;
  FirebaseFirestore db = FirebaseFirestore.instance;
  TabController _tabController;

  Future<void> getMedia() async {
    debugPrint('This statement is getting printed.');
    //imgList = db.collection("images").get();
    videoList = db.collection("videos").get();
  }

  // Future<String> makeVideoThumbnail(String url) async{
  //   final fileName = await VideoThumbnail.thumbnailFile(
  //       video: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
  //       thumbnailPath: (await getTemporaryDirectory()).path,
  //   imageFormat: ImageFormat.WEBP,
  //   maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
  //   quality: 75,
  //   );
  //   return fileName;
  // }

  @override
  void initState() {
    super.initState();
    //loadImageListFromPreferences();
    getMedia();
    debugPrint(imgList.toString());
    _tabController = new TabController(vsync: this, length: 2);
  }

  deleteVideo(String url, String docId) async {
    var st = await FirebaseStorage.instance.refFromURL(url);
    debugPrint(st.fullPath);
    await st.delete();
    await FirebaseFirestore.instance.collection('videos').doc(docId).delete();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
      return GalleryScreen();
    }));
  }
  
  loadImageListFromPreferences() async {
   List temp = await ImageUtility.getImageListFromPreferences();
   setState(() {
     imgList=temp;
   });
 }

  @override
  Widget build(BuildContext context) {
    Orientation deviceOrientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Gallery'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Photos"),
            Tab(text: "Videos")
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
        Container(
                height: (MediaQuery.of(context).size.height),
                margin: EdgeInsets.all(10),
                child: FutureBuilder(
                  //future: imgList,
                  future: ImageUtility.getImageListFromPreferences(),
                  builder: (context, AsyncSnapshot<List> snapshot){
                    if (snapshot.connectionState == ConnectionState.done && snapshot.data!=null){
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: (deviceOrientation == Orientation.portrait) ? 3 : 5,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5
                        ),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index){
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return SingleImage(image: ImageUtility.imageFromBase64String(snapshot.data[index]), base64string: snapshot.data[index]);
                              }));
                            },
                            child: GridTile(
                              child: Container(
                                color: Colors.black87,
                                child: ImageUtility.imageFromBase64String(snapshot.data[index])
                              ),
                            ),
                          );
                        },
                      );
                    }
                    else if (snapshot.connectionState == ConnectionState.none) {
                      return Text("No data");
                    }
                    else{
                      return Center(child: Text("Your saved images will be visible here."));
                    }
                    return CircularProgressIndicator();
                  },
                ),
          ),
          Container(
            height: (MediaQuery.of(context).size.height)*0.4,
            margin: EdgeInsets.all(10),
            child: FutureBuilder(
              future: videoList,
              //future: VideoUtility.getVideoListFromPreferences(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                if (snapshot.connectionState == ConnectionState.done && snapshot.data!=null){
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index){
                      var object = snapshot.data.docs[index].data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          GestureDetector(
                            // onTap: () {
                            //   Navigator.push(context, MaterialPageRoute(builder: (context){
                            //     return SingleVideo(url: snapshot.data.docs[index].data()["url"]);
                            //   }));
                            // },
                            child: Container(
                              height: MediaQuery.of(context).size.height/3.3,
                              margin: EdgeInsets.all(5),
                              //color: Colors.blueGrey,
                              //child: VideoPlayer(VideoPlayerController.file(File(snapshot.data.docs[index].data()["url"])))
                              child: Chewie(controller: ChewieController(
                                //videoPlayerController: VideoPlayerController.file(VideoUtility.videoFromBase64String(snapshot.data[index])),
                                videoPlayerController: VideoPlayerController.network(object["url"]),
                                autoPlay: false,
                                looping: false,
                                autoInitialize: true,
                              ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextButton.icon(
                              onPressed: (){
                                deleteVideo(object["url"],object["docId"]);
                                // VideoUtility.removeVideoFromPreferences(snapshot.data[index]);
                                // setState(() {});
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              label: Text('Delete', style: TextStyle(color: Colors.black87),)
                          ),
                        ],
                      );
                    },
                  );
                }
                else if (snapshot.connectionState == ConnectionState.none) {
                  return Text("No data");
                }
                else{
                  return Center(child: Text("Your saved videos will be visible here."));
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}
