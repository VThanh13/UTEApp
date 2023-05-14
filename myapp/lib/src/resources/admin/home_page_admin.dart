import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/resources/about_page/my_file.dart';
import 'package:myapp/src/resources/about_page/my_info.dart';
import 'package:myapp/src/resources/about_page/about_university.dart';
import 'package:myapp/src/resources/about_page/admission_history.dart';
import 'package:myapp/src/resources/messenger/messenger_page.dart';
import 'package:myapp/src/models/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login_screen.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageAdmin> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userR = FirebaseAuth.instance.currentUser!;
  String name = "1234";
  UserModel userModel = UserModel("", " ", "", "", "", "", "", "");

  Future<String> getUserNameFromUID() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: userR.uid)
        .get();
    return snapshot.docs.first['name'];
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
            .where("userId", isEqualTo: userR.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
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
            userModel.status = (e.data() as Map)['status'];

            return userModel;
          }).toString();

          // TODO: implement build
          return Scaffold(
            appBar: AppBar(
              title: const Text("UTE APP"),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const MessengerPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    AppIcons.chat,
                    color: Colors.white,
                  ),
                ),
                // IconButton(
                //     onPressed: () {
                //       Navigator.push(
                //           context,
                //           new MaterialPageRoute(
                //               builder: (BuildContext context) => TestPage()));
                //     },
                //     icon: Icon(
                //       AppIcons.bell_alt,
                //       color: Colors.white,
                //     ))
              ],
            ),
            drawer: Drawer(
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(userModel.name!),
                    accountEmail: Text(userModel.email!),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(userModel.image!),
                    ),
                  ),
                  ListTile(
                    title: const Text('Thông tin cá nhân'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const MyInfo(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  ListTile(
                    title: const Text('Giới thiệu về trường'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => AboutUniversity(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  ListTile(
                    title: const Text('Lịch sử tuyển sinh'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => AdmissionHistory(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  ListTile(
                    title: const Text('Hồ sơ của bạn'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => MyFile(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  ListTile(
                    title: const Text('Đăng xuất'),
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString("id", "");
                      await FirebaseAuth.instance.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
