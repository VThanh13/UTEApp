import 'dart:io';

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
import 'package:myapp/src/models/EmployeeModel.dart';
import 'package:myapp/src/screens/signin_screen.dart';

import '../../models/EmployeeModel.dart';
import '../../models/NewfeedModel.dart';
import '../home_page.dart';
import '../pdf_viewer.dart';
import 'employee_info.dart';
import '../dialog/loading_dialog.dart';
import 'messenger_employee.dart';

class HomePageEmployee extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageEmployee> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userr = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel = new EmployeeModel("", " ", "", "", "", "", "", "", "", "");
  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    getListPost();
  }
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
  List<Post> listPost = [];
  getListPost() async {
    await getDepartmentName();
    List<NewfeedModel> listNewfeed = [];
    await FirebaseFirestore.instance
        .collection('newfeed')
        .get()
        .then((value) => {
      value.docs.forEach((element) {
        NewfeedModel newfeed = new NewfeedModel("", "", "", "", "");
        newfeed.id = element['id'];
        newfeed.content = element['content'];
        newfeed.time = element['time'];
        newfeed.file = element['file'];
        newfeed.employeeId = element['employeeId'];

        listNewfeed.add(newfeed);
      })
    });
    print(listNewfeed);
    listNewfeed.forEach((element) async {
      Employee employee =
      new Employee("", "", "", "", "", "", "", "", "", "", "");
      Post post = new Post(
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
        })
      });
    });
  }
  _buildNewfeed(BuildContext context, Post post) {
    return Container(
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(width: 1.0, color: Colors.pinkAccent)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.tealAccent,
                  child: CircleAvatar(
                    backgroundImage: new NetworkImage(post.employee.image!),
                    radius: 28,
                  ),
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(post.employee.name,
                      style: TextStyle(fontSize: 17,fontStyle: FontStyle.italic,fontWeight: FontWeight.w500 ),),
                    Text(post.time,
                      style: TextStyle(fontSize: 12,),),
                    Text(post.employee.departmentName,
                      style: TextStyle(fontSize: 13),),

                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(post.content, overflow: TextOverflow.visible, maxLines: 50,
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                ,)
            ],
          )
        ],
      ),

    );
  }
  @override
  Widget build(BuildContext context) {
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
            employeeModel.status = (e.data() as Map)['status'];

            return employeeModel;

          }).toString();

          // TODO: implement build
          return Scaffold(
            appBar: new AppBar(
              title: new Text("UTE APP"),
              backgroundColor: Colors.orangeAccent,
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  MessengerPageEmployee()));
                    },
                    icon: Icon(
                      AppIcons.chat,
                      color: Colors.white,
                    )),
              ],
            ),
            drawer: new Drawer(
              child: ListView(
                children: <Widget>[
                  new UserAccountsDrawerHeader(
                    accountName: new Text(employeeModel.name!),
                    accountEmail: new Text(employeeModel.email!),
                    currentAccountPicture: new CircleAvatar(
                      backgroundImage:
                          new NetworkImage(employeeModel.image!),
                    ),
                  ),
                  new ListTile(
                    title: new Text('Thông tin cá nhân'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => new EmployeeInfo()));
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
            body: SafeArea(
              minimum: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: listPost.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _buildNewfeed(context, listPost[index]);
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
