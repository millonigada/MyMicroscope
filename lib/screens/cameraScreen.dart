import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_camera/constants/colors.dart';
import 'package:my_camera/constants/keys.dart';
import 'package:my_camera/screens/galleryScreen.dart';
import 'package:my_camera/screens/imageScreen.dart';
import 'package:my_camera/screens/videoScreen.dart';
import 'package:my_camera/widgets/cameraControls.dart';
import 'package:my_camera/widgets/observationAppBar.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:video_player/video_player.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_socket_plugin/flutter_socket_plugin.dart';

class CameraScreen extends StatefulWidget {

  final int selectedMenuButtonIndex;
  CameraScreen({this.selectedMenuButtonIndex});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin{

  CameraController cameraController;
  List<Widget> appBarsList = [observationAppBar(), sizeDistributionAppBar()];
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
  ///String magnificationDropdownValue = "M";
  double _magnificationSliderValue = 10;
  double _lightIntensitySliderValue = 10;
  double _fSliderValue = 10;
  FlutterSocket flutterSocket;
  bool connected = false;
  String _host = "2.2.2.2";
  int _port = 80;
  String receiveMessage = "";
  bool magnifyTapped = false;
  bool focusTapped = false;
  bool lightTapped = false;
  bool videoMode = false;
  TextEditingController magnificationTextEditingController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    initSocket();
    availableCameras().then((availableCameras){
      myCameras = availableCameras;

      if(myCameras.length > 0){
        // setState(() {
        //   selectedCameraIndex = getCameraPreferences();
        // });
        getCameraPreferences().then((void v){
          print("selectedCameraIndex: $selectedCameraIndex");
            initCameraController(myCameras[selectedCameraIndex]).then((void v){});
          }
        );
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
    flutterSocket.tryDisconnect();
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown]
    );
  }

  getCameraPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey(cameraKey)){
      print("If called");
      print("prefs.getInt(cameraKey): ${prefs.getInt(cameraKey)}");
      setState(() {
        selectedCameraIndex = prefs.getInt(cameraKey);
      });
    } else {
      print("Else called");
      setState(() {
        selectedCameraIndex = 0;
      });
    }
  }

  initSocket() async {

    /// init socket
    flutterSocket = FlutterSocket();

    /// listen connect callback
    flutterSocket.connectListener((data){
      print("connect listener data:$data");
    });

    /// listen error callback
    flutterSocket.errorListener((data){
      print("error listener data:$data");
    });

    /// listen receive callback
    flutterSocket.receiveListener((data){
      print("receive listener data:$data");
      if (data != null) {
        receiveMessage = receiveMessage + "\n" + data;
      }
      setState(() {

      });
    });

    /// listen disconnect callback
    flutterSocket.disconnectListener((data){
      print("disconnect listener data:$data");
    });

    await flutterSocket.createSocket(_host, _port, timeout: 20);
    flutterSocket.tryConnect();
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
  
  Widget viewGallery(context){
    return IconButton(
      icon: Icon(
        CupertinoIcons.photo_on_rectangle,
        size: 24,
        color: Colors.white,
      ),
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return GalleryScreen();
        }));
      },
    );
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
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return ImageScreen(imgFile: imgFile, imgPath: imgPath);
          }));
          //Toast.show("Slide up to view details about your image.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
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
      foregroundPainter: MeasurePainter(offsets: _offsets, measuringMode: measuringMode, currentScale: _currentScale),
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
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: handleScaleStart,
                    onScaleUpdate: handleScaleUpdate,
                    onTapDown: measuringMode ? (details){
                      if(_offsets.length<2)
                        {
                          Toast.show("Now tap to set your second point.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
                        }
                      final RenderBox referenceBox = context.findRenderObject();
                      setState(() {
                        _offsets.add(referenceBox.globalToLocal(details.globalPosition));
                      });
                    } : null,
                  );
                },
              ),
            ),
        ),
      ),
    );
  }

  void handleScaleStart(ScaleStartDetails details){
    _baseScale = _currentScale;
  }

  Future<void> handleScaleUpdate (ScaleUpdateDetails details) async {
    if(cameraController==null||_pointers!=2){
      return;
    }
    setState(() {
      _currentScale = (_baseScale*details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);
      scaleEnd = 12/_currentScale;
      debugPrint(scaleEnd.toString());
    });
    await cameraController.setZoomLevel(_currentScale);
  }

  Widget fSlider(){
    return Slider(
        value: _fSliderValue,
        min: 0,
        max: 100,
        divisions: 100,
        //label: _currentScale.toStringAsFixed(2)+'x',
        activeColor: Colors.white,
        inactiveColor: Colors.grey,
        onChanged: (double value) {
          // setState((){
          //   _currentScale = (_baseScale*value).clamp(_minAvailableZoom, _maxAvailableZoom);
          //   debugPrint('_currentScale\n');
          //   debugPrint(_currentScale.toString());
          //   scaleEnd = 12/_currentScale;
          //   debugPrint(scaleEnd.toString());
          // });
          // await cameraController.setZoomLevel(_currentScale);
          setState(() {
            _fSliderValue = value;
          });
        }
    );
  }

  // Widget lightIntensitySlider(){
  //   return Slider(
  //       value: _lightIntensitySliderValue,
  //       min: 0,
  //       max: 1024,
  //       divisions: 1024,
  //       //label: _currentScale.toStringAsFixed(2)+'x',
  //       activeColor: Colors.white,
  //       inactiveColor: Colors.grey,
  //       onChanged: (double value) {
  //         // print(value);
  //         // setState(() {
  //         //   _lightIntensitySliderValue = value;
  //         // });
  //         // flutterSocket.send('$value');
  //       },
  //       onChangeEnd: (double value){
  //
  //       },
  //   );
  // }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  void onStopButtonPressed(BuildContext context) {
    stopVideoRecording().then((file) {
      if (mounted) setState(() {});
      if (file != null) {
        debugPrint('Video recorded to ${file.path}');
        setState(() {
          videoFile = file;
          videoPath = file.path;
        });
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context){
              return VideoScreen(videoFile: this.videoFile,videoPath: this.videoPath);
            })
        );
      }
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController cameraController = this.cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      debugPrint('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      showCameraException(e);
      return;
    }
  }

  Future<XFile> stopVideoRecording() async {
    final CameraController cameraController = this.cameraController;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController cameraController = this.cameraController;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController cameraController = this.cameraController;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      showCameraException(e);
      rethrow;
    }
  }

  // Widget scaleWidget(scaleFactor){
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       Divider(
  //         indent: 20,
  //         endIndent: 20,
  //         color: Colors.white,
  //         thickness: 2,
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //
  //         children: [
  //           Text(scaleEnd==12.0?'${scaleStart.toStringAsFixed(0)} μ':'${scaleStart.toStringAsFixed(0)} μ', style: TextStyle(color: Colors.white),),
  //           Text(scaleEnd==12.0?'1 μ':'${scaleEnd.toStringAsFixed(2)} μ', style: TextStyle(color: Colors.white),)
  //         ],
  //       ),
  //     ],
  //   );
  //   // return Divider(
  //   //   color: Colors.white,
  //   // );
  // }
  double getMaxScaleFactor(){
    return 100/_currentScale;
  }

  Widget scaleWidget(scaleFactor){
    return SfLinearGauge(
      minimum: _minAvailableZoom,
      maximum: getMaxScaleFactor(),
      axisTrackStyle: LinearAxisTrackStyle(
        color: Colors.white
      ),
      minorTicksPerInterval: 5,
      majorTickStyle: LinearTickStyle(
        color: Colors.white,
        length: 11
      ),
      minorTickStyle: LinearTickStyle(
        color: Colors.white70,
        length: 7
      ),
      axisLabelStyle: TextStyle(
        color: Colors.white,
      ),
      labelFormatterCallback: (value){
        if(value==(getMaxScaleFactor().toStringAsFixed(2))){
          return("");
        } else {
          return("$valueμ");
        }
      },
    );
  }

  Widget  circularZoomDial(BuildContext context){
    return SingleCircularSlider(
      100,
      1,
      height: 350,
      width: 370,
      primarySectors: 10,
      secondarySectors: 100,
      handlerColor: Colors.white,
      selectionColor: Colors.grey[950],
      onSelectionChange: (init,end,laps) async {
        var value=(end-init)/10;
        setState((){
          _currentScale = (_baseScale*value).clamp(_minAvailableZoom, _maxAvailableZoom);
          debugPrint('_currentScale\n');
          debugPrint(_currentScale.toString());
          scaleEnd = 12/_currentScale;
          debugPrint(scaleEnd.toString());
        });
        await cameraController.setZoomLevel(_currentScale);
      },
      onSelectionEnd: (init,end,laps){
        Toast.show("${_currentScale}x", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
      },
    );
  }

  Widget findDistanceButton(BuildContext context){
    return IconButton(
      onPressed: (){
        setState(() {
          measuringMode ? measuringMode=false : measuringMode=true;
          _offsets.clear();
        });
        measuringMode ? Toast.show("Tap on the screen to set your first point.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.TOP) : null;
      },
      icon: Icon(
        measuringMode? Icons.check :Icons.add_location_alt_outlined,
        color: Colors.white,
      ),
    );
  }

  Widget photoControlsRow(BuildContext context){
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            findDistanceButton(context),
            SizedBox(height: 40),
            cameraControls(context),
            SizedBox(height: 40),
            viewGallery(context)
          ],
        ),
        (imgFile!=null&&imgPath!=null) ?
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundImage: FileImage(File(imgPath)),
              ),
              SizedBox(height: 20),
              Text(
                "PROPERTIES:",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Stem of Monocetyledon T.S. at 500x",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Length of Monocetyledon found to be 11.4μ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
                ),
              ),
              Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return ImageScreen(imgFile: imgFile, imgPath: imgPath);
                }));
              }, 
              child: Text("View Full Image")
            ),
            TextButton(
              onPressed: (){
                setState(() {
                  imgFile = null;
                  imgPath = null;
                });
              }, 
              child: Text("Discard")
            )
          ],
        ),
            ],
          ),
        ) : Container(),
      ],
    );
  }

  Widget videoControlsRow(BuildContext context){
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: cameraController != null &&
              cameraController.value.isInitialized &&
              !cameraController.value.isRecordingVideo
              ? Icon(Icons.videocam) : Icon(Icons.stop),
            color: cameraController != null &&
              cameraController.value.isInitialized &&
              !cameraController.value.isRecordingVideo
              ? Colors.white : Colors.red,
            onPressed: cameraController != null &&
              cameraController.value.isInitialized &&
              !cameraController.value.isRecordingVideo
              ? onVideoRecordButtonPressed
              : (){
                onStopButtonPressed(context);
            },
          ),
          SizedBox(width: 20),
          IconButton(
            icon: cameraController != null &&
              cameraController.value.isRecordingPaused
              ? Icon(Icons.play_arrow)
              : Icon(Icons.pause),
            color: Colors.white,
            onPressed: cameraController != null &&
              cameraController.value.isInitialized &&
              cameraController.value.isRecordingVideo
              ? (cameraController.value.isRecordingPaused)
              ? onResumeButtonPressed
              : onPauseButtonPressed
              : null,
            ),
          ],
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

  onMagnifyTapped(){
    setState(() {
      if(magnifyTapped==false){
        magnifyTapped=true;
        focusTapped=false;
        lightTapped=false;
      }else{
        magnifyTapped=false;
      }
    });
  }

  onFocusTapped(){
    setState(() {
      if(focusTapped==false){
        magnifyTapped=false;
        focusTapped=true;
        lightTapped=false;
      }else{
        focusTapped=false;
      }
    });
  }

  onLightTapped(){
    setState(() {
      if(lightTapped==false){
        magnifyTapped=false;
        focusTapped=false;
        lightTapped=true;
      }else{
        lightTapped=false;
      }
    });
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
          // appBar: observationAppBar(
          //     tabController: _appBarTabController,
          //     context: context,
          //   magnificationDropdownValue: magnificationDropdownValue,
          //   onChangedmagnificationDropdownValue: (String newValue){
          //       setState(() {
          //         magnificationDropdownValue = newValue;
          //       });
          //   }
          // ),
          body: Container(
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
                // ColorFiltered(
                //   colorFilter: ColorFilter.mode(
                //       Colors.black.withOpacity(openedUpMode?0.0:0.8), BlendMode.srcOut),
                //   child: Stack(
                //     fit: StackFit.expand,
                //     children: [
                //       Container(
                //         decoration: BoxDecoration(
                //             color: Colors.black,
                //             backgroundBlendMode: BlendMode.dstOut),
                //       ),
                //       !openedUpMode ? Container(
                //         margin: EdgeInsets.only(top: 125),
                //         child: Align(
                //           alignment: Alignment.topCenter,
                //             child: circularZoomDial(context),
                //           ),
                //       ) : Container(),
                //       GestureDetector(
                //         onTap: (){
                //           print("Gesture detector called.");
                //           setState(() {
                //             openedUpMode=true;
                //           });
                //           Toast.show("Press back for minimized view", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.CENTER);
                //         },
                //         child: Container(
                //           margin: const EdgeInsets.only(top: 150),
                //           child: Align(
                //             alignment: Alignment.topCenter,
                //             child: Container(
                //                   height: 300,
                //                   width: 300,
                //                   decoration: BoxDecoration(
                //                       color: Colors.red,
                //                       shape: BoxShape.circle
                //                   ),
                //                 ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                measuringMode ? CustomPaint(
                  foregroundPainter: MeasurePainter(offsets: _offsets, measuringMode: measuringMode, currentScale: _currentScale),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    // onScaleStart: handleScaleStart,
                    // onScaleUpdate: handleScaleUpdate,
                    onTapDown: measuringMode ? (details){
                      if(_offsets.length<2)
                      {
                        Toast.show("Now tap to set your second point.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
                      }
                      final RenderBox referenceBox = context.findRenderObject();
                      setState(() {
                        _offsets.add(referenceBox.globalToLocal(details.globalPosition));
                      });
                    } : null,
                    child: Container(
                      margin: const EdgeInsets.only(top: 150),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle
                          ),
                        ),
                      ),
                    ),
                  ),
                ) : Container(),
                //Spacer(),
                this.widget.selectedMenuButtonIndex==1 ? Positioned(
                  bottom: 125,
                    child: scaleWidget(1)
                ) : Container(),
                // Positioned(
                //   top: 0,
                //   height: 100,
                //   width: MediaQuery.of(context).size.width,
                //   child: TabBarView(
                //     controller: _appBarTabController,
                //     children: [
                //       Container(),
                //       fSlider(),
                //       Container(
                //         padding: EdgeInsets.only(left: 20,right: 20),
                //         child: Row(
                //           children: [
                //             Icon(Icons.brightness_4_rounded, color: whiteColor,),
                //             Expanded(child: lightIntensitySlider()),
                //             Icon(Icons.brightness_low_rounded, color: whiteColor),
                //           ],
                //         ),
                //       ),
                //       Text("Slideer fbh", style: TextStyle(color: whiteColor),)
                //     ],
                //   ),
                // ),
                Positioned(
                  top: 59.5,
                  child: featureControlsRow(
                    context: context,
                    magnifyTapped: magnifyTapped,
                    onMagnifyTapped: onMagnifyTapped,
                    focusTapped: focusTapped,
                    onFocusTapped: onFocusTapped,
                    lightTapped: lightTapped,
                    onLightTapped: onLightTapped
                  ),
                ),
                magnifyTapped ? Positioned(
                  left: 55,
                  top: 150,
                  child: magnificationSlider(
                    context: context,
                    sliderValue: _magnificationSliderValue,
                    onChanged: (value) async {
                      setState(() {
                        _magnificationSliderValue = value;
                      });
                      setState(() {
                        _currentScale = (_baseScale*value).clamp(_minAvailableZoom, _maxAvailableZoom);
                        scaleEnd = 12/_currentScale;
                        debugPrint(scaleEnd.toString());
                      });
                      await cameraController.setZoomLevel(_currentScale);
                    },
                    magnificationTextEditingController: magnificationTextEditingController,
                    onClearTapped: (){
                      setState(() {
                        magnificationTextEditingController.clear();
                      });
                    },
                    onPlusTapped: () async {
                      var value = double.parse(magnificationTextEditingController.text);
                      setState(() {
                        _magnificationSliderValue = value;
                      });
                      setState(() {
                        _currentScale = (_baseScale*value).clamp(_minAvailableZoom, _maxAvailableZoom);
                        scaleEnd = 12/_currentScale;
                        debugPrint(scaleEnd.toString());
                      });
                      await cameraController.setZoomLevel(_currentScale);
                    }
                  ),
                ) : Container(),
                lightTapped ? Positioned(
                  right: 55,
                  top: 150,
                  child: lightIntensitySlider(
                      context: context,
                      sliderValue: _lightIntensitySliderValue,
                      onChanged: (value){
                        setState(() {
                          _lightIntensitySliderValue = value;
                        });
                        flutterSocket.send('$value');
                      }
                  ),
                ) : Container(),
                Positioned(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 40),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Spacer(),

                          cameraController != null && cameraController.value.isInitialized && !cameraController.value.isRecordingVideo ?
                          Spacer() :
                          IconButton(
                            icon: cameraController != null &&
                                cameraController.value.isRecordingPaused
                                ? Icon(Icons.play_arrow)
                                : Icon(Icons.pause),
                            color: Colors.white,
                            onPressed: cameraController != null &&
                                cameraController.value.isInitialized &&
                                cameraController.value.isRecordingVideo
                                ? (cameraController.value.isRecordingPaused)
                                ? onResumeButtonPressed
                                : onPauseButtonPressed
                                : null,
                          ),

                          Spacer(),
                          Container(
                            height: 58,
                            width: 58,
                            child: cameraController != null &&
                                cameraController.value.isInitialized &&
                                !cameraController.value.isRecordingVideo ? IconButton(
                                icon: SvgPicture.asset(
                                  "assets/icons/Capture.svg",
                                  width: 45,
                                  height: 45,
                                  color: videoMode ? redColor : whiteColor,
                                ),
                                onPressed: (){
                                  if(videoMode){
                                    onVideoRecordButtonPressed();
                                  } else{
                                    onCapture(context);
                                  }
                                }
                            ) : IconButton(
                                icon: Icon(
                                    Icons.stop,
                                  color: redColor,
                                ),
                                onPressed: (){onStopButtonPressed(context);}
                            ),
                          ),
                          Spacer(),
                          videoMode ?
                          IconButton(
                              icon: SvgPicture.asset(
                                "assets/icons/Camera.svg",
                                width: 45,
                                height: 45,
                                color: whiteColor,
                              ),
                              onPressed: (){
                                if(cameraController != null &&
                                    cameraController.value.isInitialized &&
                                    !cameraController.value.isRecordingVideo){
                                  setState(() {
                                    videoMode = false;
                                  });
                                }
                              }
                          )
                          : IconButton(
                              icon: SvgPicture.asset(
                                "assets/icons/Video.svg",
                                width: 45,
                                height: 45,
                                color: whiteColor,
                              ),
                              onPressed: (){
                                setState(() {
                                  videoMode = true;
                                });
                              }
                          ),
                          Spacer()
                        ],
                      ),
                    )
                ),
                // SlidingUpPanel(
                //     maxHeight: MediaQuery.of(context).size.height*0.8,
                //     minHeight: 170,
                //     color: Colors.black,
                //     panel: Align(
                //     alignment: Alignment.topCenter,
                //     child: Container(
                //       child: Column(
                //         children: [
                //           Container(
                //             height: MediaQuery.of(context).size.height*0.8,
                //             width: double.infinity,
                //             padding: EdgeInsets.all(15),
                //             decoration: BoxDecoration(
                //               color: Colors.black,
                //             ),
                //             child: Column(
                //               children: [
                //                 TabBar(
                //                     tabs: [
                //                       Tab(text: "Photo"),
                //                       Tab(text: "Video")
                //                     ],
                //                     indicatorColor: Colors.red,
                //                     labelColor: Colors.red,
                //                     unselectedLabelColor: Colors.white,
                //                     controller: _tabController,
                //                   ),
                //                 //scaleWidget(1),
                //                 Container(
                //                   height: MediaQuery.of(context).size.height*0.6,
                //                   child: TabBarView(
                //                     controller: _tabController,
                //                     children: [
                //                       photoControlsRow(context),
                //                       videoControlsRow(context)
                //                     ],
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          )
      ),
    );
  }
}

class MeasurePainter extends CustomPainter{

  List<Offset> offsets;
  bool measuringMode;
  double currentScale;
  MeasurePainter({this.offsets,this.measuringMode,this.currentScale});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..strokeWidth = 2.0
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    if(measuringMode && this.offsets.length>0)
      {
        canvas.drawCircle(this.offsets[0], 4, paint);
        canvas.drawCircle(this.offsets[this.offsets.length-1], 4, paint);
      }

    if(measuringMode && this.offsets.length>1)
      {
        canvas.drawLine(this.offsets[0], this.offsets[this.offsets.length-1], paint);
        final length = (sqrt(((this.offsets[0].dx-this.offsets[this.offsets.length-1].dx)*(this.offsets[0].dx-this.offsets[this.offsets.length-1].dx))+((this.offsets[0].dy-this.offsets[this.offsets.length-1].dy)*(this.offsets[0].dy-this.offsets[this.offsets.length-1].dy)))/currentScale)/10;
        final textStyle = ui.TextStyle(
          color: Colors.white,
          fontSize: 10,
        );
        final paragraphStyle = ui.ParagraphStyle(
          textDirection: TextDirection.ltr,
        );
        final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
          ..pushStyle(textStyle)
          ..addText('${length.toStringAsFixed(2)} μ');
        final constraints = ui.ParagraphConstraints(width: 300);
        final paragraph = paragraphBuilder.build();
        paragraph.layout(constraints);
        canvas.drawParagraph(paragraph, Offset((offsets[0].dx+offsets[this.offsets.length-1].dx)/2 + 15,(offsets[0].dy+offsets[this.offsets.length-1].dy)/2));
      }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}
