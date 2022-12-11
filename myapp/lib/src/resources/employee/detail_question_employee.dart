import 'dart:async';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/resources/employee/home_page_employee.dart';

import '../../models/EmployeeModel.dart';
import '../../models/QuestionModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';

class DetailQuestionEmployee extends StatefulWidget {
  _DetailQuestionState createState() => _DetailQuestionState();

  final QuestionModel question;

  DetailQuestionEmployee({required this.question});
}

class Question{
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

EmployeeModel employeeModel = new EmployeeModel("", " ", "", "", "", "", "", "", "");
UserModel uModel = new UserModel("", " ", "", "", "", "");
Question question = new Question("", "", "", "", "", "", "", uModel, "", "");

TextEditingController _answerController = new TextEditingController();

StreamController _answerControl = new StreamController();

Stream get answerControl => _answerControl.stream;

bool isValid(String answer){

  if(answer == null || answer.length == 0){
    _answerControl.sink.addError("Nhập câu trả lời");
  }

  return true;
}

class _DetailQuestionState extends State<DetailQuestionEmployee> {

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
            UserModel userModel = new UserModel("", " ", "", "", "", "");
            userModel.id = (e.data() as Map)['userId'];
            userModel.name = (e.data() as Map)['name'];
            userModel.email = (e.data() as Map)['email'];
            userModel.image = (e.data() as Map)['image'];
            userModel.password = (e.data() as Map)['pass'];
            userModel.phone = (e.data() as Map)['phone'];

            question = new Question(widget.question.id, widget.question.title, widget.question.content,
              widget.question.time, widget.question.department, widget.question.category, widget.question.status,
              userModel, widget.question.information, widget.question.file,);
            return question;
          }).toString();
          return Scaffold(
            appBar: new AppBar(
              title: const Text("Chi tiết câu hỏi"),
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
                        Row(
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
                                  width: MediaQuery.of(context).size.width -75,
                                  child:Card(
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
                                          children: <Widget>[

                                          ],

                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,

                                          children: <Widget>[
                                            Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),

                                            Text(question.user.name,
                                              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, ),),

                                            Text(' lúc ', style: TextStyle(fontSize: 15),),
                                            Expanded(child:Text(
                                              question.time,
                                              overflow: TextOverflow.visible,
                                              maxLines: 3,
                                              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, overflow: TextOverflow.visible),)
                                            ),




                                          ],
                                        ),


                                    Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(padding: EdgeInsets.all(5)),

                                            Text('Gửi: ', style: TextStyle(fontSize: 15),),
                                            Expanded(child:Text(question.department, style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, overflow: TextOverflow.visible),)
                                            ),

                                          ],
                                        ),
                                        Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
                                        Container(
                                            padding: EdgeInsets.fromLTRB(5, 0, 5, 5),

                                            child:  Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,

                                              children: <Widget>[
                                                Expanded(child: Text(
                                                  question.content,
                                                  overflow: TextOverflow.visible,
                                                  maxLines: 20,
                                                  style: TextStyle(
                                                    fontSize: 20,  fontStyle: FontStyle.italic, fontWeight: FontWeight.w400 ),
                                                ),)

                                              ],
                                            )
                                        ),



                                      ],
                                    ),
                                  ),
                                )

                              ],


                            ),

                          ],



                        ),

                      ],


                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                constraints: BoxConstraints.loose(Size(
                                    MediaQuery.of(context).size.width,
                                    MediaQuery.of(context).size.height * 0.75)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),

                                context: context,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(builder: (BuildContext context, StateSetter setStateKhoa) {
                                    return SingleChildScrollView(
                                        child: Container(
                                          height: 900,
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(padding: EdgeInsets.fromLTRB(0, 10,0, 10)),
                                              Text("Trả lời câu hỏi",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:FontWeight.bold),
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                                child: StreamBuilder(
                                                  stream: answerControl,
                                                  builder: (context, snapshot) => TextField(
                                                    controller: _answerController,
                                                    maxLines: 7,
                                                    maxLength: 500,
                                                    decoration:
                                                    InputDecoration(
                                                        hintMaxLines: 5,
                                                        helperMaxLines:
                                                        5,
                                                        labelText:
                                                        "Đặt câu hỏi",
                                                        hintText:
                                                        'Nhập câu hỏi của bạn',
                                                        enabledBorder:
                                                        OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                            borderSide:
                                                            BorderSide(
                                                              color:
                                                              Colors.blueAccent,
                                                              width:
                                                              1,
                                                            )),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .blue,
                                                                width:
                                                                4))),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child:
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          _onSendAnswerClicked();
                                                          print(
                                                              'press save');
                                                        },
                                                        child: Text(
                                                          'Gửi',
                                                          style: TextStyle(
                                                              fontSize:
                                                              16,
                                                              color: Colors
                                                                  .white),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding:
                                                        EdgeInsets
                                                            .all(
                                                            10)),
                                                    Expanded(
                                                        child:
                                                        ElevatedButton(
                                                            onPressed:
                                                                () =>
                                                            {
                                                              Navigator.pop(context)
                                                            },
                                                            child:
                                                            Text(
                                                              'Thoát',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors.white),
                                                            ))),
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .fromLTRB(
                                                            0,
                                                            10,
                                                            0,
                                                            30)),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ));
                                  });
                                });
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white70,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12))),
                          child: Text(
                            employeeModel.name! +
                                " ơi, bạn có muốn đặt câu hỏi?",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],

                ),
              ),
            ),
          );
        });
  }
  _onSendAnswerClicked(){
    var isvalid = isValid(_answerController.text);
    var time = DateTime.now();
    String timestring = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    print(timestring);

    if(isvalid){
      LoadingDialog.showLoadingDialog(context, "loading...");
      sendAnswer(employeeModel.id, _answerController.text, timestring, question.id, () {
            LoadingDialog.hideLoadingDialog(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomePageEmployee()));


          }
      );


    }
    return 0;
  }

  void sendAnswer(String userId, String content, String time, String questionId, Function onSucces) {

    var ref = FirebaseFirestore.instance.collection('answer');
    String id = ref.doc().id;
    ref.doc(id).set({
      'id': id,
      'userId': userId,
      'time': time,
      'content': content,
      'questionId': questionId,
    }
    ).then((value) {
      onSucces();
      print("add nice");
    }).catchError((err) {
      print(err);
    });

  }
}