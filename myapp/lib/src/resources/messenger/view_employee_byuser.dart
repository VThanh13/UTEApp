import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/models/EmployeeModel.dart';
import 'package:myapp/src/models/UserModel.dart';
import 'package:myapp/src/resources/employee/detail_question_employee.dart';
import 'package:myapp/src/resources/messenger/messenger_page.dart';

import '../../blocs/auth_bloc.dart';
import '../dialog/loading_dialog.dart';

class ViewEmployeeByUser extends StatefulWidget {
  _ViewEmployeeByUser createState() => new _ViewEmployeeByUser();

  final EmployeeModel employee;

  ViewEmployeeByUser({required this.employee, required this.users});

  final UserModel users;
}

class _ViewEmployeeByUser extends State<ViewEmployeeByUser> {
  AuthBloc authBloc = new AuthBloc();

  String? value_doituong;


  var item_doituong = [
    'Học sinh THPT',
    'Sinh viên',
    'Phụ huynh',
    'Cựu sinh viên',
    'Khác'
  ];

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));

  String departmentName = "";

  getDepartmentName() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('departments')
        .where('id', isEqualTo: widget.employee.department)
        .get()
        .then((value) => {
              setState(() {
                departmentName = value.docs.first["name"];
              })
            });
  }

  @override
  void initState() {
    super.initState();
    getDepartmentName();
    //getDepartmentName();
  }

  TextEditingController _informationController = new TextEditingController();
  TextEditingController _questionController = new TextEditingController();

  StreamController _informationControl = new StreamController.broadcast();
  StreamController _questionControl = new StreamController.broadcast();

  Stream get informationControl => _informationControl.stream;
  Stream get questionControl => _questionControl.stream;

  bool isValid(String information, String question) {
    if (information == null || information.length == 0) {
      _informationControl.sink.addError("Nhập thông tin liên lạc");
      return false;
    }

    if (question == null || question.length == 0) {
      _questionControl.sink.addError("Nhập câu hỏi");
      return false;
    }

    return true;
  }

  void dispose() {
    _questionControl.close();

    _informationControl.close();
    super.dispose();
  }

  void sendQuestion(
      String userId,
      String title,
      String time,
      String status,
      String information,
      String file,
      String department,
      String content,
      String category,
      String people,
      Function onSucces) {
    var ref = FirebaseFirestore.instance.collection('questions');
    String id = ref.doc().id;
    ref.doc(id).set({
      'id': id,
      'userId': userId,
      'title': title,
      'time': time,
      'status': status,
      'information': information,
      'file': file,
      'department': department,
      'content': content,
      'people': people,
      'category': category,
    }).then((value) {
      onSucces();
      print("add nice");
    }).catchError((err) {
      print(err);
    });
  }

  _onSendQuestionClicked() {
    var isvalid =
        isValid(_informationController.text, _questionController.text);
    var time = DateTime.now();
    String timestring = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    print(timestring);

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      sendQuestion(
          widget.users.id,
          "Gửi thầy/cô " + widget.employee.name,
          timestring,
          "Chưa trả lời",
          _informationController.text,
          "file.pdf",
          departmentName,
          _questionController.text,
          widget.employee.category,
          value_doituong!, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MessengerPage()));
      });
    }
    return 0;
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.pinkAccent,
        title: new Text("Thông tin tư vấn viên"),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
              Container(
                height: 150,
                child: Center(
                  child: Stack(
                    children: [
                      new CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.tealAccent,
                        child: CircleAvatar(
                          backgroundImage:
                              new NetworkImage(widget.employee.image!),
                          radius: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
              Text(
                widget.employee.name!,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
              Text(
                widget.employee.roles!,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                width: 400,
                child: TextField(
                  controller: TextEditingController()
                    ..text = widget.employee.email!,
                  decoration: InputDecoration(
                      labelText: "Email",
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 1,
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.pink, width: 4))),
                  readOnly: true,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                width: 400,
                child: TextField(
                  controller: TextEditingController()
                    ..text = widget.employee.phone!,
                  decoration: InputDecoration(
                      labelText: "Số điện thoại",
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 1,
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.pink, width: 4))),
                  readOnly: true,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                width: 400,
                child: TextField(
                  controller: TextEditingController()..text = departmentName,
                  decoration: InputDecoration(
                      labelText: "Khoa",
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 1,
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.pink, width: 4))),
                  readOnly: true,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                width: 400,
                child: TextField(
                  controller: TextEditingController()
                    ..text = widget.employee.category == ""
                        ? "Tất cả lĩnh vực thuộc " + departmentName
                        : widget.employee.category,
                  decoration: InputDecoration(
                      labelText: "Lĩnh vực phụ trách",
                      //hintText: "Tất cả lĩnh vực thuộc" + widget.employee.department!,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 1,
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.pink, width: 4))),
                  readOnly: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.mark_chat_unread),
                    onPressed: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          // constraints: BoxConstraints.loose(Size(
                          //     MediaQuery.of(context).size.width,
                          //     MediaQuery.of(context).size.height * 0.75)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          )),
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder:
                                (BuildContext context,
                                    StateSetter setStateKhoa) {
                              return Container(
                                height: 600,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              0, 10, 0, 20)),
                                      Text(
                                        "Gửi câu hỏi cho tư vấn viên",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),

                                      Container(
                                          margin:
                                              EdgeInsets.fromLTRB(0, 10, 0, 15),
                                          width: 340,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.pinkAccent,
                                                width: 4),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: value_doituong,
                                              hint: new Text(
                                                  "Vui lòng chọn đối tượng"),
                                              iconSize: 36,
                                              items: item_doituong
                                                  .map(buildMenuItem)
                                                  .toList(),
                                              onChanged: (value) {
                                                setStateKhoa(() {
                                                  setState(() {
                                                    this.value_doituong = value;
                                                  });
                                                });
                                              },
                                            ),
                                          )),
                                      Container(
                                          margin:
                                              EdgeInsets.fromLTRB(0, 10, 0, 15),
                                          width: 340,
                                          child: StreamBuilder(
                                            stream: informationControl,
                                            builder: (context, snapshot) =>
                                                TextField(
                                              controller:
                                                  _informationController,
                                              decoration: InputDecoration(
                                                  labelText:
                                                      "Phương thức liên hệ",
                                                  hintText:
                                                      'Nhập Email/SĐT của bạn',
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors
                                                                .pinkAccent,
                                                            width: 1,
                                                          )),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide: BorderSide(
                                                              color:
                                                                  Colors.pink,
                                                              width: 4))),
                                            ),
                                          )),
                                      Container(
                                        width: 340,
                                        margin:
                                            EdgeInsets.fromLTRB(0, 10, 0, 15),
                                        child: StreamBuilder(
                                          stream: questionControl,
                                          builder: (context, snapshot) =>
                                              TextField(
                                            controller: _questionController,
                                            maxLines: 50,
                                            minLines: 7,
                                            maxLength: 3000,
                                            decoration: InputDecoration(
                                                hintMaxLines: 5,
                                                helperMaxLines: 5,
                                                labelText: "Đặt câu hỏi",
                                                hintText:
                                                    'Nhập câu hỏi của bạn',
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                          color:
                                                              Colors.pinkAccent,
                                                          width: 1,
                                                        )),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                            color: Colors.pink,
                                                            width: 4))),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Expanded(
                                              child: ElevatedButton.icon(

                                                onPressed: () {
                                                  _onSendQuestionClicked();
                                                  print('press save');
                                                },
                                                label: Text(
                                                  'Gửi',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                                icon: Icon(Icons.mail_outline_rounded),
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.pinkAccent
                                                ),
                                              ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.all(10)),
                                            Expanded(
                                                child: ElevatedButton.icon(
                                                    onPressed: () => {
                                                          Navigator.pop(context)
                                                        },
                                                    label: Text(
                                                      'Thoát',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                    ),
                                                  icon: Icon(Icons.cancel_presentation),
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.pinkAccent
                                                  ),
                                                )),
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 30)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                          });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.pinkAccent,
                    ),
                    label: Text(
                      "Gửi câu hỏi cho tư vấn viên",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 20)),
            ],
          ),
        ),
      ),
    );
  }
}
