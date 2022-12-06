import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/UserModel.dart';

class MyInfo extends StatefulWidget {
  @override
  _MyInfoState createState() => new _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userr = FirebaseAuth.instance.currentUser!;
  String name = "1234";
  UserModel userModel = new UserModel("", " ", "", "", "", "");

  Future<String> getUserNameFromUID() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: userr.uid)
        .get();
    return snapshot.docs.first['name'];
  }

  // Check if the user is signed in
  getCurrentUser() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: userr.uid)
        .get();
    userModel = snapshot.docs.first as UserModel;
    print(userModel.name);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("user")
            .where("userId", isEqualTo: userr.uid)
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
            print("hello: " + userModel.name);
            return userModel;
          }).toString();
          // TODO: implement build
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Thông tin cá nhân'),
            ),
            body: SafeArea(
              minimum: const EdgeInsets.only(left: 20, right: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                      width: 400,
                      child: TextField(
                        controller: TextEditingController()
                          ..text = userModel.name!,
                        onChanged: (text) => {},
                        decoration: InputDecoration(
                            labelText: "Tên của bạn",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 4))),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                      width: 400,
                      child: TextField(
                        controller: TextEditingController()
                          ..text = userModel.phone!,
                        onChanged: (text) => {},
                        decoration: InputDecoration(
                            labelText: "SĐT của bạn",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 4))),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                      width: 400,
                      child: TextField(
                        controller: TextEditingController()
                          ..text = userModel.email!,
                        onChanged: (text) => {},
                        decoration: InputDecoration(
                            labelText: "Email của bạn",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 4))),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                      width: 400,
                      child: TextField(
                        controller: TextEditingController()
                          ..text = userModel.password!,
                        onChanged: (text) => {},
                        decoration: InputDecoration(
                            labelText: "Mật khẩu của bạn",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 4))),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                print('press save');
                              },
                              child: Text(
                                'Lưu',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Column(
                                            children: <Widget>[
                                              Text(
                                                "Đổi mật khẩu",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 15),
                                                width: 400,
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                      labelText: "Mật khẩu",
                                                      hintText:
                                                          'Nhập mật khẩu của bạn',
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .blueAccent,
                                                                width: 1,
                                                              )),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          Colors
                                                                              .blue,
                                                                      width:
                                                                          4))),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 15),
                                                width: 400,
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                      labelText: "Mật khẩu mới",
                                                      hintText:
                                                          'Nhập mật khẩu mới của bạn',
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .blueAccent,
                                                                width: 1,
                                                              )),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          Colors
                                                                              .blue,
                                                                      width:
                                                                          4))),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 15),
                                                width: 400,
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          "Xác nhận mật khẩu",
                                                      hintText:
                                                          'Nhập lại mật khẩu của bạn',
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Colors
                                                                    .blueAccent,
                                                                width: 1,
                                                              )),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          Colors
                                                                              .blue,
                                                                      width:
                                                                          4))),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          print('press save');
                                                        },
                                                        child: Text(
                                                          'Lưu',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(10)),
                                                    Expanded(
                                                        child: ElevatedButton(
                                                            onPressed: () => {
                                                                  Navigator.pop(
                                                                      context)
                                                                },
                                                            child: Text(
                                                              'Thoát',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                            ))),
                                                  ],
                                                ),
                                              )
                                            ],
                                          );
                                        });
                                  },
                                  child: const Text('Đổi mật khẩu'))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
