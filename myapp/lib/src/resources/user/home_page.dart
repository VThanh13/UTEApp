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
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser!;
  UserModel current_user = UserModel();
  bool isLoading = true;
  Future<void> reLoad() async {
    setState(() {
      isLoading = true;
      listPost = [];
    });
    await getListPost();
    isLoading = false;
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

  cacheCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("id", current_user.id!);
    await prefs.setString("name", current_user.name!);
    await prefs.setString("email", current_user.email!);
    await prefs.setString("image", current_user.image!);
    await prefs.setString("password", current_user.password!);
    await prefs.setString("phone", current_user.phone!);
    await prefs.setString("group", current_user.group!);
    await prefs.setString("status", current_user.status!);
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
          current_user.id!,
          "Post ${post.content}",
          timeString,
          "Chưa trả lời",
          _informationController.text,
          post.employee.departmentId,
          post.employee.category[0],
          current_user.group!,
          "public",
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
      Function onSucces) {
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
      onSucces();
      sendQuestion(time, pdf_url, _questionController.text, id, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MessengerPage()));
      });
    }).catchError((err) {});
  }

  void sendQuestion(String time, String file, String content, String roomId,
      Function onSucces) {
    var ref = FirebaseFirestore.instance.collection('questions');
    String id = ref.doc().id;
    ref.doc(id).set({
      'id': id,
      'time': time,
      'file': file,
      'content': content,
      'room_id': roomId,
    }).then((value) {
      onSucces();
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
    List<NewfeedModel> listNewfeed = [];
    await FirebaseFirestore.instance
        .collection('newfeed')
        .get()
        .then((value) => {
              setState(() {
                value.docs.forEach((element) {
                  NewfeedModel newfeed = NewfeedModel();
                  newfeed.id = element['id'];
                  newfeed.content = element['content'];
                  newfeed.time = element['time'];
                  newfeed.file = element['file'];
                  newfeed.employeeId = element['employeeId'];

                  listNewfeed.add(newfeed);
                });
              })
            });
    listNewfeed.forEach((element) async {
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
  int _numItems = 10;
  bool _isLoadingMore = false;

  _buildNewFeed(BuildContext context, Post post) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
          InkWell(
            onTap: () {
              _modalBottomSheetAddQuestion(post);
            },
            child: Container(
              height: 30,
              margin: const EdgeInsets.only(top: 5),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'You have question?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 15, 0),
                    child: Icon(Icons.send_sharp),
                  )
                ],
              ),
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
                height: 600,
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
                          "You have question for this post",
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
                              controller: _informationController,
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
                                    //_onSendQuestionClicked(post);
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
                                  },
                                  label: const Text(
                                    'Send',
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
                                onPressed: () => {},
                                label: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
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
      file = result.files.first;
      had_file = true;
    });
  }

  String pdf_url = "file.pdf";
  uploadPdf() async {
    if (had_file) {
      File fileForFirebase = File(file.path!);
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("pdf/${file.name}");
      UploadTask uploadTask = ref.putFile(fileForFirebase);
      await uploadTask.whenComplete(() async {
        var url = await ref.getDownloadURL();
        pdf_url = url.toString();
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

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    reLoad();
    _numItems = 10;
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _numItems += 10;
      });
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
                    accountName: Text(current_user.name ?? 'abc'),
                    accountEmail: Text(current_user.email!),
                    arrowColor: Colors.redAccent,
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(current_user.image!),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyInfo()));
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
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutUniversity()));
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
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString("id", "");
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
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
                    Visibility(
                      visible: isLoading,
                      replacement: RefreshIndicator(
                        onRefresh: reLoad,
                        child: Visibility(
                          visible: listPost.isNotEmpty,
                          replacement: const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 200),
                              child: Text(
                                'No post found!',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.9,
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: listPost.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
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
              ),
            ),
          );
        });
  }
}
