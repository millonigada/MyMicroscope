import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_camera/constants/colors.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';

Widget featureControlsRow({
  BuildContext context,
  bool magnifyTapped,
  Function onMagnifyTapped,
  bool focusTapped,
  Function onFocusTapped,
  bool lightTapped,
  Function onLightTapped,
}){
  return Container(
    width: MediaQuery.of(context).size.width,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: SvgPicture.asset(
            "assets/icons/Magnify.svg",
            width: 34,
            height: 34,
            color: magnifyTapped ? amberColor : whiteColor,
          ),
          onPressed: onMagnifyTapped,
        ),
        IconButton(
          icon: SvgPicture.asset(
            "assets/icons/Focus.svg",
            width: 34,
            height: 34,
            color: focusTapped ? amberColor : whiteColor,
          ),
          onPressed: onFocusTapped,
        ),
        IconButton(
          icon: SvgPicture.asset(
            "assets/icons/Exposure.svg",
            width: 34,
            height: 34,
            color: lightTapped ? amberColor : whiteColor,
          ),
          onPressed: onLightTapped,
        ),
        IconButton(
          icon: SvgPicture.asset(
            "assets/icons/Hamburger.svg",
            width: 34,
            height: 34,
            color: whiteColor,
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        )
      ],
    ),
  );
}

Widget magnificationSlider({BuildContext context, sliderValue,  Function onChanged, Function onPlusTapped, Function onClearTapped, TextEditingController magnificationTextEditingController}){
  return Container(
    color: Colors.transparent,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
            icon: Icon(
              Icons.add,
              color: whiteColor,
            ),
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      content: Container(
                        height: 131.42,
                        width: 273,
                        decoration: BoxDecoration(
                          color: blackColor,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Enter magnification value",
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 18
                              ),
                            ),
                            Container(
                              width: 203,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: amberColor)
                              ),
                              child: Center(
                                child: TextFormField(
                                  controller: magnificationTextEditingController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                  enabled: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),
                                    suffix: IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: onClearTapped,
                                    )
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                onPlusTapped();
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 85.69,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: Center(
                                  child: Text(
                                    "Enter",
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
                    );
                  }
              );
            }
        ),
        SizedBox(
          height: 10,
        ),
        SfSliderTheme(
          data: SfSliderThemeData(
            activeTrackHeight: 4,
            inactiveTrackHeight: 4,
            activeDividerColor: whiteColor,
            inactiveDividerColor: whiteColor,
            activeDividerRadius: 5.5,
            inactiveDividerRadius: 5.5,
            thumbColor: amberColor,
            thumbRadius: 13.5,
            activeLabelStyle: TextStyle(
              color: whiteColor,
              fontWeight: FontWeight.w400,
              fontSize: 24
            ),
            inactiveLabelStyle: TextStyle(
                color: whiteColor,
                fontWeight: FontWeight.w400,
                fontSize: 24
            ),
          ),
          child: Container(
            height: 350,
            child: SfSlider.vertical(
              min: 0.0,
              max: 600.0,
              value: sliderValue,
              interval: 100,
              inactiveColor: blackColor,
              showTicks: true,
              showLabels: true,
              showDividers: true,
              stepSize: 5,
              labelFormatterCallback: (actualValue,formattedText){
                return "${actualValue.toStringAsFixed(0)}x";
              },
              minorTicksPerInterval: 1,
              onChanged: onChanged,
            ),
          ),
        )
      ],
    ),
  );
}

Widget lightIntensitySlider({BuildContext context, sliderValue, Function onChanged}){
  return Container(
    color: Colors.transparent,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: SvgPicture.asset(
            "assets/icons/MaxLight.svg",
            width: 15,
            height: 15,
            color: whiteColor,
          ),
        ),
        // SizedBox(
        //   height: 10,
        // ),
        SfSliderTheme(
          data: SfSliderThemeData(
            thumbColor: amberColor,
            thumbRadius: 13.5,
          ),
          child: Container(
            height: 350,
            child: SfSlider.vertical(
              min: 0,
              max: 1024,
              value: sliderValue,
              showTicks: false,
              showLabels: false,
              onChanged: onChanged,
              enableTooltip: true,
              tooltipPosition: SliderTooltipPosition.left,
              inactiveColor: blackColor,
              trackShape: SfTrackShape(),
            ),
          ),
        ),
        // SizedBox(
        //   height: 10,
        // ),
        IconButton(
          icon: SvgPicture.asset(
            "assets/icons/MinLight.svg",
            width: 15,
            height: 15,
            color: whiteColor,
          ),
        ),
      ],
    ),
  );
}