import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/resources/about_page/my_file.dart';
import 'package:myapp/src/resources/about_page/my_info.dart';
import 'package:myapp/src/resources/about_page/about_university.dart';
import 'package:myapp/src/resources/about_page/admission_history.dart';
import 'package:myapp/src/resources/login_page.dart';
import 'package:myapp/src/resources/messenger/messenger_page.dart';
import 'package:myapp/src/resources/messenger/test.dart';
import 'package:myapp/src/models/UserModel.dart';
import 'package:myapp/src/screens/signin_screen.dart';

import 'dialog/loading_dialog.dart';

class HomePage extends StatefulWidget {
  // final String emai = "";
//
//   const HomePage({
//     Key? key,
//     required this.emaill,
//
// }): super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  void initState() {
    super.initState();
    // getCurrentUser();
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
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator()),
            );
          }
          snapshot.data!.docs.map((e) {
            userModel.id = (e.data() as Map)['userId'];
            userModel.name = (e.data() as Map)['name'];
            userModel.email = (e.data() as Map)['email'];
            userModel.image = (e.data() as Map)['image'];
            userModel.password = (e.data() as Map)['pass'];
            userModel.phone = (e.data() as Map)['phone'];
            print("hello: "+userModel.name);
            return userModel;

          }).toString();

          // TODO: implement build
          return Scaffold(
            appBar: new AppBar(
              title: new Text("UTE APP"),
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  MessengerPage()));
                    },
                    icon: Icon(
                      AppIcons.chat,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => TestPage()));
                    },
                    icon: Icon(
                      AppIcons.bell_alt,
                      color: Colors.white,
                    ))
              ],
            ),
            drawer: new Drawer(
              child: ListView(
                children: <Widget>[
                  new UserAccountsDrawerHeader(
                    accountName: new Text(userModel.name!),
                    accountEmail: new Text(userModel.email!),
                    currentAccountPicture: new CircleAvatar(
                      backgroundImage:
                          new NetworkImage('http://i.pravatar.cc/300'),
                    ),
                  ),
                  new ListTile(
                    title: new Text('Thông tin cá nhân'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => new MyInfo()));
                    },
                  ),
                  new Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  new ListTile(
                    title: new Text('Giới thiệu về trường'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new AboutUniversity()));
                    },
                  ),
                  new Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  new ListTile(
                    title: new Text('Lịch sử tuyển sinh'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new AdmissionHistory()));
                    },
                  ),
                  new Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  new ListTile(
                    title: new Text('Hồ sơ của bạn'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => new MyFile()));
                    },
                  ),
                  new Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  new ListTile(
                    title: new Text('Đăng xuất'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new LoginPage()));
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
