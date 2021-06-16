import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
 
class ImageUtility {

  static const String KEY = "IMAGE_LIST_KEY";
 
  static Future<List> getImageListFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(KEY) ?? null;
  }
 
  static Future<bool> saveImageToPreferences(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> imgList = await getImageListFromPreferences();
    if(imgList==null){
      imgList = [];
    }
    print("Image String: $value");
    imgList.add(value);
    prefs.setStringList(KEY, imgList);
  }

  static Future<bool> removeImageFromPreferences(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List imgList = await getImageListFromPreferences();
    imgList.remove(value);
    prefs.setStringList(KEY, imgList);
  }
 
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }
 
  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }
 
  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}