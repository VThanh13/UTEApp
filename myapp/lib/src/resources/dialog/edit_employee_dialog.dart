import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/EmployeeModel.dart';

TextEditingController _nameController = TextEditingController();
StreamController _nameControll = StreamController();
Stream get nameStream => _nameControll.stream;

class EditEmployeeDialog {
  static void showEditEmployeeDialog(
      BuildContext context, EmployeeModel employee) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          color: const Color(0xffffffff),
          height: 500,
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                height: 150,
                child: Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.tealAccent,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(employee.image!),
                          radius: 46,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
              Text(
                employee.roles!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w200,
                ),
              ),
              Text(
                employee.name!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
              Container(
                margin: const EdgeInsets.fromLTRB(5, 20, 5, 15),
                width: 300,
                child: StreamBuilder(
                  stream: nameStream,
                  builder: (context, snapshot) => TextField(
                    controller: _nameController..text = employee.name!,
                    onChanged: (text) => {},
                    decoration: InputDecoration(
                      labelText: "Tên của bạn",
                      errorText:
                          snapshot.hasError ? snapshot.error.toString() : null,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 1,
                          )),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  ElevatedButton(
                      onPressed: () => {hideEditEmployeeDialog(context)},
                      child: const Text(
                        'Lưu',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      )),
                  ElevatedButton(
                      onPressed: () => {hideEditEmployeeDialog(context)},
                      child: const Text(
                        'Thoát',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static hideEditEmployeeDialog(BuildContext context) {
    Navigator.of(context).pop(EditEmployeeDialog);
  }
}
