import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/resources/employee/home_page_employee.dart';

import '../../models/AnswerModel.dart';
import '../../models/EmployeeModel.dart';
import '../../models/QuestionModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';

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
  @override
  void dispose() {
    super.dispose();
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  var userr = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
  //UserModel uModel = UserModel("", "", "", "", "", "", "");
  Question question = Question("", "", "", "", "", "", "", uModel, "", "");

  TextEditingController _answerController = new TextEditingController();

  StreamController _answerControl = new StreamController.broadcast();

  Stream get answerControl => _answerControl.stream;

  bool isValid(String answer) {
    if (answer == null || answer.length == 0) {
      _answerControl.sink.addError("Nhập câu trả lời");
    }

    return true;
  }

  List<Answer> listAnswer = [];
  Future<List<Answer>> getAnswerData() async {
    List<AnswerModel> list = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('answer')
        .where('questionId', isEqualTo: question.id)
        .get();
    snapshot.docs.map((e) {
      AnswerModel ans = new AnswerModel("", "", "", "", "");
      ans.userId = (e.data() as Map)['userId'];
      ans.id = e.reference.id;
      ans.questionId = (e.data() as Map)['questionId'];
      ans.content = (e.data() as Map)['content'];
      ans.time = (e.data() as Map)['time'];
      list.add(ans);
    }).toList();
    List<Answer> listAns = [];
    // print(listUser);
    for (var i = 0; i < list.length; i++) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('employee')
          .where('id', isEqualTo: list[i].userId)
          .get();
      snapshot.docs.map((e) {
        EmployeeModel employeeModel =
            new EmployeeModel("", "", "", "", "", "", "", "", "", "");
        Answer ans = Answer(list[i].id, list[i].questionId, list[i].content,
            list[i].time, employeeModel);
        employeeModel.id = (e.data() as Map)['id'];
        employeeModel.name = (e.data() as Map)['name'];
        employeeModel.email = (e.data() as Map)['email'];
        employeeModel.image = (e.data() as Map)['image'];
        employeeModel.password = (e.data() as Map)['password'];
        employeeModel.phone = (e.data() as Map)['phone'];
        employeeModel.department = (e.data() as Map)['department'];
        employeeModel.category = (e.data() as Map)['category'];
        employeeModel.roles = (e.data() as Map)['roles'];
        employeeModel.status = (e.data() as Map)['status'];
        ans.employee = employeeModel;
        listAns.add(ans);
      }).toList();
    }
    return listAns;
  }

  fillListQuestion(setState) async {
    final listAnswers = await getAnswerData() as List<Answer>;
    setState(() {
      listAnswer = listAnswers;
    });
  }

  _buildAnswers(setState) {
    fillListQuestion(setState);

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
  _modalBottomSheetAddAnswer(){
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height *
                0.65)),
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
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        5, 20, 5, 10),
                    child: Text(
                      'Trả lời câu hỏi',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                          FontWeight.w600,
                          letterSpacing: 1.0),
                    ),
                  ),
                  SingleChildScrollView(
                    physics:
                    BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(
                              context)
                              .size
                              .height *
                              0.55,
                          child:
                          SingleChildScrollView(
                              child:
                              Container(
                                height: 600,
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .start,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets
                                            .fromLTRB(
                                            0,
                                            10,
                                            0,
                                            10)),
                                    Container(
                                      margin: EdgeInsets
                                          .fromLTRB(
                                          10,
                                          10,
                                          10,
                                          15),
                                      child:
                                      StreamBuilder(
                                        stream:
                                        answerControl,
                                        builder: (context,
                                            snapshot) =>
                                            TextField(
                                              controller:
                                              _answerController,
                                              maxLines: 7,
                                              maxLength:
                                              500,
                                              decoration: InputDecoration(
                                                  hintMaxLines: 5,
                                                  helperMaxLines: 5,
                                                  labelText: "Trả lời câu hỏi",
                                                  hintText: 'Nhập nội dung câu trả lời',
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: BorderSide(
                                                        color: Colors.blueAccent,
                                                        width: 1,
                                                      )),
                                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue, width: 4))),
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding:
                                      EdgeInsets
                                          .all(
                                          10),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceAround,
                                        children: <
                                            Widget>[
                                          Expanded(
                                            child:
                                            ElevatedButton(
                                              onPressed:
                                                  () {
                                                _onSendAnswerClicked();
                                                print(
                                                    'press save');
                                              },
                                              child:
                                              Text(
                                                'Gửi',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                              padding:
                                              EdgeInsets.all(10)),
                                          Expanded(
                                              child:
                                              ElevatedButton(
                                                  onPressed: () => {
                                                    Navigator.pop(context)
                                                  },
                                                  child: Text(
                                                    'Thoát',
                                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                                  ))),
                                          Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0,
                                                  10,
                                                  0,
                                                  30)),
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("user")
            .where("userId", isEqualTo: widget.question.userId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Container(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }
          snapshot.data!.docs.map((e) {
            UserModel userModel = new UserModel("", " ", "", "", "", "", "");
            userModel.id = (e.data() as Map)['userId'];
            userModel.name = (e.data() as Map)['name'];
            userModel.email = (e.data() as Map)['email'];
            userModel.image = (e.data() as Map)['image'];
            userModel.password = (e.data() as Map)['pass'];
            userModel.phone = (e.data() as Map)['phone'];
            userModel.status = (e.data() as Map)['status'];

            question = new Question(
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
            return question;
          }).toString();

          return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("employee")
                  .where("id", isEqualTo: userr.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Container(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator()),
                  );
                }
                snapshot.data!.docs.map((e) {
                  employeeModel.id = (e.data() as Map)['id'];
                  employeeModel.name = (e.data() as Map)['name'];
                  employeeModel.email = (e.data() as Map)['email'];
                  employeeModel.image = (e.data() as Map)['image'];
                  employeeModel.password = (e.data() as Map)['password'];
                  employeeModel.phone = (e.data() as Map)['phone'];
                  employeeModel.department = (e.data() as Map)['department'];
                  employeeModel.category = (e.data() as Map)['category'];
                  employeeModel.roles = (e.data() as Map)['roles'];
                  employeeModel.status = (e.data() as Map)['status'];

                  return employeeModel;
                }).toString();

                return Scaffold(
                  appBar: new AppBar(
                    title: const Text("Chi tiết câu hỏi"),
                  ),
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
                      height: MediaQuery.of(context).size.height * 0.75,
                    child: SingleChildScrollView(
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.tealAccent,
                                    child: CircleAvatar(
                                      backgroundImage: new NetworkImage(
                                          question.user.image!),
                                      radius: 20,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    //mainAxisSize: MainAxisSize.min,

                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                75,
                                        child: Card(
                                          margin: EdgeInsets.all(5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              5, 5, 5, 5)),
                                                  Text(
                                                    '   ' + question.user.name,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    '   Lúc ' + question.time,
                                                    overflow:
                                                        TextOverflow.visible,
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        overflow: TextOverflow
                                                            .visible),
                                                  ),
                                                  Text(
                                                    '   Gửi: ' +
                                                        question.department,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        overflow: TextOverflow
                                                            .visible),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                          question.content,
                                                          overflow: TextOverflow
                                                              .visible,
                                                          maxLines: 20,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
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
                                ],
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[_buildAnswers(setState)],
                              ),
                            ],
                          ),
                    ),
                      ),
                        ],
                      ),
                    ),
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                  0,
                                  10,
                                  0,
                                  10),
                              alignment: Alignment.bottomRight,
                              child: SizedBox.fromSize(
                                size: Size(56, 56), // button width and height
                                child: ClipOval(
                                  child: Material(
                                    color: Colors.blue, // button color
                                    child: InkWell(
                                      splashColor: Colors.green, // splash color
                                      onTap: () {
                                        return _modalBottomSheetAddAnswer();
                                      }, // button pressed
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.send), // text
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                      ),
                  ),
                );
              });
        });
  }

  _onSendAnswerClicked() {
    var isvalid = isValid(_answerController.text);
    var time = DateTime.now();
    String timestring = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    print(timestring);

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      sendAnswer(
          employeeModel.id, _answerController.text, timestring, question.id,
          () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomePageEmployee()));
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
