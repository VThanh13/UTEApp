import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/resources/leader/stats_leader.dart';
import 'package:myapp/src/models/EmployeeModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/internet_check.dart';
import '../../models/NewfeedModel.dart';
import '../employee/employee_info.dart';
import '../dialog/loading_dialog.dart';
import '../employee/messenger_employee.dart';
import '../login_screen.dart';
import 'manage_category.dart';
import 'manage_employee.dart';

class HomePageLeader extends StatefulWidget {
  const HomePageLeader({super.key});

  @override
  State<HomePageLeader> createState() => _HomePageState();
}

class Employee {
  String id;
  String name;
  String email;
  String image;
  String password;
  String phone;
  String departmentId;
  String departmentName;
  List<String> category;
  String roles;
  String status;

  Employee(
      this.id,
      this.name,
      this.email,
      this.image,
      this.password,
      this.phone,
      this.departmentId,
      this.departmentName,
      this.category,
      this.roles,
      this.status);

  @override
  int get hashCode => Object.hash(id, name, email, image, password, phone, departmentId, departmentName, category, roles, status);

  @override
  bool operator ==(Object other) {

    return other.hashCode == hashCode;
  }
}

class Post {
  String id;
  Employee employee;
  String content;
  String time;
  String file;

  Post(this.id, this.employee, this.content, this.time, this.file);

  @override
  int get hashCode => Object.hash(id, employee, content, time, file);

  @override
  bool operator ==(Object other) {

    return  other.hashCode == hashCode;
  }
}

class _HomePageState extends State<HomePageLeader> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userAuth = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel = EmployeeModel();
  var departmentName = {};

  InternetCheck internetCheck = InternetCheck();

  Post? get post => null;
  @override
  void dispose() {
    _infoPostControll.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // getListPost();
    reload();
    _onCreateNewPost();
    sortListPost();

  }

  final TextEditingController _infoPostController = TextEditingController();

  final StreamController _infoPostControll = StreamController.broadcast();

  Stream get infoPostController => _infoPostControll.stream;

  bool isValidContent(String content) {
    if (content.isEmpty) {
      _infoPostControll.sink.addError("Nhập nội dung");
      return false;
    }
    return true;
  }

  void createNewPost(String employeeId, String content, String time,
      String file, Function onSuccess) {
    var ref = FirebaseFirestore.instance.collection('newfeed');
    String id = ref.doc().id;
    ref.doc(id).set({
      'id': id,
      'employeeId': employeeId,
      'content': content,
      'time': time,
      'file': file,
    }).then((value) {
      onSuccess();
    }).catchError((err) {});
  }

  _onCreateNewPost() async {
    var isValidContentT = isValidContent(_infoPostController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadImage();
    if (isValidContentT) {
      if (!mounted) return;
      LoadingDialog.showLoadingDialog(context, "Please Wait...");
      createNewPost(
          employeeModel.id!, _infoPostController.text, timeString, imgUrl, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomePageLeader()));
        showSuccessMessage('Create post success');
      });
    }
    return 0;
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message,
      style: const TextStyle(color: Colors.white),
    ), backgroundColor: Colors.blueAccent,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(content: Text(message,
      style: const TextStyle(color: Colors.white),
    ),backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  List<Post> listPost = [];
  getListPost() async {
    await getDepartmentName();
    List<NewfeedModel> listNewfeed = [];
    await FirebaseFirestore.instance
      .collection('newfeed')
      .get()
      .then((value) => {
        setState(() {
          for (var element in value.docs) {
            NewfeedModel newFeed = NewfeedModel();
            newFeed.id = element['id'];
            newFeed.content = element['content'];
            newFeed.time = element['time'];
            newFeed.file = element['file'];
            newFeed.employeeId = element['employeeId'];

            listNewfeed.add(newFeed);
          }
        }),
      });
    // ignore: avoid_function_literals_in_foreach_calls
    listNewfeed.forEach((element) async {
      Employee employee = Employee("", "", "", "", "", "", "", "", [], "", "");
      Post post = Post(
          element.id!, employee, element.content!, element.time!, element.file!);
      await FirebaseFirestore.instance
        .collection('employee')
        .doc(element.employeeId)
        .get()
        .then((value) => {
          setState(() {
            employee.id = value['id'];
            employee.name = value['name'];
            employee.email = value['email'];
            employee.image = value['image'];
            employee.password = value['password'];
            employee.phone = value['phone'];
            employee.departmentId = value['department'];
            employee.departmentName = departmentName[employee.departmentId];
            employee.category = value['category'].cast<String>();
            employee.roles = value['roles'];
            employee.status = value['status'];
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
      key: UniqueKey(),
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueAccent,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(post.employee.image),
                    radius: 22,
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
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3,),
                  Text(
                    post.time,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    post.employee.departmentName,
                    style: TextStyle(fontSize: 11,
                    color: Colors.grey[500]),
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
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  post.content,
                  overflow: TextOverflow.visible,
                  maxLines: 50,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 0)),
          if (post.file != 'file.pdf')
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              child: Image.network(
                post.file,
              ),
            ),
          const SizedBox(height: 10,)
        ],
      ),
    );
  }

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
  bool isLoading = false;
  Future<void> reload() async {
    setState(() {
      isLoading = true;
      listPost = [];

    });
    await getListPost();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("employee")
            .where("id", isEqualTo: userAuth.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator()),
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
            employeeModel.category = (e.data() as Map)['category'].cast<String>();
            employeeModel.roles = (e.data() as Map)['roles'];
            employeeModel.status = (e.data() as Map)['status'];

            return employeeModel;
          }).toString();
          return Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: AppBar(
              title: const Text("UTE APP"),
              backgroundColor: Colors.blueAccent,
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    if(internetCheck.isInternetConnect == true){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                              const MessengerPageEmployee()));
                    }else{
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: const Column(
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    size: 30,
                                    color: Colors.redAccent,
                                  ),
                                  Text('No internet'),
                                ],
                              ),
                              content: const Text(
                                  'Please check your internet connection!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          });
                    }

                  },
                  icon: const Icon(
                    AppIcons.chat,
                    color: Colors.white,
                  ),
                ),
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
                  InkWell(
                    onTap: (){
                      if(internetCheck.isInternetConnect == true){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeInfo()));

                      }else{
                        showDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const Column(
                                  children: [
                                    Icon(
                                      Icons.warning_amber,
                                      size: 30,
                                      color: Colors.redAccent,
                                    ),
                                    Text('No internet'),
                                  ],
                                ),
                                content: const Text(
                                    'Please check your internet connection!'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    child: SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 13,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 17.14,
                                        width: 20,
                                        child: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Icon(
                                            Icons.person,
                                            color: Color(0xff757575),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 22,
                                        margin: const EdgeInsets.only(left: 20),
                                        child: const Text(
                                          'Personal Information',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Plus_Jakarta_Sans',
                                            color: Color(0xff000000),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                  height: 10,
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xffB4B4B4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 0,
                              color: Color(0xffAAAAAA),
                              indent: 0,
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      if(internetCheck.isInternetConnect == true){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageEmployee()));

                      }else{
                        showDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const Column(
                                  children: [
                                    Icon(
                                      Icons.warning_amber,
                                      size: 30,
                                      color: Colors.redAccent,
                                    ),
                                    Text('No internet'),
                                  ],
                                ),
                                content: const Text(
                                    'Please check your internet connection!'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    child: SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 13,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 17.14,
                                        width: 20,
                                        child: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Icon(
                                            Icons.group,
                                            color: Color(0xff757575),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 22,
                                        margin: const EdgeInsets.only(left: 20),
                                        child: const Text(
                                          'Manage employee',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Plus_Jakarta_Sans',
                                            color: Color(0xff000000),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                  height: 10,
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xffB4B4B4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 0,
                              color: Color(0xffAAAAAA),
                              indent: 0,
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      if(internetCheck.isInternetConnect == true){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategory()));

                      }else{
                        showDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const Column(
                                  children: [
                                    Icon(
                                      Icons.warning_amber,
                                      size: 30,
                                      color: Colors.redAccent,
                                    ),
                                    Text('No internet'),
                                  ],
                                ),
                                content: const Text(
                                    'Please check your internet connection!'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    child: SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 13,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 17.14,
                                        width: 20,
                                        child: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Icon(
                                            Icons.category,
                                            color: Color(0xff757575),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 22,
                                        margin: const EdgeInsets.only(left: 20),
                                        child: const Text(
                                          'Manage category',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Plus_Jakarta_Sans',
                                            color: Color(0xff000000),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                  height: 10,
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xffB4B4B4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 0,
                              color: Color(0xffAAAAAA),
                              indent: 0,
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      if(internetCheck.isInternetConnect == true){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsLeaderPage()));

                      }else{
                        showDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const Column(
                                  children: [
                                    Icon(
                                      Icons.warning_amber,
                                      size: 30,
                                      color: Colors.redAccent,
                                    ),
                                    Text('No internet'),
                                  ],
                                ),
                                content: const Text(
                                    'Please check your internet connection!'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    child: SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 13,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 17.14,
                                        width: 20,
                                        child: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Icon(
                                            Icons.add_chart,
                                            color: Color(0xff757575),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 22,
                                        margin: const EdgeInsets.only(left: 20),
                                        child: const Text(
                                          'Statistical',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Plus_Jakarta_Sans',
                                            color: Color(0xff000000),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                  height: 10,
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xffB4B4B4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 0,
                              color: Color(0xffAAAAAA),
                              indent: 0,
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () async {
                      if(internetCheck.isInternetConnect == true){
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString("id", "");
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));

                      }else{
                        showDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const Column(
                                  children: [
                                    Icon(
                                      Icons.warning_amber,
                                      size: 30,
                                      color: Colors.redAccent,
                                    ),
                                    Text('No internet'),
                                  ],
                                ),
                                content: const Text(
                                    'Please check your internet connection!'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      }

                    },
                    child: SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(left: 13,),
                                  child: Row(
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 17.14,
                                        width: 20,
                                        child: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Icon(Icons.logout,
                                            color: Color(0xff757575),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 22,
                                        margin: const EdgeInsets.only(left: 20),
                                        child:  const Text(
                                          'Log out',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Plus_Jakarta_Sans',
                                            color: Color(0xff000000),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                  height: 10,
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Icon(Icons.arrow_forward_ios,
                                      color: Color(0xffB4B4B4),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            const Divider(
                              height: 0,
                              color: Color(0xffAAAAAA),
                              indent: 0,
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: internetCheck.isInternetConnect == true?
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 90,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 80,
                              margin: const EdgeInsets.fromLTRB(10, 0, 0, 15),
                              child: Center(
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.blueAccent,
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            employeeModel.image!),
                                        radius: 26,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _modalBottomSheetAddPost,
                              child: SizedBox(
                                height: 90,
                                width: 270,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 50,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Padding(padding: EdgeInsets.only(left: 5),
                                          child: Icon(Icons.newspaper_outlined),),
                                          Padding(padding: EdgeInsets.only(bottom: 3, left: 5),
                                          child: Text('Create new post',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 14
                                          ),
                                          ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                      child: const Divider(
                                        height: 0,
                                        color: Color(0xffAAAAAA),
                                        indent: 0,
                                        thickness: 1,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                      width: 200,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                                                child: Icon(Icons.image,
                                                color: Colors.blueAccent,),),
                                              Padding(padding: EdgeInsets.fromLTRB(0, 1, 1, 1),
                                              child: Text('Photo',
                                              style: TextStyle(fontSize: 12),),)
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Padding(padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                                                child: Icon(Icons.picture_as_pdf_rounded,
                                                color: Colors.redAccent,),),
                                              Padding(padding: EdgeInsets.fromLTRB(0, 1, 1, 1),
                                                child: Text('File',
                                                style: TextStyle(
                                                  fontSize: 12
                                                ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isLoading,
                      replacement: RefreshIndicator(
                      onRefresh: reload,
                      child: Visibility(
                        visible: listPost.isNotEmpty,
                        replacement: const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 200),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_sharp,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                Text(
                                  'No post found!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.75,
                              child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: listPost.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return _buildNewFeed(context, listPost[index]);
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ), child: const Center(
                      child: Padding(padding: EdgeInsets.only(top: 200),
                      child: CircularProgressIndicator(),)
                    ),
                    ),

                  ],
                ):const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.redAccent,
                        size: 45,
                      ),
                      Text(
                        'No Internet connection!',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  _modalBottomSheetAddPost() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.75)),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: (){
              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          margin: const EdgeInsets.only(left: 90),
                          child: const Text(
                            'Create new post',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0),
                          ),
                        ),

                        Padding(padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                          child: IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            iconSize: 30,
                            onPressed: (){
                              Navigator.pop(context);
                            },
                          ),)
                      ],
                    ),
                    const Divider(
                      height: 0,
                      color: Color(0xffAAAAAA),
                      indent: 0,
                      thickness: 1,
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.665,
                            child: SingleChildScrollView(
                                child: SizedBox(
                                  height: 600,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      const Padding(
                                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                                      Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                        child: StreamBuilder(
                                          stream: infoPostController,
                                          builder: (context, snapshot) => TextField(
                                            controller: _infoPostController,
                                            maxLines: 50,
                                            maxLength: 3000,
                                            minLines: 10,
                                            decoration: InputDecoration(
                                                hintMaxLines: 5,
                                                helperMaxLines: 5,
                                                labelText: "Post content",
                                                hintText:
                                                'Insert post content',
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                    borderSide: const BorderSide(
                                                      color: Colors.blueAccent,
                                                      width: 1,
                                                    )),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                    borderSide: const BorderSide(
                                                        color: Colors.blue,
                                                        width: 4))),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          margin: const EdgeInsets.fromLTRB(20, 10, 30, 0),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(color: Colors.grey),
                                          ),
                                          child: const Row(
                                            children: [
                                              Padding(padding: EdgeInsets.fromLTRB(30, 1, 70, 1),
                                                child: Text('Insert to your post',
                                                  style: TextStyle(
                                                      fontSize: 14
                                                  ),
                                                ),
                                              ),
                                              Padding(padding: EdgeInsets.fromLTRB(1, 1, 20, 1),
                                                child: Icon(
                                                  AppIcons.file_pdf,
                                                  size: 20,
                                                  color: Colors.redAccent,
                                                ),),
                                              Padding(padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
                                                child: Icon(
                                                  Icons.add_photo_alternate_rounded,
                                                  size: 30,
                                                  color: Colors.green,
                                                ),)
                                            ],
                                          ),
                                        ),
                                        onTap: (){
                                          importImage();
                                        },
                                      ),
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            if(internetCheck.isInternetConnect == true){
                                              try{
                                                if(_onCreateNewPost()){
                                                  setState(() {
                                                    _infoPostController.text = '';
                                                  });
                                                }else{
                                                  setState(() {
                                                    _infoPostController.text = '';
                                                  });
                                                  Navigator.pop(context);
                                                  showErrorMessage('Create post failed');
                                                }
                                              }catch(e){
                                                //
                                              }

                                            }else{
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return CupertinoAlertDialog(
                                                      title: const Column(
                                                        children: [
                                                          Icon(
                                                            Icons.warning_amber,
                                                            size: 30,
                                                            color: Colors.redAccent,
                                                          ),
                                                          Text('No internet'),
                                                        ],
                                                      ),
                                                      content: const Text(
                                                          'Please check your internet connection!'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child: const Text('OK'),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            }

                                          },
                                          label: const Text(
                                            'Post',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                          icon: const Icon(Icons.task_alt),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueAccent),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
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

  late File file;
  bool hadFile = false;
  String fileName = "";
  importImage() async {
    final imagePicker = ImagePicker();
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Select Image
      var image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        file = File(image.path);
        fileName = image.name;
        hadFile = true;
      });
    } else {
    }
  }

  String imgUrl = "file.pdf";
  uploadImage() async {
    if (hadFile) {
      File fileForFirebase = File(file.path);
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("image_post/$fileName");
      UploadTask uploadTask = ref.putFile(fileForFirebase);
      await uploadTask.whenComplete(() async {
        var url = await ref.getDownloadURL();
        imgUrl = url.toString();
      }).catchError((onError) {
        return onError;
      });
    } else {}
  }
}
