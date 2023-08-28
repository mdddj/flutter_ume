
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';

class MyJsonView extends StatelessWidget {
  final String title;
  final dynamic data;

  const MyJsonView({Key? key, required this.title, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("格式化显示"),),
      body:widget,
    );
  }

  Widget get widget {
    return getMap.isNotEmpty ? JsonView.map(getMap) : Text(data.toString());
  }
  Map<String,dynamic> get getMap {
    if(data is Map<String,dynamic>) {
      return data;
    }
    try{
      return jsonDecode(data.toString());
    }catch(e){
      return {};
    }
  }
}