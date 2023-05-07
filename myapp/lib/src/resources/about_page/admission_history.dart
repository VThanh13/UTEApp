import 'package:flutter/material.dart';

class AdmissionHistory extends StatefulWidget{
  const AdmissionHistory({super.key});

  @override
  State<AdmissionHistory> createState() => _AdmissionHistoryState();
}

class _AdmissionHistoryState extends State<AdmissionHistory>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử tuyển sinh'),
      ),
    );
  }
}