import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Class of functions to help push to Firebase
class Database {
  static Future<dynamic> once(String child) async{
    List<String> children = child.split('/');
    dynamic jsonData = jsonDecode(
      await rootBundle.loadString('assets/${children[0]}.json')
    );
    
    if(children.length == 2){
      if(jsonData[children[1]] != null){
        return jsonData[children[1]];
      }
    }
    else if(children.length == 3){
      return jsonData[children[1]][children[2]];
    }
    else if(children.length == 4){
      if(jsonData[children[1]][children[2]] == null){
        return null;
      }
      else{
        return jsonData[children[1]][children[2]][children[3]];
      }
    }
    else{
      return jsonData;
    }
  }
}
