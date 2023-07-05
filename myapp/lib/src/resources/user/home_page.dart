import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/controller/internet_check.dart';
import 'package:myapp/src/resources/about_page/my_info.dart';
import 'package:myapp/src/resources/about_page/about_university.dart';
import 'package:myapp/src/resources/login_screen.dart';
import 'package:myapp/src/resources/user/search_post.dart';
import 'messenger_page.dart';
import 'package:myapp/src/models/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/NewfeedModel.dart';
import '../dialog/loading_dialog.dart';

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

  @override
  int get hashCode => Object.hash(id, employee, content, time, file);

  @override
  bool operator ==(Object other) {

    return  other.hashCode == hashCode;
  }
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

class _HomePageState extends State<HomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser!;
  UserModel userModel = UserModel();
  bool isLoading = true;
  Future<void> reLoad() async {
    setState(() {
      isLoading = true;
      listPost = [];
    });
    await getListPost();
    isLoading = false;
  }

  InternetCheck internetCheck = InternetCheck();

  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: currentUser.uid)
        .get()
        .then((value) => {
              setState(() {
                userModel.id = value.docs.first['userId'];
                userModel.name = value.docs.first['name'];
                userModel.email = value.docs.first['email'];
                userModel.image = value.docs.first['image'];
                userModel.password = value.docs.first['password'];
                userModel.phone = value.docs.first['phone'];
                userModel.group = value.docs.first['group'];
                userModel.status = value.docs.first['status'];
              }),
            });
  }

  cacheCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("id", userModel.id!);
    await prefs.setString("name", userModel.name!);
    await prefs.setString("email", userModel.email!);
    await prefs.setString("image", userModel.image!);
    await prefs.setString("password", userModel.password!);
    await prefs.setString("phone", userModel.phone!);
    await prefs.setString("group", userModel.group!);
    await prefs.setString("status", userModel.status!);
  }

  var departmentName = {};

  _onSendQuestionClicked(Post post) async {
    var isvalid =
        isValid(_informationController.text, _questionController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadPdf();
    if (isvalid) {
      if (!mounted) return;
      LoadingDialog.showLoadingDialog(context, "Please Wait...");
      createChatRoom(
          userModel.id!,
          "Post ${post.content}",
          timeString,
          "Chưa trả lời",
          _informationController.text,
          post.employee.departmentId,
          post.employee.category[0],
          userModel.group!,
          "private",
          () {});
    }
    return 0;
  }

  void createChatRoom(
      String userId,
      String title,
      String time,
      String status,
      String information,
      String departmentId,
      String category,
      String group,
      String mode,
      Function onSuccess) {
    var ref = FirebaseFirestore.instance.collection('chat_room');
    String id = ref.doc().id;
    ref.doc(id).set({
      'room_id': id,
      'user_id': userId,
      'title': title,
      'time': time,
      'status': status,
      'information': information,
      'department': departmentId,
      'group': group,
      'category': category,
      'mode': mode,
    }).then((value) {
      onSuccess();
      sendQuestion(time, pdfUrl, _questionController.text, id, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MessengerPage()));
      });
    }).catchError((err) {});
  }

  void sendQuestion(String time, String file, String content, String roomId,
      Function onSuccess) {
    var ref = FirebaseFirestore.instance.collection('questions');
    String id = ref.doc().id;
    ref.doc(id).set({
      'id': id,
      'time': time,
      'file': file,
      'content': content,
      'room_id': roomId,
    }).then((value) {
      onSuccess();
    }).catchError((err) {});
  }

  bool isValid(String information, String question) {
    if (information.isEmpty) {
      _informationControl.sink.addError("Insert contact method");
      return false;
    }
    _informationControl.sink.add("");
    if (question.isEmpty) {
      _questionControl.sink.addError("Insert question");
      return false;
    }
    _questionControl.sink.add("");

    return true;
  }

  List<Post> listPost = [];
  getListPost() async {
    await getDepartmentName();
    List<NewfeedModel> listNewFeed = [];
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

                  listNewFeed.add(newFeed);
                }
              })
            });
    // ignore: avoid_function_literals_in_foreach_calls
    listNewFeed.forEach((element) async {
      Employee employee = Employee("", "", "", "", "", "", "", "", [], "", "");
      Post post = Post(element.id!, employee, element.content!, element.time!,
          element.file!);
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
                  employee.category =
                      value.docs.first['category'].cast<String>();
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

  final ScrollController _scrollController = ScrollController();
  String nameEmployee = '';
  String idEmployee = '';
  String departmentEmployee = '';

  _buildNewFeed(BuildContext context, Post post) {
    nameEmployee = post.employee.name;
    idEmployee = post.employee.id;
    departmentEmployee = post.employee.departmentName;
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
                    children: [
                      Text(
                        post.employee.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        post.time,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        post.employee.departmentName,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return CupertinoActionSheet(
                          title: const Text(
                            'Choose options',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          actions: [
                            CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                                _modelBottomSheetSendMessage();
                              },
                              child: const Text(
                                'Send message',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                                _modalBottomSheetAddQuestion(post);
                              },
                              child: const Text(
                                'Have question',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      });
                },
                icon: const Icon(
                  Icons.more_horiz,
                  size: 30,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Divider(
              height: 0,
              color: Color(0xffAAAAAA),
              indent: 0,
              thickness: 1,
            ),
          ),
          const SizedBox(
            height: 10,
          )
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
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
            return GestureDetector(
              onTap: () {
                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
              },
              child: SizedBox(
                height: 520,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                        const Text(
                          "You have question for this post?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        const Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                          width: double.infinity,
                          child: StreamBuilder(
                            stream: informationControl,
                            builder: (context, snapshot) => TextField(
                              controller: _informationController
                                ..text = userModel.email!,
                              decoration: InputDecoration(
                                  labelText: "Contact method",
                                  hintText: 'Insert your Email/Phone',
                                  errorText: snapshot.hasError
                                      ? snapshot.error.toString()
                                      : null,
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
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(20, 20, 20, 15),
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
                                  errorText: snapshot.hasError
                                      ? snapshot.error.toString()
                                      : null,
                                  labelText: "Send question",
                                  hintText: 'Insert your question',
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
                        InkWell(
                          child: Container(
                            height: 70,
                            margin: const EdgeInsets.fromLTRB(100, 0, 110, 0),
                            width: double.infinity,
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(25, 5, 0, 5),
                                  child: Icon(
                                    AppIcons.file_pdf,
                                    color: Colors.red,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                                  child: Text(
                                    'Attached files',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey),
                                  ),
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            importPdf();
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if(internetCheck.isInternetConnect == true){
                                      try {
                                        if (_onSendQuestionClicked(post)) {
                                          setState(() {
                                            _informationController.text = '';
                                            _questionController.text = '';
                                          });
                                        } else {
                                          setState(() {
                                            _informationController.text = '';
                                            _questionController.text = '';
                                          });
                                          Navigator.pop(context);
                                          showErrorMessage(
                                              'Send question failed');
                                        }
                                      } catch (e) {
                                        //
                                      }
                                    }
                                    else{
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
                                    'Send',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  icon: const Icon(Icons.mail_outline_rounded),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(10)),
                              Expanded(
                                  child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                label: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                icon: const Icon(Icons.cancel_presentation),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent),
                              )),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 30)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  _onSendMessageClicked() async {
    var isvalid =
        isValid(_informationController.text, _questionController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadPdf();
    if (isvalid) {
      if (!mounted) return;
      LoadingDialog.showLoadingDialog(context, "Please Wait...");
      createChatRoom(
          userModel.id!,
          "Send $nameEmployee",
          timeString,
          "Chưa trả lời",
          _informationController.text,
          departmentEmployee,
          idEmployee,
          userModel.group!,
          "to employee",
          () {});
    }
    return 0;
  }

  _modelBottomSheetSendMessage() {
    showModalBottomSheet(
        isScrollControlled: true,
        // constraints: BoxConstraints.loose(Size(
        //     MediaQuery.of(context).size.width,
        //     MediaQuery.of(context).size.height * 0.75)),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
            return SizedBox(
              height: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 20)),
                    const Text(
                      "Send Message",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                      width: 340,
                      child: StreamBuilder(
                        stream: informationControl,
                        builder: (context, snapshot) => TextField(
                          controller: _informationController
                            ..text = userModel.email!,
                          decoration: InputDecoration(
                            labelText: "Contact method",
                            hintText: 'Insert your Email/Phone',
                            errorText: snapshot.hasError
                                ? snapshot.error.toString()
                                : null,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1,
                                )),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
                            labelText: "Send question",
                            hintText: 'Insert your question',
                            errorText: snapshot.hasError
                                ? snapshot.error.toString()
                                : null,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.blueAccent,
                                  width: 1,
                                )),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      child: Container(
                        height: 70,
                        margin: const EdgeInsets.fromLTRB(100, 0, 110, 0),
                        width: double.infinity,
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(25, 5, 0, 5),
                              child: Icon(
                                AppIcons.file_pdf,
                                color: Colors.red,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                              child: Text(
                                'Attached files',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey),
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        importPdf();
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if(internetCheck.isInternetConnect == true){
                                  _onSendMessageClicked();
                                  Navigator.pop(context);
                                }
                                else{
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
                                'Send',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              icon: const Icon(Icons.mail_outline_rounded),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          Expanded(
                              child: ElevatedButton.icon(
                            onPressed: () => {Navigator.pop(context)},
                            label: const Text(
                              'Cancel',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            icon: const Icon(Icons.cancel_presentation),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent),
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
  bool hadFile = false;
  importPdf() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf']);
    if (result == null) return;
    setState(() {
      file = result.files.first;
      hadFile = true;
    });
  }

  String pdfUrl = "file.pdf";
  uploadPdf() async {
    if (hadFile) {
      File fileForFirebase = File(file.path!);
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("pdf/${file.name}");
      UploadTask uploadTask = ref.putFile(fileForFirebase);
      await uploadTask.whenComplete(() async {
        var url = await ref.getDownloadURL();
        pdfUrl = url.toString();
        // ignore: body_might_complete_normally_catch_error
      }).catchError((onError) {
        //
      });
    }
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

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    reLoad();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {});
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blueAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text("UTE APP"),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    if (internetCheck.isInternetConnect == true) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const MessengerPage()));
                    } else {
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
                IconButton(
                  onPressed: () {
                    if (internetCheck.isInternetConnect == true) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const SearchPostScreen()));
                    } else {
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
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(userModel.name ?? 'abc'),
                    accountEmail: Text(userModel.email!),
                    arrowColor: Colors.redAccent,
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(userModel.image!),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if(internetCheck.isInternetConnect == true){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyInfo()));
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
                                            Icons.manage_accounts_outlined,
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
                    onTap: () {
                      if(internetCheck.isInternetConnect == true){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutUniversity()));
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
                      if(internetCheck.isInternetConnect == true){
                        SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        await prefs.setString("id", "");
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()));
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
                                            Icons.logout,
                                            color: Color(0xff757575),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 22,
                                        margin: const EdgeInsets.only(left: 20),
                                        child: const Text(
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
                ],
              ),
            ),
            body: SafeArea(
              child: internetCheck.isInternetConnect == true
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Visibility(
                            visible: isLoading,
                            replacement: RefreshIndicator(
                              onRefresh: reLoad,
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.9,
                                      child: ListView.builder(
                                        key: UniqueKey(),
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: listPost.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return _buildNewFeed(
                                                context, listPost[index]);
                                          }),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 200),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
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
          );
        });
  }
}
