import 'dart:typed_data';
import 'package:my_camera/constants/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class VideoUtility {

  static String KEY = videoKey;
 
  static Future<List> getVideoListFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(KEY) ?? null;
  }
 
  static Future<bool> saveVideoToPreferences(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> videoList = await getVideoListFromPreferences();
    if(videoList==null){
      videoList = [];
    }
    videoList.add(value);
    prefs.setStringList(KEY, videoList);
  }

  static Future<bool> removeVideoFromPreferences(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List videoList = await getVideoListFromPreferences();
    videoList.remove(value);
    prefs.setStringList(KEY, videoList);
  }
 
  static File videoFromBase64String(String base64String) {
    return File.fromRawPath(
      base64Decode(base64String),
    );
  }
 
  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }
 
  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}