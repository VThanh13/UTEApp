import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/resources/about_page/my_info.dart';
import 'package:myapp/src/resources/about_page/about_university.dart';
import 'package:myapp/src/resources/login_screen.dart';
import 'package:myapp/src/resources/messenger/messenger_page.dart';
import 'package:myapp/src/models/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/NewfeedModel.dart';
import 'dialog/loading_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
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
  var currentUser = FirebaseAuth.instance.currentUser!;
  // String name = "1234";
  UserModel current_user = UserModel("", " ", "", "", "", "", "", "");

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getListPost();
  }

  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: currentUser.uid)
        .get()
        .then((value) => {
              setState(() {
                current_user.id = value.docs.first['userId'];
                current_user.name = value.docs.first['name'];
                current_user.email = value.docs.first['email'];
                current_user.image = value.docs.first['image'];
                current_user.password = value.docs.first['password'];
                current_user.phone = value.docs.first['phone'];
                current_user.group = value.docs.first['group'];
                current_user.status = value.docs.first['status'];
              }),
            });
  }

  cacheCurrentUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("id", current_user.id);
    await prefs.setString("name", current_user.name);
    await prefs.setString("email", current_user.email);
    await prefs.setString("image", current_user.image);
    await prefs.setString("password", current_user.password);
    await prefs.setString("phone", current_user.phone);
    await prefs.setString("group", current_user.group);
    await prefs.setString("status", current_user.status);
    print('duoi la id');
    print(current_user.id);
  }

  var departmentName = {};

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
    _informationControl.sink.add("");
    if (question == null || question.length == 0) {
      _questionControl.sink.addError("Nhập câu hỏi");
      return false;
    }
    _questionControl.sink.add("");

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
          currentUser.uid,
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
                NewfeedModel newfeed = NewfeedModel("", "", "", "", "");
                newfeed.id = element['id'];
                newfeed.content = element['content'];
                newfeed.time = element['time'];
                newfeed.file = element['file'];
                newfeed.employeeId = element['employeeId'];

                listNewfeed.add(newfeed);
              })
            });
    listNewfeed.forEach((element) async {
      Employee employee =
          Employee("", "", "", "", "", "", "", "", "", "", "");
      Post post = Post(
          element.id, employee, element.content, element.time, element.file);
      FirebaseFirestore.instance
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

  _buildNewfeed(BuildContext context, Post post) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1.0, color: Colors.white24)),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0, top: 10),
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(140),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(140)),
                    height: 58,
                    width: 60,
                    child: Stack(
                      children: <Widget>[
                        Container(
                            height: 78,
                            width: 74,
                            margin: const EdgeInsets.only(
                                left: 0.0, right: 0, top: 0, bottom: 0),
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(140)),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                post.employee.image,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 13),
                  child: Text(
                    post.employee.name,
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    post.time,
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                        letterSpacing: 1,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    post.employee.departmentName,
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        letterSpacing: 1,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ]),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Text(
              post.content,
              style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 15,
                  letterSpacing: 1,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.justify,
            ),
          ),
          if (post.file != 'file.pdf')
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0, top: 15),
              child: Material(
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                  elevation: 6,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(1),
                    ),
                    child: Stack(children: [
                      Image.network(post.file),
                    ]),
                  )),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(top: 2, left: 28.0),
              //   child: Row(
              //     children: [
              //     ],
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 18, left: 15),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mode_comment),
                      iconSize: 25,
                      onPressed: () {
                        _modalBottomSheetAddQuestion(post);
                      },
                    ),
                    Text(
                      'Đặt câu hỏi',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          letterSpacing: 1,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _modalBottomSheetAddQuestion(post) {
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        context: context,
        builder: (BuildContext contetxt) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
            return SizedBox(
              height: 600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                    const Text(
                      "Gửi thắc mắc về bài đăng",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                      width: 340,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 4,
                          )),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: value_doituong,
                          hint: const Text("Vui lòng chin đối tượng"),
                          iconSize: 36,
                          items: item_doituong.map(buildMenuItem).toList(),
                          onChanged: (value) {
                            setStateKhoa(() {
                              setState(() {
                                value_doituong = value;
                              });
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                        width: 340,
                        child: StreamBuilder(
                          stream: informationControl,
                          builder: (context, snapshot) => TextField(
                            controller: _informationController,
                            decoration: InputDecoration(
                                labelText: "Phương thức liên hệ",
                                hintText: 'Nhập Email/SĐT của bạn',
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.blueAccent,
                                      width: 1,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.blue, width: 4))),
                          ),
                        )),
                    Container(
                      width: 340,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                      child: StreamBuilder(
                        stream: questionControl,
                        builder: (context, snapshot) => TextField(
                          controller: _questionController,
                          maxLines: 50,
                          minLines: 7,
                          maxLength: 3000,
                          decoration: InputDecoration(
                              hintMaxLines: 5,
                              helperMaxLines: 5,
                              labelText: "Đặt câu hỏi",
                              hintText: 'Nhập câu hỏi của bạn',
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.blueAccent,
                                    width: 1,
                                  )),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 4))),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          importPdf();
                        },
                        icon: const Icon(AppIcons.file_pdf)),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _onSendQuestionClicked(post);
                                print('press save');
                              },
                              label: const Text(
                                'Gửi',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              icon: const Icon(Icons.mail_outline_rounded),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blueAccent),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(10)),
                          Expanded(
                              child: ElevatedButton.icon(
                            onPressed: () => {Navigator.pop(context)},
                            label: const Text(
                              'Thoát',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            icon: const Icon(Icons.cancel_presentation),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blueAccent),
                          )),
                          const Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 30)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  late PlatformFile file;
  bool had_file = false;
  importPdf() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf']);
    if (result == null) return;
    setState(() {
      file = result.files.first as PlatformFile;
      had_file = true;
    });
  }

  String pdf_url = "file.pdf";
  uploadPdf() async {
    if (had_file) {
      File fileForFirebase = File(file.path!);
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("pdf/" + file.name);
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

  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  final StreamController _informationControl = StreamController.broadcast();
  final StreamController _questionControl = StreamController.broadcast();

  Stream get informationControl => _informationControl.stream;
  Stream get questionControl => _questionControl.stream;

  @override
  void dispose() {
    _questionControl.close();
    _informationControl.close();
    super.dispose();
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("user")
            .where("userId", isEqualTo: currentUser.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }
          // TODO: implement build
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text("UTE APP"),
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const MessengerPage()));
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
                    accountName: Text(current_user.name!= null ? current_user.name : 'abc'),
                    accountEmail: Text(current_user.email!),
                    arrowColor: Colors.redAccent,
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(current_user.image!),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyInfo()));
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUniversity()));
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
                                            Icons.school,
                                            color: Color(0xff757575),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 22,
                                        margin: const EdgeInsets.only(left: 20),
                                        child: const Text(
                                          'About UTE',
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
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString("id", "");
                      await FirebaseAuth.instance.signOut();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));

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
                  )
                ],
              ),
            ),
            body: SafeArea(
              // minimum: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
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
