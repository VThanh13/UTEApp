import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/AnswerModel.dart';
import '../../models/EmployeeModel.dart';
import '../../models/QuestionModel.dart';
import '../../models/UserModel.dart';

class DetailQuestion extends StatefulWidget {
  _DetailQuestionState createState() => _DetailQuestionState();

  final QuestionModel question;

  DetailQuestion({required this.question});
}

class Answer {
  String id;
  String content;
  String questionId;
  String time;
  EmployeeModel employee;

  Answer(this.id, this.questionId, this.content, this.time, this.employee);
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

UserModel uModel = new UserModel("", " ", "", "", "", "", "");

class _DetailQuestionState extends State<DetailQuestion> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    getDepartmentName();
    getQuestion();
    super.initState();
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  var userr = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel =
      new EmployeeModel("", " ", "", "", "", "", "", "", "", "");

  Question question = new Question("", "", "", "", "", "", "", uModel, "", "");
  List<Answer> listAnswer = [];

  var departmentName = new Map();
  getDepartmentName() async {
    await FirebaseFirestore.instance
        .collection('departments')
        .get()
        .then((value) => {
      setState(() {
        value.docs.forEach((element) {
          departmentName[element.id] = element["name"];
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
                        )),
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        title: const Text("Chi tiết câu hỏi"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //Text("chi tiet cau hoi"),
              //Text(widget.question.title),
              Column(
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

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
