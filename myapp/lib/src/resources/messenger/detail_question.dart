import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/QuestionModel.dart';
import '../../models/UserModel.dart';

class DetailQuestion extends StatefulWidget {
  _DetailQuestionState createState() => _DetailQuestionState();

  final QuestionModel question;

  DetailQuestion({required this.question});
}

UserModel userModel = new UserModel("", " ", "", "", "", "");

class _DetailQuestionState extends State<DetailQuestion> {
  Future<String> getUserNameFromUID() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: widget.question.userId)
        .get();
    return snapshot.docs.first['name'];
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
            userModel.id = (e.data() as Map)['userId'];
            userModel.name = (e.data() as Map)['name'];
            userModel.email = (e.data() as Map)['email'];
            userModel.image = (e.data() as Map)['image'];
            userModel.password = (e.data() as Map)['pass'];
            userModel.phone = (e.data() as Map)['phone'];
            return userModel;
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
                                new NetworkImage(userModel.image!),
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

                                            Text(userModel.name,
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
                                            Expanded(child:Text(widget.question.department, style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, overflow: TextOverflow.visible),)
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
                                                  widget.question.content,
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


                  ],
                ),
              ),
            ),
          );
        });
  }
}
