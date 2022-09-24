import 'package:flutter/material.dart';

class MyFile extends StatefulWidget{
  @override
  _MyFileState createState() => new _MyFileState();
}

class _MyFileState extends State<MyFile>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new  AppBar(
        title: new Text('Hồ sơ của bạn'),
      ),
    );
  }
}