import 'dart:async';
import 'dart:io';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/models/EmployeeModel.dart';
import 'package:myapp/src/models/QuestionModel.dart';
import 'package:myapp/src/resources/home_page.dart';
import 'package:myapp/src/resources/messenger/detail_question.dart';
import 'package:myapp/src/resources/messenger/view_employee_byuser.dart';

import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';

class MessengerPage extends StatefulWidget {
  @override
  _MessengerPageState createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  CollectionReference derpart =
      FirebaseFirestore.instance.collection('departments');
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? value;
  String? value_khoa;
  String? value4;
  var selectedDerpartments;
  String? value2;
  String? value_doituong;
  String? value_vande;
  var departmentsItems = [];
  var item_doituong = [
    'Học sinh THPT',
    'Sinh viên',
    'Phụ huynh',
    'Cựu sinh viên',
    'Khác'
  ];
  List<dynamic> listt = [];
  int pageIndex = 0;

  FirebaseAuth auth = FirebaseAuth.instance;
  var userr = FirebaseAuth.instance.currentUser!;
  UserModel userModel = new UserModel("", " ", "", "", "", "", "");

  @override
  void initState() {
    super.initState();
    getEmployeeData();
    getDepartmentName();
  }
  @override
  void dispose() {
    _questionControl.close();
    _titleControl.close();
    _informationControl.close();
    super.dispose();
  }

  Future<List> getDataDropdownProblem(String? value_khoa) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("departments")
        .where("name", isEqualTo: value_khoa)
        .get();

    List<dynamic> list = [];
    snapshot.docs.map((e) {
      list = (e.data() as Map)["category"];
      return list;
    }).toList();
    return list;
  }
  List<String> listDepartment = [];
  var departmentName = new Map();
  getDepartmentName() async {
    await FirebaseFirestore.instance
        .collection('departments')
        .get()
        .then((value) => {
      setState(() {
        value.docs.forEach((element) {
          departmentName[element.id] = element["name"];
          listDepartment.add(element['name']);
        });
      })
    });
  }

  List<QuestionModel> listQuestion = [];
  Future<List<QuestionModel>> getQuestionData() async {
    List<QuestionModel> list = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where('userId', isEqualTo: userr.uid)
        .get();
    snapshot.docs.map((e) {
      QuestionModel questionModel =
          new QuestionModel("", "", "", "", "", "", "", "", "", "");
      questionModel.id = e.reference.id;
      questionModel.title = (e.data() as Map)['title'];
      questionModel.content = (e.data() as Map)['content'];
      questionModel.time = (e.data() as Map)['time'];
      questionModel.department = (e.data() as Map)['department'];
      questionModel.category = (e.data() as Map)['category'];
      questionModel.status = (e.data() as Map)['status'];
      questionModel.userId = (e.data() as Map)['userId'];
      questionModel.information = (e.data() as Map)['information'];
      questionModel.file = (e.data() as Map)['file'];
      list.add(questionModel);
    }).toList();
    return list;
  }

  fillListQuestion(setState) async {
    final testlistQuestion = await getQuestionData() as List<QuestionModel>;
    setState(() {
      listQuestion = testlistQuestion;
    });
  }

  _buildQuestions(setState) {
    fillListQuestion(setState);

    List<Widget> questionsList = [];
    listQuestion.forEach((QuestionModel question) {
      questionsList.add(GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      DetailQuestion(question: question)));
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                width: 1.0,
                color: Colors.grey,
              )),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                margin: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      question.title,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      question.time,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(question.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: question.status == "Chưa trả lời"
                              ? Colors.redAccent
                              : Colors.green,
                          overflow: TextOverflow.ellipsis,
                        ))
                  ],
                ),
              ))
            ],
          ),
        ),
      ));
    });
    return Column(children: questionsList);
  }

  List<EmployeeModel> listEmployee = [];
  getEmployeeData() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                EmployeeModel eModel =
                    new EmployeeModel("", " ", "", "", "", "", "", "", "", "");
                eModel.id = element['id'];
                eModel.name = element['name'];
                eModel.email = element['email'];
                eModel.image = element['image'];
                eModel.password = element['password'];
                eModel.phone = element['phone'];
                eModel.department = element['department'];
                eModel.category = element['category'];
                eModel.roles = element['roles'];
                eModel.status = element['status'];

                listEmployee.add(eModel);
              })
            });
  }

  _buildEmployee(BuildContext context, EmployeeModel employeeModel) {
    return Container(
      margin: EdgeInsets.all(10.0),
      width: 320,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            width: 1.0,
            color: Colors.pinkAccent,
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.tealAccent,
              child: CircleAvatar(
                backgroundImage: new NetworkImage(employeeModel.image!),
                radius: 28,
              ),
            ),
          ),
          Expanded(
              child: Container(
            margin: EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  employeeModel.name,
                  style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  employeeModel.roles,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Khoa",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )),
          Container(
            margin: EdgeInsets.only(right: 10),
            width: 48,
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              icon: Icon(AppIcons.user),
              iconSize: 30,
              color: Colors.white70,
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => ViewEmployeeByUser(
                            employee: employeeModel, users: userModel)));
              },
            ),
          )
        ],
      ),
    );
  }

  TextEditingController _informationController = new TextEditingController();
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _questionController = new TextEditingController();

  StreamController _informationControl = new StreamController.broadcast();
  StreamController _titleControl = new StreamController.broadcast();
  StreamController _questionControl = new StreamController.broadcast();

  Stream get informationControl => _informationControl.stream;
  Stream get titleControl => _titleControl.stream;
  Stream get questionControl => _questionControl.stream;

  bool isValid(String information, String title, String question) {
    if (information == null || information.length == 0) {
      _informationControl.sink.addError("Nhập thông tin liên lạc");
      return false;
    }

    if (title == null || title.length == 0) {
      _titleControl.sink.addError("Nhập tiêu đề");
    }
    if (question == null || question.length == 0) {
      _questionControl.sink.addError("Nhập câu hỏi");
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("departments").get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Container(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }

          return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("departments")
                  .where("name", isEqualTo: value_khoa)
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
                          title: const Text("Tin nhắn"),
                          backgroundColor: Colors.pinkAccent,
                        ),
                        bottomNavigationBar: getFooter(),
                          floatingActionButton: FloatingActionButton(
                              onPressed: () {
                                modalBottomSheetQuestion();
                              },
                              child: Icon(
                                Icons.add,
                                size: 25,
                              ),
                              backgroundColor: Colors.pink
                            //params
                          ),
                          floatingActionButtonLocation:
                          FloatingActionButtonLocation.centerDocked,
                        body: SafeArea(
                          minimum: const EdgeInsets.only(left: 20, right: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                ),
                                StreamBuilder<QuerySnapshot>(
                                    stream: derpart.snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasError) {
                                        Text("Loading");
                                      } else {
                                        derpart.get().then(
                                            (QuerySnapshot querySnapshot) {
                                          querySnapshot.docs.forEach((doc) {
                                            print(doc["departments"]);
                                          });
                                        });
                                      }
                                      return Text("");
                                    }),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Text(
                                        'Đội ngũ tư vấn viên',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.0),
                                      ),
                                    ),
                                    Container(
                                      height: 120.0,
                                      child: ListView.builder(
                                          physics: BouncingScrollPhysics(),
                                          padding: EdgeInsets.only(left: 10.0),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: listEmployee.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            // EmployeeModel employeeModel = listEmployee[index];
                                            return _buildEmployee(
                                                context, listEmployee[index]);
                                          }),
                                    )
                                  ],
                                ),
                                getQuestion(),

                              ],
                            ),
                          ),
                        ),
                      );
                    });
              });
        });
  }
  Widget getQuestion(){
    if(pageIndex==0){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 20.0),
            child: Text(
              'Câu hỏi của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0),
            ),
          ),
          _buildQuestions(setState)
        ],
      );
    }
    else{
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 20.0),
            child: Text(
              'Tất cả câu hỏi',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0),
            ),
          ),
          _buildQuestions(setState)
        ],
      );
    }
  }
  modalBottomSheetQuestion(){
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(
            Size(
                MediaQuery.of(context)
                    .size
                    .width,
                MediaQuery.of(context)
                    .size
                    .height *
                    0.75)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder:
              (BuildContext context,
              StateSetter
              setStateKhoa) {
            return Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                    EdgeInsets.fromLTRB(
                        5, 20, 5, 10),
                    child: Text(
                      'Đặt câu hỏi',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                          FontWeight
                              .w600,
                          letterSpacing:
                          1.0),
                    ),
                  ),
                  SingleChildScrollView(
                    physics:
                    BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(
                              context)
                              .size
                              .height *
                              0.65,
                          child:
                          SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .start,
                              children: <
                                  Widget>[
                                Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        0,
                                        10,
                                        0,
                                        10)),
                                Container(
                                    margin: EdgeInsets.fromLTRB(
                                        0,
                                        10,
                                        0,
                                        15),
                                    width:
                                    340,
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                        12,
                                        vertical:
                                        4),
                                    decoration:
                                    BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.pinkAccent,
                                          width: 4),
                                    ),
                                    child:
                                    DropdownButtonHideUnderline(
                                      child:
                                      DropdownButton(
                                        isExpanded:
                                        true,
                                        value:
                                        value_khoa,
                                        hint:
                                        new Text("Vui lòng chọn đơn vị để hỏi"),
                                        iconSize:
                                        36,
                                        items:
                                        render(listDepartment),
                                        onChanged:
                                            (value) async {
                                          final List<dynamic> list_problem = await getDataDropdownProblem(value) as List;
                                          setStateKhoa(() {
                                            setState(() {
                                              this.value_vande = null;
                                              this.value_khoa = value;
                                              this.listt = list_problem;
                                            });
                                          });
                                        },
                                      ),
                                    )),
                                Container(
                                    margin: EdgeInsets.fromLTRB(
                                        0,
                                        10,
                                        0,
                                        15),
                                    width:
                                    340,
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                        12,
                                        vertical:
                                        4),
                                    decoration:
                                    BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.pinkAccent,
                                          width: 4),
                                    ),
                                    child:
                                    DropdownButtonHideUnderline(
                                      child:
                                      DropdownButton(
                                        isExpanded:
                                        true,
                                        value:
                                        value_vande,
                                        hint:
                                        new Text("Vui lòng chọn vấn đề để hỏi"),
                                        iconSize:
                                        36,
                                        items:
                                        renderr(listt),
                                        onChanged:
                                            (value) {
                                          setStateKhoa(() {
                                            setState(() {
                                              this.value_vande = value;
                                            });
                                          });
                                        },
                                      ),
                                    )),
                                Container(
                                    margin: EdgeInsets.fromLTRB(
                                        0,
                                        10,
                                        0,
                                        15),
                                    width:
                                    340,
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                        12,
                                        vertical:
                                        4),
                                    decoration:
                                    BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.pinkAccent,
                                          width: 4),
                                    ),
                                    child:
                                    DropdownButtonHideUnderline(
                                      child:
                                      DropdownButton<String>(
                                        isExpanded:
                                        true,
                                        value:
                                        value_doituong,
                                        hint:
                                        new Text("Vui lòng chọn đối tượng"),
                                        iconSize:
                                        36,
                                        items:
                                        item_doituong.map(buildMenuItem).toList(),
                                        onChanged:
                                            (value) {
                                          setStateKhoa(() {
                                            setState(() {
                                              this.value_doituong = value;
                                            });
                                          });
                                        },
                                      ),
                                    )),
                                Container(
                                    margin: EdgeInsets.fromLTRB(
                                        0,
                                        10,
                                        0,
                                        15),
                                    width:
                                    340,
                                    child:
                                    StreamBuilder(
                                      stream:
                                      informationControl,
                                      builder: (context, snapshot) =>
                                          TextField(
                                            controller:
                                            _informationController,
                                            decoration: InputDecoration(
                                                labelText: "Phương thức liên hệ",
                                                hintText: 'Nhập Email/SĐT của bạn',
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(
                                                      color: Colors.pinkAccent,
                                                      width: 1,
                                                    )),
                                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.pink, width: 4))),
                                          ),
                                    )),
                                Container(
                                  margin: EdgeInsets
                                      .fromLTRB(
                                      0,
                                      10,
                                      0,
                                      15),
                                  width:
                                  340,
                                  child:
                                  StreamBuilder(
                                    stream:
                                    titleControl,
                                    builder:
                                        (context, snapshot) =>
                                        TextField(
                                          controller:
                                          _titleController,
                                          decoration: InputDecoration(
                                              labelText: "Tiêu đề",
                                              hintText: 'Nhập Tiêu đề',
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.pinkAccent,
                                                    width: 1,
                                                  )),
                                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.pink, width: 4))),
                                        ),
                                  ),
                                ),
                                Container(
                                  width:
                                  340,
                                  margin: EdgeInsets
                                      .fromLTRB(
                                      0,
                                      10,
                                      0,
                                      15),
                                  child:
                                  StreamBuilder(
                                    stream:
                                    questionControl,
                                    builder:
                                        (context, snapshot) =>
                                        TextField(
                                          controller:
                                          _questionController,
                                          maxLines:50,
                                          minLines: 10,
                                          maxLength:3000,
                                          decoration: InputDecoration(
                                              hintMaxLines: 5,
                                              helperMaxLines: 5,
                                              labelText: "Đặt câu hỏi",
                                              hintText: 'Nhập câu hỏi của bạn',
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.pinkAccent,
                                                    width: 1,
                                                  )),
                                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.pink, width: 4))),
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
                                  padding:
                                  EdgeInsets.all(
                                      10),
                                  child:
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: <
                                        Widget>[
                                      Expanded(
                                        child:
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            _onSendQuestionClicked();
                                            print('press save');
                                          },
                                          label: Text(
                                            'Gửi',
                                            style: TextStyle(fontSize: 16, color: Colors.white),
                                          ),
                                          icon: Icon(Icons.send_rounded),
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.pinkAccent
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.all(10)),
                                      Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => {Navigator.pop(context)},
                                            label: Text(
                                              'Thoát',
                                              style: TextStyle(fontSize: 16, color: Colors.white),
                                            ),
                                            icon: Icon(Icons.cancel_presentation),
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.pinkAccent
                                            ),)),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, 10, 0, 30)),
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
                ],
              ),
            );
          });
        });
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
  Widget getFooter() {
    List<IconData> iconItems = [
      Icons.message,
      Icons.question_answer_outlined,
    ];
    return AnimatedBottomNavigationBar(
      activeColor: Colors.blue,
      splashColor: Colors.grey,
      inactiveColor: Colors.black.withOpacity(0.5),
      icons: iconItems,
      activeIndex: pageIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 10,
      iconSize: 25,
      rightCornerRadius: 10,
      onTap: (index) {
        selectedTab(index);
      },
      //other params
    );
  }
  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }

  List<DropdownMenuItem<String>> render(List<String> list) {
    return list.map(buildMenuItem).toList();
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
  DropdownMenuItem<dynamic> buildMenuItemm(dynamic item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
  List<DropdownMenuItem<dynamic>> renderr(List<dynamic> list) {
    return list.map(buildMenuItemm).toList();
  }

  _onSendQuestionClicked() async {
    var isvalid = isValid(_informationController.text, _questionController.text,
        _titleController.text);
    var time = DateTime.now();
    String timestring = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadPdf();
    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      sendQuestion(
          userModel.id,
          _titleController.text,
          timestring,
          "Chưa trả lời",
          _informationController.text,
          pdf_url,
          value_khoa!,
          _questionController.text,
          value_vande!,
          value_doituong!, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      });
    }
    return 0;
  }

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
    String departmentId = departmentName.keys.firstWhere((k) => departmentName[k] == department, orElse: () => null);
    ref.doc(id).set({
      'id': id,
      'userId': userId,
      'title': title,
      'time': time,
      'status': status,
      'information': information,
      'file': file,
      'department': departmentId,
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
}
