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
class Answer{
  String id;
  String content;
  String questionId;
  String time;
  EmployeeModel employee;

  Answer(this.id, this.questionId, this.content, this.time, this.employee);
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
FirebaseAuth auth = FirebaseAuth.instance;
var userr = FirebaseAuth.instance.currentUser!;
EmployeeModel employeeModel = new EmployeeModel("", " ", "", "", "", "", "", "", "");
UserModel uModel = new UserModel("", " ", "", "", "", "");
Question question = new Question("", "", "", "", "", "", "", uModel, "", "");

List<Answer> listAnswer = [];
Future<List<Answer>> getAnswerData() async {
  List<AnswerModel> list = [];
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('answer').where('questionId', isEqualTo: question.id).get();
  snapshot.docs.map((e){
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
  for (var i = 0; i < list.length; i++){
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('employee')
        .where('id', isEqualTo: list[i].userId)
        .get();
    snapshot.docs.map((e){
      EmployeeModel employeeModel = new EmployeeModel("", "", "", "", "", "", "", "", "");
      Answer ans = Answer(
          list[i].id, list[i].questionId, list[i].content, list[i].time,
          employeeModel);
      employeeModel.id = (e.data() as Map)['id'];
      employeeModel.name = (e.data() as Map)['name'];
      employeeModel.email = (e.data() as Map)['email'];
      employeeModel.image = (e.data() as Map)['image'];
      employeeModel.password = (e.data() as Map)['password'];
      employeeModel.phone = (e.data() as Map)['phone'];
      employeeModel.department = (e.data() as Map)['department'];
      employeeModel.category = (e.data() as Map)['category'];
      employeeModel.roles = (e.data() as Map)['roles'];
      ans.employee = employeeModel;
      listAns.add(ans);
    }).toList();

  }
  return listAns;
}

fillListQuestion(setState) async{
  final listAnswers = await getAnswerData() as List<Answer>;
  setState((){
    listAnswer=listAnswers;
  });
}
_buildAnswers(setState) {
  fillListQuestion(setState);

  List<Widget> answerList = [];
  listAnswer.forEach((Answer answer) {
    answerList.add(
        GestureDetector(

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
                              Text(answer.employee.name,
                                style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, ),),

                              Text(' lúc ', style: TextStyle(fontSize: 15),),
                              Expanded(child:Text(
                                answer.time,
                                overflow: TextOverflow.visible,
                                maxLines: 3,
                                style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, overflow: TextOverflow.visible),)
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
                                    answer.content,
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
                  ),
                ],
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.tealAccent,
                child: CircleAvatar(
                  backgroundImage:
                  new NetworkImage(answer.employee.image!),
                  radius: 20,

                ),
              ),
            ],
          ),

        )
    );
  });
  return Column(children: answerList);
}

class _DetailQuestionState extends State<DetailQuestion> {
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

    return employeeModel;

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
                                              widget.question.time,
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
                        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildAnswers(setState)
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });});
  }
}
