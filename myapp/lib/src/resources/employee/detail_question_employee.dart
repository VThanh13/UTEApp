import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../icons/app_icons_icons.dart';
import '../../models/AnswerModel.dart';
import '../../models/EmployeeModel.dart';
import '../../models/QuestionModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';
import '../pdf_viewer.dart';
import 'messenger_employee.dart';

class DetailQuestionEmployee extends StatefulWidget {
  @override
  State<DetailQuestionEmployee> createState() => _DetailQuestionState();

  final QuestionModel question;

  const DetailQuestionEmployee({super.key, required this.question});
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

UserModel uModel = UserModel("", "", "", "", "", "", "", "");

class _DetailQuestionState extends State<DetailQuestionEmployee> {
  String? valueKhoa;
  String? valueVanDe;
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
  var userR = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
  EmployeeModel currentEmployee =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
  Question question = Question("", "", "", "", "", "", "", uModel, "", "");

  final TextEditingController _answerController = TextEditingController();

  final StreamController _answerControl = StreamController.broadcast();

  Stream get answerControl => _answerControl.stream;
  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: userR.uid)
        .get()
        .then((value) => {
              currentEmployee.id = value.docs.first['id'],
              currentEmployee.name = value.docs.first['name'],
              currentEmployee.email = value.docs.first['email'],
              currentEmployee.image = value.docs.first['image'],
              currentEmployee.password = value.docs.first['password'],
              currentEmployee.phone = value.docs.first['phone'],
              currentEmployee.department = value.docs.first['department'],
              currentEmployee.category = value.docs.first['category'],
              currentEmployee.roles = value.docs.first['roles'],
              currentEmployee.status = value.docs.first['status']
            });
  }

  bool isValid(String answer) {
    if (answer.isEmpty) {
      _answerControl.sink.addError("Nhập câu trả lời");
      return false;
    }

    return true;
  }

  List<dynamic> listT = [];
  Future<List> getDataDropdownProblem(String? valueKhoa) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("departments")
        .where("name", isEqualTo: valueKhoa)
        .get();

    List<dynamic> list = [];
    snapshot.docs.map((e) {
      list = (e.data() as Map)["category"];
      return list;
    }).toList();
    return list;
  }

  List<String> listDepartment = [];
  var departmentName = {};
  getDepartmentName() async {
    await FirebaseFirestore.instance
        .collection('departments')
        .get()
        .then((value) => {
              setState(() {
                for (var element in value.docs) {
                  departmentName[element.id] = element["name"];
                  listDepartment.add(element['name']);
                }
              })
            });
  }

  getQuestion() async {
    // UserModel userModel = new UserModel("", " ", "", "", "", "", "");
    // await FirebaseFirestore.instance
    //     .collection('user')
    //     .where('userId', isEqualTo: widget.question.userId)
    //     .get()
    //     .then((value) => {
    //   setState(() {
    //     userModel.id = value.docs.first['userId'];
    //     userModel.name = value.docs.first['name'];
    //     userModel.email = value.docs.first['email'];
    //     userModel.image = value.docs.first['image'];
    //     userModel.password = value.docs.first['pass'];
    //     userModel.phone = value.docs.first['phone'];
    //     userModel.status = value.docs.first['status'];
    //     question = Question(
    //       widget.question.id,
    //       widget.question.title,
    //       widget.question.content,
    //       widget.question.time,
    //       widget.question.department,
    //       widget.question.category,
    //       widget.question.status,
    //       userModel,
    //       widget.question.information,
    //       widget.question.file,
    //     );
    //   })
    // });
    // await getAnswerData();
  }

  List<Answer> listAnswer = [];
  getAnswerData() async {
    List<AnswerModel> listAns = [];
    // await FirebaseFirestore.instance
    //     .collection('answer')
    //     .where('room_id', isEqualTo: widget.chat_room.id)
    //     .get()
    //     .then((value) => {
    //   value.docs.forEach((element) {
    //     AnswerModel ans = new AnswerModel("", "", "", "", "");
    //     ans.employee_id = element['employee_id'];
    //     ans.id = element['id'];
    //     ans.room_id = element['room_id'];
    //     ans.content = element['content'];
    //     ans.time = element['time'];
    //     listans.add(ans);
    //   })
    // });
    listAns.forEach((element) async {
      EmployeeModel employeeModel =
          EmployeeModel("", "", "", "", "", "", "", "", "", "");
      Answer ans = Answer(element.id, element.room_id, element.content,
          element.time, employeeModel);
      await FirebaseFirestore.instance
          .collection('employee')
          .where('id', isEqualTo: element.employee_id)
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
      return const Center(
        child:
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
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
            backgroundImage: NetworkImage(question.user.image!),
            radius: 20,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,

          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width - 75,
              child: Card(
                margin: const EdgeInsets.all(5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.grey,
                elevation: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
                        Text(
                          '   ${question.user.name}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '   Lúc ${question.time}',
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                          style: const TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.visible),
                        ),
                        Text(
                          '   Gửi: ' + departmentName[question.department],
                          style: const TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.visible),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 5, 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              question.content,
                              overflow: TextOverflow.visible,
                              maxLines: 20,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                      ),
                    ),
                    if (widget.question.file != 'file.pdf')
                      if (widget.question.file
                          .substring(widget.question.file.length - 57)
                          .startsWith('.pdf'))
                        (Column(
                          children: [
                            Row(
                              children: const [
                                Text("  "),
                                Icon(AppIcons.file_pdf,
                                    color: Color(0xED0565B2)),
                                Text(
                                  " File PDF đính kèm",
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xED0565B2)),
                                ),
                              ],
                            ),
                            const Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
                          ],
                        ))
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            question.file,
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
    listAnswer.sort((a, b) => DateFormat("dd-MM-yyyy HH:mm:ss")
        .parse(a.time)
        .compareTo(DateFormat("dd-MM-yyyy HH:mm:ss").parse(b.time)));
    for (var answer in listAnswer) {
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
                SizedBox(
                  //width: MediaQuery.of(context).size.width -75,
                  width: 285,
                  child: Card(
                    margin: const EdgeInsets.all(5),
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
                          children: const <Widget>[],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
                            Text(
                              '   ${answer.employee.name}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '   Lúc ${answer.time}',
                              overflow: TextOverflow.visible,
                              maxLines: 3,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.visible),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
                        Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 5, 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    answer.content,
                                    overflow: TextOverflow.visible,
                                    maxLines: 20,
                                    style: const TextStyle(
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
                backgroundImage: NetworkImage(answer.employee.image!),
                radius: 20,
              ),
            ),
          ],
        ),
      ));
    }
    return Column(children: answerList);
  }

  _modalBottomSheetChange() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.55)),
        shape: const RoundedRectangleBorder(
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
                  const Padding(
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
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: SingleChildScrollView(
                              child: SizedBox(
                            height: 300,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                                Container(
                                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                    width: 340,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.orangeAccent, width: 4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: valueKhoa,
                                        hint: const Text("Vui lòng chọn đơn vị"),
                                        iconSize: 36,
                                        items: render(listDepartment),
                                        onChanged: (value) async {
                                          final List<dynamic> listProblem =
                                              await getDataDropdownProblem(
                                                  value);
                                          setStateKhoa(() {
                                            setState(() {
                                              valueVanDe = null;
                                              valueKhoa = value;
                                              listT = listProblem;
                                            });
                                          });
                                        },
                                      ),
                                    )),
                                Container(
                                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                    width: 340,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.orangeAccent, width: 4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: valueVanDe,
                                        hint: const Text("Vui lòng chọn vấn đề"),
                                        iconSize: 36,
                                        items: renderR(listT),
                                        onChanged: (value) {
                                          setStateKhoa(() {
                                            setState(() {
                                              valueVanDe = value;
                                            });
                                          });
                                        },
                                      ),
                                    )),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _onChangeQuestionClicked(
                                                question.id);
                                          },
                                          label: const Text(
                                            'Lưu',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                          icon: const Icon(Icons.save_outlined),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.orangeAccent),
                                        ),
                                      ),
                                      const Padding(padding: EdgeInsets.all(10)),
                                      Expanded(
                                          child: ElevatedButton.icon(
                                        onPressed: () =>
                                            {Navigator.pop(context)},
                                        label: const Text(
                                          'Thoát',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.cancel_presentation),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.orangeAccent),
                                      )),
                                      const Padding(
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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
  DropdownMenuItem<dynamic> buildMenuItemM(dynamic item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
  List<DropdownMenuItem<dynamic>> renderR(List<dynamic> list) {
    return list.map(buildMenuItemM).toList();
  }

  _modalBottomSheetAddAnswer() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.65)),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
            return Column(
              children: <Widget>[
                const Padding(
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
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: SingleChildScrollView(
                            child: SizedBox(
                          height: 600,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),),
                              Container(
                                margin: const EdgeInsets.fromLTRB(10, 10, 10, 15),
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
                                            borderSide: const BorderSide(
                                              color: Colors.orangeAccent,
                                              width: 1,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Colors.orange,
                                                width: 4))),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          _onSendAnswerClicked();
                                          print('press save');
                                        },
                                        label: const Text(
                                          'Gửi',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.send),
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.orangeAccent),
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.all(10)),
                                    Expanded(
                                        child: ElevatedButton.icon(
                                      onPressed: () =>
                                          {Navigator.pop(context)},
                                      label: const Text(
                                        'Hủy',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                      icon: const Icon(Icons.cancel_presentation),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.orangeAccent),
                                    )),
                                    const Padding(
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
      animatedIconTheme: const IconThemeData(size: 22),
      backgroundColor: Colors.orange,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // FAB 1
        SpeedDialChild(
            child: const Icon(Icons.send),
            backgroundColor: Colors.orange,
            onTap: () {
              _modalBottomSheetAddAnswer();
            },
            label: 'Gửi câu trả lời',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.orangeAccent),
        // FAB 2
        if (widget.question.file != 'file.pdf')
          if (widget.question.file
              .substring(widget.question.file.length - 57)
              .startsWith('.pdf'))
            SpeedDialChild(
                child: const Icon(AppIcons.file_pdf),
                backgroundColor: Colors.orange,
                onTap: () async {
                  final url = widget.question.file;
                  final file = await PDFApi.loadNetwork(url);
                  openPDF(context, file);
                },
                label: 'Mở file PDF',
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 16.0),
                labelBackgroundColor: Colors.orangeAccent),

        SpeedDialChild(
            child: const Icon(Icons.published_with_changes),
            backgroundColor: Colors.orange,
            onTap: () {
              _modalBottomSheetChange();
            },
            label: 'Chuyển câu hỏi',
            labelStyle: const TextStyle(
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
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          MessengerPageEmployee()));
            }),
        title: const Text("Chi tiết câu hỏi"),
        backgroundColor: Colors.orangeAccent,
      ),
      floatingActionButton: _getFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.875,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                          _buildQuestion(),
                          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[_buildAnswers()],
                          ),
                          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10))
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
    changeQuestion(id, valueKhoa!, valueVanDe!, () {
      LoadingDialog.hideLoadingDialog(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MessengerPageEmployee()));
    });
  }

  void changeQuestion(id, department, category, Function onSuccess) {
    var ref = FirebaseFirestore.instance.collection('questions');
    String departmentId = departmentName.keys
        .firstWhere((k) => departmentName[k] == department, orElse: () => null);
    ref.doc(id).update({
      'department': departmentId,
      'category': category,
    }).then((value) {
      onSuccess();
    }).catchError((err) {
      //TODO

    });
  }

  _onSendAnswerClicked() {
    var isvalid = isValid(_answerController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "Loading...");
      sendAnswer(userR.uid, _answerController.text, timeString, question.id,
          () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DetailQuestionEmployee(question: widget.question)));
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
    }).catchError((err) {
    });
  }

  void updateQuestionStatus(String questionId) {
    var ref = FirebaseFirestore.instance.collection('questions');

    ref.doc(questionId).update({'status': "Đã trả lời"}).then((value) {
    }).catchError((err) {
      //TODO
    });
  }
}
