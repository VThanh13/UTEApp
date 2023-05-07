import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/resources/about_page/about_university.dart';
import 'package:myapp/src/resources/login_page.dart';
import 'package:myapp/src/models/EmployeeModel.dart';

import '../../models/NewfeedModel.dart';
import '../home_page.dart';
import '../pdf_viewer.dart';
import 'employee_info.dart';
import 'messenger_employee.dart';

class HomePageEmployee extends StatefulWidget {
  const HomePageEmployee({super.key});

  @override
  State<HomePageEmployee> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageEmployee> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userR = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel =
      EmployeeModel("", " ", "", "", "", "", "", "", "", "");
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getListPost();
  }

  var departmentName = {};
  getDepartmentName() async {
    await FirebaseFirestore.instance
        .collection('departments')
        .get()
        .then((value) => {
              setState(() {
                for (var element in value.docs) {
                  departmentName[element.id] = element["name"];
                }
              })
            });
  }

  List<Post> listPost = [];
  getListPost() async {
    await getDepartmentName();
    List<NewfeedModel> listNewFeed = [];
    await FirebaseFirestore.instance
        .collection('newfeed')
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                NewfeedModel newFeed = NewfeedModel("", "", "", "", "");
                newFeed.id = element['id'];
                newFeed.content = element['content'];
                newFeed.time = element['time'];
                newFeed.file = element['file'];
                newFeed.employeeId = element['employeeId'];

                listNewFeed.add(newFeed);
              })
            });
    listNewFeed.forEach((element) async {
      Employee employee = Employee("", "", "", "", "", "", "", "", "", "", "");
      Post post = Post(
          element.id, employee, element.content, element.time, element.file);
      await FirebaseFirestore.instance
          .collection('employee')
          .where("id", isEqualTo: element.employeeId)
          .get()
          .then((value) => {
                setState(() {
                  employee.id = value.docs.first['id'];
                  employee.name = value.docs.first['name'];
                  employee.email = value.docs.first['email'];
                  employee.image = value.docs.first['image'];
                  employee.password = value.docs.first['password'];
                  employee.phone = value.docs.first['phone'];
                  employee.departmentId = value.docs.first['department'];
                  employee.departmentName =
                      departmentName[employee.departmentId];
                  employee.category = value.docs.first['category'];
                  employee.roles = value.docs.first['roles'];
                  employee.status = value.docs.first['status'];
                  post.employee = employee;
                  listPost.add(post);
                  sortListPost();
                })
              });
    });
  }

  sortListPost() {
    setState(() {
      listPost.sort((a, b) => DateFormat("dd-MM-yyyy HH:mm:ss")
          .parse(b.time)
          .compareTo(DateFormat("dd-MM-yyyy HH:mm:ss").parse(a.time)));
    });
  }

  _buildNewFeed(BuildContext context, Post post) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(width: 1.0, color: Colors.pinkAccent)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.tealAccent,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(post.employee.image!),
                    radius: 28,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    post.employee.name,
                    style: const TextStyle(
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    post.time,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    post.employee.departmentName,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  post.content,
                  overflow: TextOverflow.visible,
                  maxLines: 50,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 0)),
          if (post.file != 'file.pdf')
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              child: Image.network(
                post.file,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: CircularProgressIndicator(),
              ),
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
              title: const Text("UTE APP"),
              backgroundColor: Colors.orangeAccent,
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              MessengerPageEmployee(),
                        ),
                      );
                    },
                    icon: const Icon(
                      AppIcons.chat,
                      color: Colors.white,
                    )),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(employeeModel.name!),
                    accountEmail: Text(employeeModel.email!),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(employeeModel.image!),
                    ),
                  ),
                  ListTile(
                    title: const Text('Thông tin cá nhân'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const EmployeeInfo(),
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
                    title: const Text('Đăng xuất'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const LoginPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            body: SafeArea(
              minimum: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: listPost.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _buildNewFeed(context, listPost[index]);
                              }),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
      );
}
