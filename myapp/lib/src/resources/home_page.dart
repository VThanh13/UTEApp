import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

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

import '../models/NewfeedModel.dart';
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

class Post {
  String id;
  Employee employee;
  String content;
  String time;
  String file;

  Post(this.id, this.employee, this.content, this.time, this.file);
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
  String category;
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
}


class _HomePageState extends State<HomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userr = FirebaseAuth.instance.currentUser!;
  String name = "1234";
  UserModel userModel = new UserModel("", " ", "", "", "", "", "");

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
  }


  @override
  void initState() {
    super.initState();
    getListPost();
  }

  var departmentName = new Map();

  void sendQuestion(
      String userId,
      String title,
      String time,
      String status,
      String information,
      String file,
      String department,
      String content,
      String category,
      String people,
      Function onSucces) {
    var ref = FirebaseFirestore.instance.collection('questions');
    String id = ref.doc().id;
    ref.doc(id).set({
      'id': id,
      'userId': userId,
      'title': title,
      'time': time,
      'status': status,
      'information': information,
      'file': file,
      'department': department,
      'content': content,
      'people': people,
      'category': category,
    }).then((value) {
      onSucces();
      print("add nice");
    }).catchError((err) {
      print(err);
    });
  }

  bool isValid(String information, String question) {
    if (information == null || information.length == 0) {
      _informationControl.sink.addError("Nhập thông tin liên lạc");
      return false;
    }

    if (question == null || question.length == 0) {
      _questionControl.sink.addError("Nhập câu hỏi");
      return false;
    }

    return true;
  }

  _onSendQuestionClicked(Post post) async {
    var isvalid =
    isValid(_informationController.text, _questionController.text);
    var time = DateTime.now();
    String timestring = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadPdf();

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      sendQuestion(
          userr.uid,
          "Thắc mắc bài đăng ngày " + post.time,
          timestring,
          "Chưa trả lời",
          _informationController.text,
          pdf_url,
          post.employee.departmentId,
          _questionController.text,
          "",
          value_doituong!, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MessengerPage()));
      });
    }
    return 0;
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

                    // Container(
                    //   child: Expanded(
                    //     child: Text(post.content,
                    //     ),
                    //   ),
                    // )


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
          ),
          Container(
            margin: EdgeInsets.fromLTRB(240, 10, 0, 10),
            width: 48,
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              icon: Icon(Icons.send_sharp),
              iconSize: 30,
              color: Colors.white70,
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )
                  ),
                  context: context,
                  builder: (BuildContext contetxt){
                    return StatefulBuilder(builder: (BuildContext context, StateSetter setStateKhoa ){
                      return Container(
                        height: 600,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      0, 10, 0, 20)),
                              Text(
                                "Gửi thắc mắc về bài đăng",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                width: 340,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.pinkAccent, width: 4,
                                  )
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: value_doituong,
                                    hint: new Text(
                                        "Vui lòng chọn đối tượng"),
                                    iconSize: 36,
                                    items: item_doituong.map(buildMenuItem).toList(),
                                    onChanged: (value){
                                      setStateKhoa((){
                                        setState(() {
                                          this.value_doituong = value;
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                  margin:
                                  EdgeInsets.fromLTRB(0, 10, 0, 15),
                                  width: 340,
                                  child: StreamBuilder(
                                    stream: informationControl,
                                    builder: (context, snapshot) =>
                                        TextField(
                                          controller:
                                          _informationController,
                                          decoration: InputDecoration(
                                              labelText:
                                              "Phương thức liên hệ",
                                              hintText:
                                              'Nhập Email/SĐT của bạn',
                                              enabledBorder:
                                              OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(10),
                                                  borderSide:
                                                  BorderSide(
                                                    color: Colors
                                                        .pinkAccent,
                                                    width: 1,
                                                  )),
                                              focusedBorder:
                                              OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(10),
                                                  borderSide: BorderSide(
                                                      color:
                                                      Colors.pink,
                                                      width: 4))),
                                        ),
                                  )),
                              Container(
                                width: 340,
                                margin:
                                EdgeInsets.fromLTRB(0, 10, 0, 15),
                                child: StreamBuilder(
                                  stream: questionControl,
                                  builder: (context, snapshot) =>
                                      TextField(
                                        controller: _questionController,
                                        maxLines: 50,
                                        minLines: 7,
                                        maxLength: 3000,
                                        decoration: InputDecoration(
                                            hintMaxLines: 5,
                                            helperMaxLines: 5,
                                            labelText: "Đặt câu hỏi",
                                            hintText:
                                            'Nhập câu hỏi của bạn',
                                            enabledBorder:
                                            OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(10),
                                                borderSide: BorderSide(
                                                  color:
                                                  Colors.pinkAccent,
                                                  width: 1,
                                                )),
                                            focusedBorder:
                                            OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(10),
                                                borderSide: BorderSide(
                                                    color: Colors.pink,
                                                    width: 4))),
                                      ),
                                ),
                              ),
                              IconButton(
                                  onPressed:() {
                                    importPdf();
                                  },
                                  icon: Icon(
                                      AppIcons.file_pdf)),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      child: ElevatedButton.icon(

                                        onPressed: () {
                                          _onSendQuestionClicked(post);
                                          print('press save');
                                        },
                                        label: Text(
                                          'Gửi',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: Icon(Icons.mail_outline_rounded),
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.pinkAccent
                                        ),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(10)),
                                    Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => {
                                            Navigator.pop(context)
                                          },
                                          label: Text(
                                            'Thoát',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                          icon: Icon(Icons.cancel_presentation),
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.pinkAccent
                                          ),
                                        )),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0, 10, 0, 30)),
                                  ],
                                ),
                              )
                            ],

                          ),
                        ),
                      );
                    });
                  }
                );
                
              },
            ),
          )
        ],
      ),

    );
  }
  late PlatformFile file;
  importPdf() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    file = result.files.first as PlatformFile;
    setState((){
      print(file.name);
    });
  }
  String pdf_url = "file.pdf";
  uploadPdf() async {
    if(file!=null){
      File fileForFirebase = File(file.path!);
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref =
      storage.ref().child("pdf/"+file.name);
      UploadTask uploadTask = ref.putFile(fileForFirebase);
      await uploadTask.whenComplete(() async {
        var url = await ref.getDownloadURL();
        pdf_url = url.toString();
      }).catchError((onError) {
        print(onError);
      });
      print('pdf');
    }
  }
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
  var item_doituong = [
    'Học sinh THPT',
    'Sinh viên',
    'Phụ huynh',
    'Cựu sinh viên',
    'Khác'
  ];

  String? value_doituong;

  TextEditingController _informationController = new TextEditingController();
  TextEditingController _questionController = new TextEditingController();

  StreamController _informationControl = new StreamController.broadcast();
  StreamController _questionControl = new StreamController.broadcast();

  Stream get informationControl => _informationControl.stream;
  Stream get questionControl => _questionControl.stream;

  void dispose() {
    _questionControl.close();

    _informationControl.close();
    super.dispose();
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));



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
            userModel.status = (e.data() as Map)['status'];

            return userModel;

          }).toString();

          // TODO: implement build
          return Scaffold(
            appBar: new AppBar(
              backgroundColor: Colors.pinkAccent,


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
            drawer: new Drawer(

              child: ListView(
                children: <Widget>[
                  new UserAccountsDrawerHeader(

                    accountName: new Text(userModel.name!),
                    accountEmail: new Text(userModel.email!),
                    arrowColor: Colors.redAccent,
                    currentAccountPicture: new CircleAvatar(
                      backgroundImage:
                          new NetworkImage(userModel.image!),
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
                  // new Divider(
                  //   color: Colors.black,
                  //   height: 5.0,
                  // ),
                  // new ListTile(
                  //   title: new Text('Lịch sử tuyển sinh'),
                  //   onTap: () {
                  //     Navigator.push(
                  //         context,
                  //         new MaterialPageRoute(
                  //             builder: (BuildContext context) =>
                  //                 new AdmissionHistory()));
                  //   },
                  // ),
                  // new Divider(
                  //   color: Colors.black,
                  //   height: 5.0,
                  // ),
                  // new ListTile(
                  //   title: new Text('Hồ sơ của bạn'),
                  //   onTap: () {
                  //     Navigator.push(
                  //         context,
                  //         new MaterialPageRoute(
                  //             builder: (BuildContext context) => new MyFile()));
                  //   },
                  // ),
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
}
