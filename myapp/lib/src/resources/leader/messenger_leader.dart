import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/models/QuestionModel.dart';

import '../../models/EmployeeModel.dart';

class MessengerPageLeader extends StatefulWidget {
  const MessengerPageLeader({super.key});

  @override
  State<MessengerPageLeader> createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPageLeader> {
  CollectionReference derPart =
      FirebaseFirestore.instance.collection('departments');
  FirebaseFirestore db = FirebaseFirestore.instance;

  String? valueKhoa;
  var selectedDerpartments;
  var departmentsItems = [];

  FirebaseAuth auth = FirebaseAuth.instance;
  var userR = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel = EmployeeModel("", " ", "", "", "", "", "", "", "", "");


  List<QuestionModel> listQuestion = [];
  // Future<List<QuestionModel>> getQuestionData() async {
  //   List<QuestionModel> list = [];
  //   QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('questions').where('department', isEqualTo: employeeModel.department).get();
  //     snapshot.docs.map((e) {
  //       QuestionModel questionModel = new QuestionModel("", "", "", "", "", "", "", "", "", "");
  //       questionModel.id = e.reference.id;
  //       questionModel.title = (e.data() as Map)['title'];
  //       questionModel.content = (e.data() as Map)['content'];
  //       questionModel.time = (e.data() as Map)['time'];
  //       questionModel.department = (e.data() as Map)['department'];
  //       questionModel.category = (e.data() as Map)['category'];
  //       questionModel.status = (e.data() as Map)['status'];
  //       questionModel.userId = (e.data() as Map)['userId'];
  //       questionModel.information = (e.data() as Map)['information'];
  //       questionModel.file = (e.data() as Map)['file'];
  //       list.add(questionModel);
  //
  //   }).toList();
  //   return list;
  // }

  // fillListQuestion(setState) async{
  //   final testlistQuestion = await getQuestionData() as List<QuestionModel>;
  //   setState((){
  //     listQuestion=testlistQuestion;
  //   });
  // }
  // _buildQuestions(setState) {
  //   //fillListQuestion(setState);
  //
  //   List<Widget> questionsList = [];
  //   listQuestion.forEach((QuestionModel question) {
  //     questionsList.add(
  //         GestureDetector(
  //           onTap: () {
  //             Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => DetailQuestionEmployee(question: question)));
  //           },
  //           child: Container(
  //             margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
  //             decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(15.0),
  //                 border: Border.all(
  //                   width: 1.0,
  //                   color: Colors.grey,
  //                 )
  //             ),
  //             child: Row(
  //               children: <Widget>[
  //                 Expanded(child: Container(
  //                   margin: EdgeInsets.all(12.0),
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: <Widget>[
  //                       Text(question.title,
  //                         style: TextStyle(
  //                           fontSize: 20.0,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                       SizedBox(height: 4.0,),
  //
  //                       Text(question.time,
  //                         style: TextStyle(
  //                           fontSize: 16.0,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                       Text(question.status,
  //                       style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: question.status == "Chưa trả lời"? Colors.redAccent : Colors.green),
  //                       overflow: TextOverflow.ellipsis,)
  //
  //                     ],
  //                   ),
  //                 ))
  //               ],
  //             ),
  //           ),
  //
  //         )
  //     );
  //   });
  //   return Column(children: questionsList);
  // }

  final StreamController _informationControl = StreamController();
  final StreamController _titleControl = StreamController();
  final StreamController _questionControl = StreamController();
  
  Stream get informationControl => _informationControl.stream;
  Stream get titleControl => _titleControl.stream;
  Stream get questionControl => _questionControl.stream;
  
  bool isValid(String information, String title, String question){
    if(information.isEmpty){
      _informationControl.sink.addError("Nhập thông tin liên lạc");
      return false;
    }

    if(title.isEmpty){
      _titleControl.sink.addError("Nhập tiêu đề");
      return false;
    }
    if(question.isEmpty){
      _questionControl.sink.addError("Nhập câu hỏi");
      return false;
    }
    
    return true;
  }

  @override
  void dispose(){
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
            return const Center(
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }
          List<String> list = [];
          snapshot.data!.docs.map((e) {
            String name = (e.data() as Map)["name"];
            list.add(name);
            return list;
          }).toList();

          return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("departments")
                  .where("name", isEqualTo: valueKhoa)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator()),
                  );
                }

                return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("employee")
                        .where("id", isEqualTo: userR.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: SizedBox(
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

                      // TODO: implement build
                      return Scaffold(
                        appBar: AppBar(
                          title: const Text("Tin nhắn"),
                        ),
                        body: SafeArea(
                          minimum: const EdgeInsets.only(left: 20, right: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 70,
                                    child: ElevatedButton(
                                      onPressed: () {
                                      },
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.white70,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12))),
                                      child: const Text(
                                            "Trả lời câu hỏi",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                ),

                                StreamBuilder<QuerySnapshot>(
                                    stream: derPart.snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasError) {
                                        const Text("Loading");
                                      } else {
                                        derPart.get().then(
                                            (QuerySnapshot querySnapshot) {
                                          for (var doc in querySnapshot.docs) {
                                            print(doc["departments"]);
                                          }
                                        });
                                      }
                                      return const Text("");
                                    }),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget>[
                                    Padding(padding: EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Text(
                                        'Câu hỏi của bạn',
                                        style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                    //_buildQuestions(setState)
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
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

}
