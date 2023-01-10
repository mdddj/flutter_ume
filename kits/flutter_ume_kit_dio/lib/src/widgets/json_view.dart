
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';

class MyJsonView extends StatelessWidget {
  final String title;
  final dynamic data;

  const MyJsonView({Key? key, required this.title, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final m =  MediaQuery.of(context);
    final bodyHei = m.size.height - kToolbarHeight - m.padding.top;
    return Scaffold(
      appBar: AppBar(title: Text("格式化显示"),),
      body: SizedBox(
        width: double.infinity,
        height: bodyHei ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            SizedBox(height: 12,),
            Expanded(
              child: ListView(children: [
                widget
              ],),
            ),
            SizedBox(height: 12,)
          ],
        ),
      ),
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