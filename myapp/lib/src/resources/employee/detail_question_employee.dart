import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/resources/employee/home_page_employee.dart';

import '../../../icons/app_icons_icons.dart';
import '../../models/AnswerModel.dart';
import '../../models/EmployeeModel.dart';
import '../../models/QuestionModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';
import '../leader/messenger_leader.dart';
import '../pdf_viewer.dart';
import 'messenger_employee.dart';

class DetailQuestionEmployee extends StatefulWidget {
  _DetailQuestionState createState() => _DetailQuestionState();

  final QuestionModel question;

  DetailQuestionEmployee({required this.question});
}

class Question {
  String id;
  String title;
  String content;
  String time;
  String department;
  String category;
  String status;
  UserModel user;
  String information;
  String file;

  Question(this.id, this.title, this.content, this.time, this.department,
      this.category, this.status, this.user, this.information, this.file);
}

class Answer {
  String id;
  String content;
  String questionId;
  String time;
  EmployeeModel employee;

  Answer(this.id, this.questionId, this.content, this.time, this.employee);
}

UserModel uModel = UserModel("", "", "", "", "", "", "");

class _DetailQuestionState extends State<DetailQuestionEmployee> {
  String? value_khoa;
  String? value_vande;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getDepartmentName();
    getQuestion();
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  var userr = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
  EmployeeModel current_employee =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
  Question question = Question("", "", "", "", "", "", "", uModel, "", "");

  TextEditingController _answerController = new TextEditingController();

  StreamController _answerControl = new StreamController.broadcast();

  Stream get answerControl => _answerControl.stream;
  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: userr.uid)
        .get()
        .then((value) => {
      current_employee.id = value.docs.first['id'],
      current_employee.name = value.docs.first['name'],
      current_employee.email = value.docs.first['email'],
      current_employee.image = value.docs.first['image'],
      current_employee.password = value.docs.first['password'],
      current_employee.phone = value.docs.first['phone'],
      current_employee.department = value.docs.first['department'],
      current_employee.category = value.docs.first['category'],
      current_employee.roles = value.docs.first['roles'],
      current_employee.status = value.docs.first['status']
    });
  }
  bool isValid(String answer) {
    if (answer == null || answer.length == 0) {
      _answerControl.sink.addError("Nhập câu trả lời");
      return false;
    }

    return true;
  }
  List<dynamic> listt = [];
  Future<List> getDataDropdownProblem(String? value_khoa) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("departments")
        .where("name", isEqualTo: value_khoa)
        .get();

    List<dynamic> list = [];
    snapshot.docs.map((e) {
      list = (e.data() as Map)["category"];
      return list;
    }).toList();
    return list;
  }
  List<String> listDepartment = [];
  var departmentName = new Map();
  getDepartmentName() async {
    await FirebaseFirestore.instance
        .collection('departments')
        .get()
        .then((value) => {
      setState(() {
        value.docs.forEach((element) {
          departmentName[element.id] = element["name"];
          listDepartment.add(element['name']);
        });
      })
    });
  }
  getQuestion() async {
    UserModel userModel = new UserModel("", " ", "", "", "", "", "");
    await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: widget.question.userId)
        .get()
        .then((value) => {
      setState(() {
        userModel.id = value.docs.first['userId'];
        userModel.name = value.docs.first['name'];
        userModel.email = value.docs.first['email'];
        userModel.image = value.docs.first['image'];
        userModel.password = value.docs.first['pass'];
        userModel.phone = value.docs.first['phone'];
        userModel.status = value.docs.first['status'];
        question = Question(
          widget.question.id,
          widget.question.title,
          widget.question.content,
          widget.question.time,
          widget.question.department,
          widget.question.category,
          widget.question.status,
          userModel,
          widget.question.information,
          widget.question.file,
        );
      })
    });
    await getAnswerData();
  }

  List<Answer> listAnswer = [];
  getAnswerData() async {
    List<AnswerModel> listans = [];
    await FirebaseFirestore.instance
        .collection('answer')
        .where('questionId', isEqualTo: question.id)
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                AnswerModel ans = new AnswerModel("", "", "", "", "");
                ans.userId = element['userId'];
                ans.id = element['id'];
                ans.questionId = element['questionId'];
                ans.content = element['content'];
                ans.time = element['time'];
                listans.add(ans);
              })
            });
    listans.forEach((element) async {
      EmployeeModel employeeModel =
          new EmployeeModel("", "", "", "", "", "", "", "", "", "");
      Answer ans = Answer(element.id, element.questionId, element.content,
          element.time, employeeModel);
      await FirebaseFirestore.instance
          .collection('employee')
          .where('id', isEqualTo: element.userId)
          .get()
          .then((value) => {
                setState(() {
                  employeeModel.id = value.docs.first['id'];
                  employeeModel.name = value.docs.first['name'];
                  employeeModel.email = value.docs.first['email'];
                  employeeModel.image = value.docs.first['image'];
                  employeeModel.password = value.docs.first['password'];
                  employeeModel.phone = value.docs.first['phone'];
                  employeeModel.department = value.docs.first['department'];
                  employeeModel.category = value.docs.first['category'];
                  employeeModel.roles = value.docs.first['roles'];
                  employeeModel.status = value.docs.first['status'];
                  ans.employee = employeeModel;
                  listAnswer.add(ans);
                })
              });
    });
  }

  _buildQuestion() {
    if (question.id == "" || departmentName.isEmpty) {
      return Center(
        child: Container(
            width: 20,
            height: 20,
            child: CircularProgressIndicator()),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.tealAccent,
          child: CircleAvatar(
            backgroundImage:
            new NetworkImage(question.user.image!),
            radius: 20,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,

          children: <Widget>[
            Container(
              width:
              MediaQuery.of(context).size.width - 75,
              child: Card(
                margin: EdgeInsets.all(5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.grey,
                elevation: 10,
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.start,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: <Widget>[],
                    ),
                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.fromLTRB(
                                5, 5, 5, 5)),
                        Text(
                          '   ' + question.user.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '   Lúc ' + question.time,
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                          style: TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              overflow:
                              TextOverflow.visible),
                        ),
                        Text(
                          '   Gửi: ' +
                              departmentName[question.department],
                          style: TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              overflow:
                              TextOverflow.visible),
                        ),
                      ],
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(
                            5, 5, 5, 5)),
                    Container(
                        padding: EdgeInsets.fromLTRB(
                            10, 0, 5, 5),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                question.content,
                                overflow:
                                TextOverflow.visible,
                                maxLines: 20,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w400),
                              ),
                            )
                          ],
                        ),
                    ),
                    if(widget.question.file!='file.pdf')
                      if(widget.question.file.substring(widget.question.file.length - 57).startsWith('.pdf'))(
                        Column(
                          children: [
                            Row(
                              children: [
                                Text("  "),
                                Icon(AppIcons.file_pdf,
                                color: Color(0xED0565B2)),
                                Text(" File PDF đính kèm",
                                  overflow:
                                  TextOverflow.visible,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                      FontWeight.w400,
                                  color: Color(0xED0565B2)),
                                ),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.fromLTRB(
                                    5, 5, 5, 5)),
                          ],
                        )
                      )
                      else
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(question.file,
                                ),
                          ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _buildAnswers() {
    List<Widget> answerList = [];
    listAnswer.forEach((Answer answer) {
      answerList.add(GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              //mainAxisSize: MainAxisSize.min,

              children: <Widget>[
                Container(
                  //width: MediaQuery.of(context).size.width -75,
                  width: 285,
                  child: Card(
                    margin: EdgeInsets.all(5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.lightBlueAccent,
                    elevation: 10,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
                            Text(
                              '   ' + answer.employee.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '   Lúc ' + answer.time,
                              overflow: TextOverflow.visible,
                              maxLines: 3,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.visible),
                            ),
                          ],
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
                        Container(
                            padding: EdgeInsets.fromLTRB(10, 0, 5, 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    answer.content,
                                    overflow: TextOverflow.visible,
                                    maxLines: 20,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                )
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.tealAccent,
              child: CircleAvatar(
                backgroundImage: new NetworkImage(answer.employee.image!),
                radius: 20,
              ),
            ),
          ],
        ),
      ));
    });
    return Column(children: answerList);
  }

  _modalBottomSheetChange() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.55)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
            return Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                    child: Text(
                      'Chuyển câu hỏi',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0),
                    ),
                  ),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: SingleChildScrollView(
                              child: Container(
                            height: 300,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                                Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                    width: 340,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.orangeAccent, width: 4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: value_khoa,
                                        hint: new Text(
                                            "Vui lòng chọn đơn vị"),
                                        iconSize: 36,
                                        items: render(listDepartment),
                                        onChanged: (value) async {
                                          final List<dynamic> list_problem =
                                          await getDataDropdownProblem(
                                              value) as List;
                                          setStateKhoa(() {
                                            setState(() {
                                              this.value_vande = null;
                                              this.value_khoa = value;
                                              this.listt = list_problem;
                                            });
                                          });
                                        },
                                      ),
                                    )),
                                Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                    width: 340,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.orangeAccent, width: 4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: value_vande,
                                        hint: new Text(
                                            "Vui lòng chọn vấn đề"),
                                        iconSize: 36,
                                        items: renderr(listt),
                                        onChanged: (value) {
                                          setStateKhoa(() {
                                            setState(() {
                                              this.value_vande = value;
                                            });
                                          });
                                        },
                                      ),
                                    )),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _onChangeQuestionClicked(question.id);
                                            print('press save');
                                          },
                                          label: Text(
                                            'Lưu',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                          icon: Icon(Icons.save_outlined),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.all(10)),
                                      Expanded(
                                          child: ElevatedButton.icon(
                                              onPressed: () =>
                                                  {Navigator.pop(context)},
                                              label: Text(
                                                'Thoát',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                            icon: Icon(Icons.cancel_presentation),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                                          )),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              0, 10, 0, 30)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }
  List<DropdownMenuItem<String>> render(List<String> list) {
    return list.map(buildMenuItem).toList();
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
  DropdownMenuItem<dynamic> buildMenuItemm(dynamic item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
  List<DropdownMenuItem<dynamic>> renderr(List<dynamic> list) {
    return list.map(buildMenuItemm).toList();
  }
  _modalBottomSheetAddAnswer() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.65)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
                return Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                        child: Text(
                          'Trả lời câu hỏi',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0),
                        ),
                      ),
                      SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: MediaQuery.of(context).size.height * 0.55,
                              child: SingleChildScrollView(
                                  child: Container(
                                    height: 600,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                                        Container(
                                          margin: EdgeInsets.fromLTRB(10, 10, 10, 15),
                                          child: StreamBuilder(
                                            stream: answerControl,
                                            builder: (context, snapshot) => TextField(
                                              controller: _answerController,
                                              maxLines: 7,
                                              maxLength: 500,
                                              decoration: InputDecoration(
                                                  hintMaxLines: 5,
                                                  helperMaxLines: 5,
                                                  labelText: "Trả lời câu hỏi",
                                                  hintText: 'Nhập nội dung câu trả lời',
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      borderSide: BorderSide(
                                                        color: Colors.blueAccent,
                                                        width: 1,
                                                      )),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      borderSide: BorderSide(
                                                          color: Colors.blue,
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
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _onSendAnswerClicked();
                                                    print('press save');
                                                  },
                                                  child: Text(
                                                    'Gửi',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Padding(padding: EdgeInsets.all(10)),
                                              Expanded(
                                                  child: ElevatedButton(
                                                      onPressed: () =>
                                                      {Navigator.pop(context)},
                                                      child: Text(
                                                        'Thoát',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white),
                                                      ))),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 10, 0, 30)),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }
  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
  );
  Widget _getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22),
      backgroundColor: Colors.orange,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // FAB 1
        SpeedDialChild(
            child: Icon(Icons.send),
            backgroundColor: Colors.orange,
            onTap: () {
              _modalBottomSheetAddAnswer();
            },
            label: 'Gửi câu trả lời',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.orangeAccent),
        // FAB 2
        if(widget.question.file!='file.pdf')
          if(widget.question.file.substring(widget.question.file.length - 57).startsWith('.pdf'))
            SpeedDialChild(
                child: Icon(AppIcons.file_pdf),
                backgroundColor: Colors.orange,
                onTap: () async {
                  final url =
                      widget.question.file;
                  final file = await PDFApi.loadNetwork(url);
                  openPDF(context, file);
                },
                label: 'Mở file PDF',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 16.0),
                labelBackgroundColor: Colors.orangeAccent),

        SpeedDialChild(
            child: Icon(Icons.published_with_changes),
            backgroundColor: Colors.orange,
            onTap: () {
              _modalBottomSheetChange();
            },
            label: 'Chuyển câu hỏi',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.orangeAccent),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                      new MessengerPageEmployee()));

            }
        ),
        title: const Text("Chi tiết câu hỏi"),
        backgroundColor: Colors.orangeAccent,
      ),
      floatingActionButton:_getFAB(),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.875,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                          _buildQuestion(),
                          Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[_buildAnswers()],
                          ),
                          Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  _onChangeQuestionClicked(id) {

    LoadingDialog.showLoadingDialog(context, "Loading...");
    changeQuestion(id,value_khoa!,value_vande!,() {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MessengerPageEmployee()));
      });
  }
  void changeQuestion(id,department, category,Function onSuccess) {
    var ref = FirebaseFirestore.instance.collection('questions');
    String departmentId = departmentName.keys
        .firstWhere((k) => departmentName[k] == department, orElse: () => null);
    ref.doc(id).update({
      'department': departmentId,
      'category': category,
    }).then((value) {
      onSuccess();
      print("update successful");
    }).catchError((err){
      //TODO
      print("err");
      print(err);
    });
  }
  _onSendAnswerClicked() {
    var isvalid = isValid(_answerController.text);
    var time = DateTime.now();
    String timestring = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    print(timestring);

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "Loading...");
      sendAnswer(
          userr.uid, _answerController.text, timestring, question.id,
          () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DetailQuestionEmployee(question: widget.question)));
      });
    }
    return 0;
  }

  void sendAnswer(String userId, String content, String time, String questionId,
      Function onSuccess) {
    var ref = FirebaseFirestore.instance.collection('answer');
    String id = ref.doc().id;
    ref.doc(id).set({
      'id': id,
      'userId': userId,
      'time': time,
      'content': content,
      'questionId': questionId,
    }).then((value) {
      updateQuestionStatus(questionId);
      onSuccess();
      print("add nice");
    }).catchError((err) {
      print(err);
    });
  }

  void updateQuestionStatus(String questionId) {
    var ref = FirebaseFirestore.instance.collection('questions');

    ref.doc(questionId).update({'status': "Đã trả lời"}).then((value) {
      print("add user");
    }).catchError((err) {
      //TODO
      print("err");
    });
  }
}
