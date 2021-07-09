import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_camera/constants/colors.dart';
import 'package:my_camera/constants/keys.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestScreen extends StatefulWidget {

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with TickerProviderStateMixin{

  CameraController cameraController;
  //List<Widget> appBarsList = [observationAppBar(), sizeDistributionAppBar()];
  List myCameras;
  int selectedCameraIndex;
  String imgPath;
  XFile imgFile;
  String videoPath;
  XFile videoFile;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 10.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  int _pointers = 0;
  double scaleStart = 0;
  double scaleEnd = 12.0;
  bool measuringMode = false;
  List<Offset> _offsets = <Offset>[];
  TabController _tabController;
  TabController _appBarTabController;
  double _colorFilterOpacity = 0.8;
  bool openedUpMode = false;

  getCameraPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey(cameraKey)){
      return prefs.getInt(cameraKey);
    } else {
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras){
      myCameras = availableCameras;
      if(myCameras.length > 0){
        setState(() {
          selectedCameraIndex = 0;
        });
        initCameraController(myCameras[selectedCameraIndex]).then((void v){});
      } else{
        print('No cameras found.');
      }
    }).catchError((err){
      print('Error: ${err.hashCode}');
    });
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]
    );
    _tabController = new TabController(vsync: this, length: 2);
    _appBarTabController = new TabController(vsync: this, length: 4);
  }

  @override
  void dispose() {
    super.dispose();
    cameraController?.dispose();
    videoController?.dispose();
    _tabController.dispose();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown]
    );
  }

  Future initCameraController(CameraDescription cameraDescription) async {
    if(cameraController!=null){
      await cameraController.dispose();
    }

    cameraController = CameraController(cameraDescription, ResolutionPreset.high, enableAudio: true);

    cameraController.addListener(() {
      if(mounted){
        setState(() {});
      }
    });

    if(cameraController.value.hasError){
      print('Camera error: ${cameraController.value.errorDescription}');
    }

    try{
      await cameraController.initialize();
    }on CameraException catch(e){
      showCameraException(e);
    }

    if(mounted){
      setState(() {});
    }

    _maxAvailableZoom = await cameraController.getMaxZoomLevel();
  }

  Widget cameraControls(context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        FloatingActionButton(
          onPressed: (){
            onCapture(context);
          },
          child: Icon(
            Icons.camera,
            color: Colors.black87,
          ),
          backgroundColor: Colors.white,
        ),
      ],
    );
  }

  Widget cameraToggle(){
    if(myCameras == null || myCameras.isEmpty){
      return Spacer();
    }

    CameraDescription selectedCamera = myCameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: onCameraToggle,
          icon: Icon(
            getCameraLensIcon(lensDirection),
            color: Colors.white,
            size: 24,
          ),
          // label: Text('${lensDirection.toString().substring(lensDirection.toString().indexOf('.')+1).toUpperCase()}',
          //   style: TextStyle(
          //     color: Colors.white,
          //     fontWeight: FontWeight.w500
          //   ),
          // ),
        ),
      ),
    );
  }

  void onCapture(context) async {
    try{
      final path = join((await getTemporaryDirectory()).path,
          '${DateTime.now()}.png'
      );
      await cameraController.takePicture().then((XFile file){
        if(mounted) {
          setState(() {
            imgFile = file;
            imgPath = file.path;
          });
          print('ImageFilePath: ${file.path}');
          Toast.show("Slide up to view details about your image.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
        }
      });
    } catch (e){
      showCameraException(e);
    }
  }

  void onCameraToggle() {
    selectedCameraIndex = selectedCameraIndex<(myCameras.length-1) ? selectedCameraIndex + 1 : 0;

    CameraDescription selectedCamera = myCameras[selectedCameraIndex];

    initCameraController(selectedCamera);
  }

  IconData getCameraLensIcon(CameraLensDirection lensDirection) {

    switch(lensDirection){
      case CameraLensDirection.back:
        return CupertinoIcons.switch_camera;
      case CameraLensDirection.front:
        return CupertinoIcons.switch_camera_solid;
      case CameraLensDirection.external:
        return CupertinoIcons.photo_camera;
      default:
        return Icons.device_unknown;
    }

  }

  void showCameraException(CameraException e){
    String errorText = 'Camera Error: $e';
    print(errorText);
  }

  Widget cameraPreview(){
    if(cameraController == null || !cameraController.value.isInitialized){
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      );
    }

    return CustomPaint(
      // foregroundPainter: MeasurePainter(offsets: _offsets, measuringMode: measuringMode, currentScale: _currentScale),
      child: AspectRatio(
        //aspectRatio: cameraController.value.aspectRatio,
        aspectRatio: 3/4,
        child: Listener(
          onPointerDown: (_) => _pointers++,
          onPointerUp: (_) => _pointers--,
          child: CameraPreview(
            cameraController,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints){
                return GestureDetector(
                  // behavior: HitTestBehavior.opaque,
                  // onScaleStart: handleScaleStart,
                  // onScaleUpdate: handleScaleUpdate,
                  // onTapDown: measuringMode ? (details){
                  //   if(_offsets.length<2)
                  //     {
                  //       Toast.show("Now tap to set your second point.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
                  //     }
                  //   final RenderBox referenceBox = context.findRenderObject();
                  //   setState(() {
                  //     _offsets.add(referenceBox.globalToLocal(details.globalPosition));
                  //   });
                  // } : null,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if(openedUpMode){
      setState(() {
        openedUpMode=false;
      });
      return Future.value(false);
    }
    else{
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {

    if(!cameraController.value.isInitialized){
      return new Scaffold(
        body: Container(
            child: CircularProgressIndicator()
        ),
      );
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          body: Container(
            child: SafeArea(
              child: Stack(
                alignment: Alignment.bottomCenter,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    //width: MediaQuery.of(context).size.width,
                    child: NativeDeviceOrientationReader(
                        useSensor: true,
                        builder: (context){
                          NativeDeviceOrientation deviceOrientation = NativeDeviceOrientationReader.orientation(context);
                          int turns;
                          switch(deviceOrientation){
                            case NativeDeviceOrientation.landscapeLeft: turns = 1; break;
                            case NativeDeviceOrientation.landscapeRight: turns = -1; break;
                            case NativeDeviceOrientation.portraitDown: turns = 2; break;
                            case NativeDeviceOrientation.portraitUp: turns = 0; break;
                            default: turns=0; break;
                          }
                          return RotatedBox(
                              quarterTurns: turns,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0),
                                    bottomLeft: Radius.circular(8.0),
                                  ),
                                  child: cameraPreview()
                              )
                          );
                        }
                    ),
                  ),
                  SlidingUpPanel(
                    maxHeight: 140,
                    minHeight: 140,
                    color: Colors.black,
                    panel: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: myCameras.length,
                                itemBuilder: (context, index){
                                  return GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        selectedCameraIndex = index;
                                      });
                                      initCameraController(myCameras[selectedCameraIndex]).then((void v){});
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: amberColor,
                                        border: selectedCameraIndex == index ? Border.all(color: blackColor, width: 1) : Border.all(color: Colors.transparent)
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$index'
                                        ),
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setInt(cameraKey, selectedCameraIndex);
                            },
                            child: Container(
                              width: 85.69,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: whiteColor,
                                  //borderRadius: BorderRadius.circular(4)
                              ),
                              child: Center(
                                child: Text(
                                  "Set",
                                  style: TextStyle(
                                      color: blackColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
