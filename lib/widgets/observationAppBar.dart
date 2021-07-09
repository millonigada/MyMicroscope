import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

AppBar observationAppBar({
  TabController tabController,
  BuildContext context,
  String magnificationDropdownValue,
  Function onChangedmagnificationDropdownValue
}){
  return AppBar(
    automaticallyImplyLeading: false,
    title: TabBar(
      controller: tabController,
      tabs: [
        DropdownButton<String>(
          value: magnificationDropdownValue,
          elevation: 16,
          underline: Container(),
          style: TextStyle(color: Colors.white),
          dropdownColor: Colors.blueGrey,
          onChanged: onChangedmagnificationDropdownValue,
          items: <String>['M', '50x', '100x', '200x', '300x', '400x', '500x', '600x']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Text("F"),
        Text("L"),
        IconButton(
            icon: Icon(Icons.menu),
            onPressed: (){
              Navigator.pop(context);
            }
        )
      ],
    ),
  );
}

AppBar sizeDistributionAppBar({
  TabController tabController,
  BuildContext context,
  String magnificationDropdownValue,
  Function onChangedmagnificationDropdownValue,
  String sdDropdownValue,
  Function onChangedSdDropdownValue
}){
  return AppBar(
    automaticallyImplyLeading: false,
    title: TabBar(
      controller: tabController,
      tabs: [
        DropdownButton<String>(
          value: magnificationDropdownValue,
          elevation: 16,
          underline: Container(),
          style: TextStyle(color: Colors.white),
          dropdownColor: Colors.blueGrey,
          onChanged: onChangedmagnificationDropdownValue,
          items: <String>['M', '50x', '100x', '200x', '300x', '400x', '500x', '600x']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Text("F"),
        Text("L"),
        DropdownButton<String>(
          value: sdDropdownValue,
          elevation: 16,
          underline: Container(),
          style: TextStyle(color: Colors.white),
          dropdownColor: Colors.blueGrey,
          onChanged: onChangedSdDropdownValue,
          items: <String>['|||', 'Size Analysis', 'Distribution Curve']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    ),
  );
}