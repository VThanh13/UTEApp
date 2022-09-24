import 'package:flutter/material.dart';

class AdmissionHistory extends StatefulWidget{
  @override
  _AdmissionHistoryState createState() => new _AdmissionHistoryState();
}

class _AdmissionHistoryState extends State<AdmissionHistory>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new  AppBar(
        title: new Text('Lịch sử tuyển sinh'),
      ),
    );
  }
}