import 'dart:async';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/models/QuestionModel.dart';
import 'package:myapp/src/resources/home_page.dart';
import 'package:myapp/src/resources/messenger/detail_question.dart';

import '../../models/EmployeeModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';
import 'detail_question_employee.dart';

class MessengerPageEmployee extends StatefulWidget {
  @override
  _MessengerPageState createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPageEmployee> {
  CollectionReference derpart =
      FirebaseFirestore.instance.collection('departments');
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? value_khoa;
  var selectedDerpartments;
  var departmentsItems = [];

  List<dynamic> listt = [];

  FirebaseAuth auth = FirebaseAuth.instance;
  var user_auth = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel =
      new EmployeeModel("", " ", "", "", "", "", "", "", "", "");
  EmployeeModel current_employee =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getAllQuestion();
  }

  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: user_auth.uid)
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
    await getQuestionData();
  }

  List<QuestionModel> listQuestion = [];
  getQuestionData() async {
    if (current_employee.roles == 'Tư vấn viên') {
      await FirebaseFirestore.instance
          .collection('questions')
          .where('category', isEqualTo: current_employee.category)
          .get()
          .then((value) => {
                setState(() {
                  value.docs.forEach((element) {
                    QuestionModel questionModel = new QuestionModel(
                        "", "", "", "", "", "", "", "", "", "");
                    questionModel.id = element.id;
                    questionModel.title = element['title'];
                    questionModel.content = element['content'];
                    questionModel.time = element['time'];
                    questionModel.department = element['department'];
                    questionModel.category = element['category'];
                    questionModel.status = element['status'];
                    questionModel.userId = element['userId'];
                    questionModel.information = element['information'];
                    questionModel.file = element['file'];

                    listQuestion.add(questionModel);
                  });
                })
              });
    } else {
      await FirebaseFirestore.instance
          .collection('questions')
          .where('department', isEqualTo: current_employee.department)
          .get()
          .then((value) => {
                setState(() {
                  value.docs.forEach((element) {
                    QuestionModel questionModel = new QuestionModel(
                        "", "", "", "", "", "", "", "", "", "");
                    questionModel.id = element.id;
                    questionModel.title = element['title'];
                    questionModel.content = element['content'];
                    questionModel.time = element['time'];
                    questionModel.department = element['department'];
                    questionModel.category = element['category'];
                    questionModel.status = element['status'];
                    questionModel.userId = element['userId'];
                    questionModel.information = element['information'];
                    questionModel.file = element['file'];

                    listQuestion.add(questionModel);
                  });
                })
              });
    }
  }

  _buildQuestions() {
    List<Widget> questionsList = [];
    listQuestion.forEach((QuestionModel question) {
      questionsList.add(GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      DetailQuestionEmployee(question: question)));
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                width: 1.0,
                color: Colors.grey,
              )),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                margin: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      question.title,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      question.time,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      question.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: question.status == "Chưa trả lời"
                            ? Colors.redAccent
                            : Colors.green,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ))
            ],
          ),
        ),
      ));
    });
    return Column(children: questionsList);
  }

  TextEditingController _informationController = new TextEditingController();
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _questionController = new TextEditingController();

  StreamController _informationControl = new StreamController();
  StreamController _titleControl = new StreamController();
  StreamController _questionControl = new StreamController();

  Stream get informationControl => _informationControl.stream;
  Stream get titleControl => _titleControl.stream;
  Stream get questionControl => _questionControl.stream;

  bool isValid(String information, String title, String question) {
    if (information == null || information.length == 0) {
      _informationControl.sink.addError("Nhập thông tin liên lạc");
      return false;
    }

    if (title == null || title.length == 0) {
      _titleControl.sink.addError("Nhập tiêu đề");
    }
    if (question == null || question.length == 0) {
      _questionControl.sink.addError("Nhập câu hỏi");
    }

    return true;
  }

  void dispose() {
    _questionControl.close();
    _titleControl.close();
    _informationControl.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("departments").get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Container(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }
          List<String> list = [];
          snapshot.data!.docs.map((e) {
            String name = (e.data() as Map)["name"];
            list.add(name);
            return list;
          }).toList();

          // TODO: implement build
          return Scaffold(
            appBar: new AppBar(
              title: const Text("Tin nhắn"),
              backgroundColor: Colors.orangeAccent,
            ),
            bottomNavigationBar: getFooter(),
            body: SafeArea(
              minimum: const EdgeInsets.only(left: 20, right: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Padding(
                    //   padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                    //   child: SizedBox(
                    //     width: double.infinity,
                    //     height: 70,
                    //     child: ElevatedButton(
                    //       onPressed: () {},
                    //       style: ElevatedButton.styleFrom(
                    //           primary: Colors.white70,
                    //           shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(12))),
                    //       child: Text(
                    //         "Trả lời câu hỏi",
                    //         style:
                    //             TextStyle(color: Colors.black54, fontSize: 15),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: derpart.snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasError) {
                            Text("Loading");
                          } else {
                            derpart.get().then((QuerySnapshot querySnapshot) {
                              querySnapshot.docs.forEach((doc) {
                                print(doc["departments"]);
                              });
                            });
                          }
                          return Text("");
                        }),

                    getQuestion(),
                  ],
                ),
              ),
            ),
          );
        });
  }
  List<QuestionModel> listAllQuestion = [];
  getAllQuestion() async {
    await FirebaseFirestore.instance
        .collection('questions')
        .get()
        .then((value) => {
      setState(() {
        value.docs.forEach((element) {
          QuestionModel questionModel =
          new QuestionModel("", "", "", "", "", "", "", "", "", "");
          questionModel.id = element.id;
          questionModel.title = element['title'];
          questionModel.content = element['content'];
          questionModel.time = element['time'];
          questionModel.department = element['department'];
          questionModel.category = element['category'];
          questionModel.status = element['status'];
          questionModel.userId = element['userId'];
          questionModel.information = element['information'];
          questionModel.file = element['file'];
          listAllQuestion.add(questionModel);
        });
      })
    });
  }
  _buildAllQuestions() {
    List<Widget> questionsList = [];
    listAllQuestion.forEach((QuestionModel question) {
      questionsList.add(GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      DetailQuestion(question: question)));
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                width: 1.0,
                color: Colors.grey,
              )),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                    margin: EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          question.title,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          question.time,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(question.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: question.status == "Chưa trả lời"
                                  ? Colors.redAccent
                                  : Colors.green,
                              overflow: TextOverflow.ellipsis,
                            ))
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ));
    });
    return Column(children: questionsList);
  }
  Widget getQuestion() {
    if (pageIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Câu hỏi của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0),
            ),
          ),
          _buildQuestions()
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Tất cả câu hỏi',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0),
            ),
          ),
          _buildAllQuestions()
        ],
      );
    }
  }
  int pageIndex = 0;
  Widget getFooter() {
    List<IconData> iconItems = [
      Icons.message,
      Icons.question_answer_outlined,
    ];
    return AnimatedBottomNavigationBar(
      activeColor: Colors.blue,
      splashColor: Colors.grey,
      inactiveColor: Colors.black.withOpacity(0.5),
      icons: iconItems,
      activeIndex: pageIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 10,
      iconSize: 25,
      rightCornerRadius: 10,
      onTap: (index) {
        selectedTab(index);
      },
      //other params
    );
  }
  selectedTab(index) {
    setState(() {
      pageIndex = index;
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
}
