import 'package:flutter/material.dart';

class MyInfo extends StatefulWidget{
  @override
  _MyInfoState createState() => new _MyInfoState();
}

class _MyInfoState extends State<MyInfo>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new  AppBar(
        title: new Text('Thông tin cá nhân'),
      ),
    );
  }
}