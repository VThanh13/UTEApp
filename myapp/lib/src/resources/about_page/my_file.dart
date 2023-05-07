import 'package:flutter/material.dart';

class MyFile extends StatefulWidget{
  const MyFile({super.key});

  @override
  State<MyFile> createState() => _MyFileState();
}

class _MyFileState extends State<MyFile>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của bạn '),
      ),
    );
  }
}