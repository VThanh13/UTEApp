import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  bool isFingerprintEnabled;

  SettingScreen({required this.isFingerprintEnabled});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cài đặt')),
      body: Center(
        child: SwitchListTile(
          title: Text('Đăng nhập bằng vân tay'),
          value: widget.isFingerprintEnabled,
          onChanged: (value) {
            setState(() {
              widget.isFingerprintEnabled = value;
            });
          },
        ),
      ),
    );
  }
}