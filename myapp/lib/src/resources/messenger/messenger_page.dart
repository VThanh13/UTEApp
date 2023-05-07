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
import 'package:myapp/src/resources/home_page.dart';
import 'package:myapp/src/resources/messenger/detail_question.dart';
import 'package:myapp/src/resources/messenger/view_employee_byuser.dart';
import '../../models/ChatRoomModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';

class MessengerPage extends StatefulWidget {
  const MessengerPage({super.key});

  @override
  State<MessengerPage> createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  CollectionReference derPart =
      FirebaseFirestore.instance.collection('departments');
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? value;
  String? valueKhoa;
  String? value4;
  var selectedDerpartments;
  String? value2;
  String? valueVanDe;
  var departmentsItems = [];
  var itemDoiTuong = [
    'Học sinh THPT',
    'Sinh viên',
    'Phụ huynh',
    'Cựu sinh viên',
    'Khác'
  ];
  List<dynamic> listT = [];
  int pageIndex = 0;

  FirebaseAuth auth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser!;
  UserModel currentUserR = UserModel("", " ", "", "", "", "", "", "");

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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

  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: currentUser.uid)
        .get()
        .then((value) => {
              setState(() {
                currentUserR.id = value.docs.first['userId'];
                currentUserR.name = value.docs.first['name'];
                currentUserR.email = value.docs.first['email'];
                currentUserR.image = value.docs.first['image'];
                currentUserR.password = value.docs.first['password'];
                currentUserR.phone = value.docs.first['phone'];
                currentUserR.group = value.docs.first['group'];
                currentUserR.status = value.docs.first['status'];
              })
            });
    await getChatRoomByUser();
    await getAllChatRoom();
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
  var departmentName = {};
  getDepartmentName() async {
    await FirebaseFirestore.instance
        .collection('departments')
        .get()
        .then((value) => {
              setState(() {
                for (var element in value.docs) {
                  departmentName[element.id] = element["name"];
                  listDepartment.add(element['name']);
                }
              })
            });
  }

  List<ChatRoomModel> listPublicChatRoom = [];
  getAllChatRoom() async {
    await FirebaseFirestore.instance
        .collection('chat_room')
        .where('mode', isEqualTo: 'public')
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                ChatRoomModel chatRoom =
                    ChatRoomModel("", "", "", "", "", "", "", "", "", "");
                chatRoom.id = element['room_id'];
                chatRoom.user_id = element['user_id'];
                chatRoom.time = element['time'];
                chatRoom.title = element['title'];
                chatRoom.department = element['department'];
                chatRoom.category = element['category'];
                chatRoom.information = element['information'];
                chatRoom.group = element['group'];
                chatRoom.mode = element['mode'];
                chatRoom.status = element['status'];

                listPublicChatRoom.add(chatRoom);
              })
            });
  }

  _buildAllChatRoom() {
    listPublicChatRoom.sort((a, b) => DateFormat("dd-MM-yyyy HH:mm:ss")
        .parse(b.time)
        .compareTo(DateFormat("dd-MM-yyyy HH:mm:ss").parse(a.time)));

    List<Widget> chatList = [];
    listPublicChatRoom.forEach((ChatRoomModel chatRoom) {
      chatList.add(GestureDetector(
        // onTap: () {
        //   Navigator.push(
        //       context,
        //       new MaterialPageRoute(
        //           builder: (BuildContext context) =>
        //               DetailQuestion(question: question)));
        // },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
                margin: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      chatRoom.title,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      chatRoom.time,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(chatRoom.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: chatRoom.status == "Chưa trả lời"
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
    return Column(children: chatList);
  }

  List<ChatRoomModel> listChatRoomByUser = [];
  getChatRoomByUser() async {
    await FirebaseFirestore.instance
        .collection('chat_room')
        .where('user_id', isEqualTo: currentUserR.id)
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                ChatRoomModel chatRoom =
                    ChatRoomModel("", "", "", "", "", "", "", "", "", "");
                chatRoom.id = element['room_id'];
                chatRoom.user_id = element['user_id'];
                chatRoom.time = element['time'];
                chatRoom.title = element['title'];
                chatRoom.department = element['department'];
                chatRoom.category = element['category'];
                chatRoom.information = element['information'];
                chatRoom.group = element['group'];
                chatRoom.mode = element['mode'];
                chatRoom.status = element['status'];

                listChatRoomByUser.add(chatRoom);
              })
            });
  }

  _buildChatRoomByUser() {
    listChatRoomByUser.sort((a, b) => DateFormat("dd-MM-yyyy HH:mm:ss")
        .parse(b.time)
        .compareTo(DateFormat("dd-MM-yyyy HH:mm:ss").parse(a.time)));

    List<Widget> chatList = [];
    listChatRoomByUser.forEach((ChatRoomModel chatRoom) {
      chatList.add(GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      DetailQuestion(chatRoom: chatRoom)));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
                margin: const  EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      chatRoom.title,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      chatRoom.time,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(chatRoom.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: chatRoom.status == "Chưa trả lời"
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
    return Column(children: chatList);
  }

  List<EmployeeModel> listEmployee = [];
  getEmployeeData() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                EmployeeModel eModel =
                    EmployeeModel("", " ", "", "", "", "", "", "", "", "");
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
      margin: const EdgeInsets.all(10.0),
      width: 320,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            width: 1.0,
            color: Colors.blueAccent,
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.tealAccent,
              child: CircleAvatar(
                backgroundImage: NetworkImage(employeeModel.image!),
                radius: 28,
              ),
            ),
          ),
          Expanded(
              child: Container(
            margin: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  employeeModel.name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  employeeModel.roles,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  departmentName[employeeModel.department],
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )),
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 48,
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              icon: const Icon(AppIcons.user),
              iconSize: 30,
              color: Colors.white70,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ViewEmployeeByUser(
                            employee: employeeModel, users: currentUserR)));
              },
            ),
          )
        ],
      ),
    );
  }

  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  final StreamController _informationControl = StreamController.broadcast();
  final StreamController _titleControl = StreamController.broadcast();
  final StreamController _questionControl = StreamController.broadcast();

  Stream get informationControl => _informationControl.stream;
  Stream get titleControl => _titleControl.stream;
  Stream get questionControl => _questionControl.stream;

  bool isValid(String information, String title, String question) {
    if (information.isEmpty) {
      _informationControl.sink.addError("Nhập thông tin liên lạc");
      return false;
    }

    if (title.isEmpty) {
      _titleControl.sink.addError("Nhập tiêu đề");
      return false;
    }
    if (question.isEmpty) {
      _questionControl.sink.addError("Nhập câu hỏi");
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("departments").get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }

          return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("departments")
                  .where("name", isEqualTo: valueKhoa)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator()),
                  );
                }
                // TODO: implement build
                return Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                       HomePage()));
                        }),
                    title: const Text("Tin nhắn"),
                    backgroundColor: Colors.blueAccent,
                  ),
                  bottomNavigationBar: getFooter(),
                  floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        if (currentUserR.id != "") {
                          modalBottomSheetQuestion();
                        }
                      },
                      backgroundColor: Colors.blue,
                      child: const Icon(
                        Icons.add,
                        size: 25,
                      )
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
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                          ),
                          StreamBuilder<QuerySnapshot>(
                              stream: derPart.snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasError) {
                                  const Text("Loading");
                                } else {
                                  derPart
                                      .get()
                                      .then((QuerySnapshot querySnapshot) {
                                    querySnapshot.docs.forEach((doc) {
                                    });
                                  });
                                }
                                return const Text("");
                              }),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text(
                                  'Đội ngũ tư vấn viên',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0),
                                ),
                              ),
                              SizedBox(
                                height: 120.0,
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.only(left: 10.0),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: listEmployee.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
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
  }

  Widget getQuestion() {
    if (pageIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Câu hỏi của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0),
            ),
          ),
          _buildChatRoomByUser()
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Tất cả câu hỏi',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0),
            ),
          ),
          _buildAllChatRoom()
        ],
      );
    }
  }

  modalBottomSheetQuestion() {
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
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
            return Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                  child: Text(
                    'Đặt câu hỏi',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                              Container(
                                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                  width: 340,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.blueAccent, width: 4),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: valueKhoa,
                                      hint: const Text(
                                          "Vui lòng chọn đơn vị để hỏi"),
                                      iconSize: 36,
                                      items: render(listDepartment),
                                      onChanged: (value) async {
                                        final List<dynamic> listProblem =
                                            await getDataDropdownProblem(
                                                value);
                                        setStateKhoa(() {
                                          setState(() {
                                            valueVanDe = null;
                                            valueKhoa = value;
                                            listT = listProblem;
                                          });
                                        });
                                      },
                                    ),
                                  )),
                              Container(
                                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                  width: 340,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.blueAccent, width: 4),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: valueVanDe,
                                      hint: const Text(
                                          "Vui lòng chọn vấn đề để hỏi"),
                                      iconSize: 36,
                                      items: renderR(listT),
                                      onChanged: (value) {
                                        setStateKhoa(() {
                                          setState(() {
                                            valueVanDe = value;
                                          });
                                        });
                                      },
                                    ),
                                  )),
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
                                  )),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                width: 340,
                                child: StreamBuilder(
                                  stream: titleControl,
                                  builder: (context, snapshot) => TextField(
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                        labelText: "Tiêu đề",
                                        hintText: 'Nhập Tiêu đề',
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
                              Container(
                                width: 340,
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                child: StreamBuilder(
                                  stream: questionControl,
                                  builder: (context, snapshot) => TextField(
                                    controller: _questionController,
                                    maxLines: 50,
                                    minLines: 10,
                                    maxLength: 3000,
                                    decoration: InputDecoration(
                                        hintMaxLines: 5,
                                        helperMaxLines: 5,
                                        labelText: "Đặt câu hỏi",
                                        hintText: 'Nhập câu hỏi của bạn',
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Colors.blueAccent,
                                              width: 1,
                                            ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Colors.blue,
                                                width: 4))),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          _onSendQuestionClicked();
                                          print('press save');
                                        },
                                        label: const Text(
                                          'Gửi',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.send_rounded),
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.blueAccent),
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.all(10)),
                                    Expanded(
                                        child: ElevatedButton.icon(
                                      onPressed: () =>
                                          {Navigator.pop(context)},
                                      label: const Text(
                                        'Thoát',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                      icon: const Icon(Icons.cancel_presentation),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.blueAccent),
                                    )),
                                    const Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0, 10, 0, 30)),
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
      Reference ref = storage.ref().child("pdf/" + file.name);
      UploadTask uploadTask = ref.putFile(fileForFirebase);
      await uploadTask.whenComplete(() async {
        var url = await ref.getDownloadURL();
        pdfUrl = url.toString();
      }).catchError((onError) {
      });
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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
  DropdownMenuItem<dynamic> buildMenuItemM(dynamic item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
  List<DropdownMenuItem<dynamic>> renderR(List<dynamic> list) {
    return list.map(buildMenuItemM).toList();
  }

  _onSendQuestionClicked() async {
    var isvalid = isValid(_informationController.text, _questionController.text,
        _titleController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadPdf();
    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      createChatRoom(
          currentUserR.id,
          _titleController.text,
          timeString,
          "Chưa trả lời",
          _informationController.text,
          valueKhoa!,
          valueVanDe!,
          currentUserR.group,
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
      String department,
      String category,
      String group,
      String mode,
      Function onSucces) {
    var ref = FirebaseFirestore.instance.collection('chat_room');
    String id = ref.doc().id;
    String departmentId = departmentName.keys
        .firstWhere((k) => departmentName[k] == department, orElse: () => null);
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
      sendQuestion(time, pdfUrl, _questionController.text, id, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MessengerPage()));
      });
    }).catchError((err) {
    });
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
    }).catchError((err) {
    });
  }
}
