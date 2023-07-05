import 'dart:async';
import 'dart:io';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/models/EmployeeModel.dart';
import 'package:myapp/src/resources/user/home_page.dart';
import 'package:myapp/src/resources/user/search_counselors.dart';
import 'package:myapp/src/resources/user/view_employee_by_user.dart';
import 'detail_question.dart';
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
  String? valueDepart;

  String? valueVanDe;
  var departmentsItems = [];
  List<dynamic> listT = [];
  int pageIndex = 0;

  FirebaseAuth auth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser!;
  UserModel user = UserModel();
  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: currentUser.uid)
        .get()
        .then((value) => {
              setState(() {
                user.id = value.docs.first['userId'];
                user.name = value.docs.first['name'];
                user.email = value.docs.first['email'];
                user.image = value.docs.first['image'];
                user.password = value.docs.first['password'];
                user.phone = value.docs.first['phone'];
                user.group = value.docs.first['group'];
                user.status = value.docs.first['status'];
              })
            });
    await getChatRoomByUser();
    await getAllChatRoom();
  }

  Future<List> getDataDropdownProblem(String? valueDepartment) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("departments")
        .where("name", isEqualTo: valueDepartment)
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
              setState(() {
                for (var element in value.docs) {
                  ChatRoomModel chatRoom = ChatRoomModel();
                  chatRoom.id = element['room_id'];
                  chatRoom.userId = element['user_id'];
                  chatRoom.time = element['time'];
                  chatRoom.title = element['title'];
                  chatRoom.department = element['department'];
                  chatRoom.category = element['category'];
                  chatRoom.information = element['information'];
                  chatRoom.group = element['group'];
                  chatRoom.mode = element['mode'];
                  chatRoom.status = element['status'];

                  listPublicChatRoom.add(chatRoom);
                }
              })
            });
  }

  var employeeName = {};
  getEmployeeName() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .get()
        .then((value) => {
              setState(() {
                for (var element in value.docs) {
                  employeeName[element.id] = element["name"];
                }
              })
            });
  }

  List<ChatRoomModel> listChatRoomByUser = [];
  getChatRoomByUser() async {
    await FirebaseFirestore.instance
        .collection('chat_room')
        .where('user_id', isEqualTo: user.id)
        .get()
        .then((value) => {
              setState(() {
                for (var element in value.docs) {
                  ChatRoomModel chatRoom = ChatRoomModel();
                  chatRoom.id = element['room_id'];
                  chatRoom.userId = element['user_id'];
                  chatRoom.time = element['time'];
                  chatRoom.title = element['title'];
                  chatRoom.department = element['department'];
                  chatRoom.category = element['category'];
                  chatRoom.information = element['information'];
                  chatRoom.group = element['group'];
                  chatRoom.mode = element['mode'];
                  chatRoom.status = element['status'];

                  listChatRoomByUser.add(chatRoom);
                }
              })
            });
  }

  _buildChatRoom(listChatRoom) {
    listChatRoom.sort((a, b) => DateFormat("dd-MM-yyyy HH:mm:ss")
        .parse(b.time)
        .compareTo(DateFormat("dd-MM-yyyy HH:mm:ss").parse(a.time)));

    List<Widget> chatList = [];
    listChatRoom.forEach((ChatRoomModel chatRoom) {
      chatList.add(GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      DetailQuestion(chatRoom: chatRoom)));
        },
        child: Card(
          key: UniqueKey(),
          color: Colors.grey[200],
          child: Container(
            //margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            height: 90,

            child: Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        chatRoom.title!,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      if (chatRoom.category == "")
                        const Text('To: Leader')
                      else
                        Text(
                          employeeName.containsKey(chatRoom.category)
                              ? 'To: ${employeeName[chatRoom.category]}'
                              : 'To: ${chatRoom.category}',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      Text(
                        chatRoom.time!,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        chatRoom.status!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: chatRoom.status == "Chưa trả lời"
                              ? Colors.redAccent
                              : Colors.green,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ))
              ],
            ),
          ),
        ),
      ));
    });
    return Column(children: chatList);
  }

  List<EmployeeModel> listEmployee = [];
  getEmployeeData() async {
    await FirebaseFirestore.instance
        .collection('employee').limit(10)
        .get()
        .then((value) => {
              setState(() {
                for (var element in value.docs) {
                  EmployeeModel eModel = EmployeeModel();
                  eModel.id = element['id'];
                  eModel.name = element['name'];
                  eModel.email = element['email'];
                  eModel.image = element['image'];
                  eModel.password = element['password'];
                  eModel.phone = element['phone'];
                  eModel.department = element['department'];
                  eModel.category = element['category'].cast<String>();
                  eModel.roles = element['roles'];
                  eModel.status = element['status'];
                  listEmployee.add(eModel);
                }
              })
            });
  }

  _buildEmployee(BuildContext context, EmployeeModel employeeModel) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ViewEmployeeByUser(employee: employeeModel, users: user)));
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        width: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.blueAccent,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(employeeModel.image!),
                  radius: 24,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      employeeModel.name!,
                      style: const TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      employeeModel.roles!,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      employeeModel.department == ''
                          ? 'Manager'
                          : departmentName[employeeModel.department],
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      _informationControl.sink.addError("Insert Contact method");
      return false;
    }

    if (title.isEmpty) {
      _titleControl.sink.addError("Insert title");
      return false;
    }
    if (question.isEmpty) {
      _questionControl.sink.addError("Insert message");
      return false;
    }
    return true;
  }

  late final ScrollController _scrollController;
  late final PageStorageKey _storageKey;
  double? _savedPosition;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getEmployeeData();
    getDepartmentName();
    getEmployeeName();
    _storageKey = const PageStorageKey('user message scroll position');
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _questionControl.close();
    _titleControl.close();
    _informationControl.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const HomePage()));
            }),
        title: const Text("Message"),
        backgroundColor: Colors.blueAccent,
      ),
      bottomNavigationBar: getFooter(),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (user.id != "") {
              modalBottomSheetQuestion();
            }
          },
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.add,
            size: 25,
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 5, right: 5),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              listPublicChatRoom.clear();
              listChatRoomByUser.clear();
              getAllChatRoom();
              getChatRoomByUser();
              // getQuestion();
            });
          },
          child: FutureBuilder(
            future: Future.delayed(Duration.zero),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (_savedPosition != null) {
                _scrollController.animateTo(
                  _savedPosition!,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
              return SingleChildScrollView(
                controller: _scrollController,
                key: _storageKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: derPart.snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasError) {
                            const Text("Loading");
                          } else {
                            derPart.get().then((QuerySnapshot querySnapshot) {
                              // ignore: unused_local_variable
                              for (var doc in querySnapshot.docs) {}
                            });
                          }
                          return const Text("");
                        }),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 110.0,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                height: 90,
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const SearchCounselorsScreen()));
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        margin: const EdgeInsets.only(left: 10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.grey[300]),
                                        child: const Center(
                                          child: Icon(
                                            Icons.search_outlined,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                                      child: Text(
                                        'Search',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 110,
                                width: MediaQuery.of(context).size.width - 70,
                                child: ListView.builder(
                                  key: UniqueKey(),
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
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Divider(
                      height: 0,
                      color: Color(0xffAAAAAA),
                      indent: 0,
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    getQuestion(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> refreshMes() async {
    setState(() {
      listChatRoomByUser.clear();
      getQuestion();
    });
    //_buildChatRoom(listChatRoomByUser);
  }

  Widget getQuestion() {
    if (listPublicChatRoom.isEmpty) {
      return const Center(
        child:
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
      );
    }
    if (pageIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[_buildChatRoom(listChatRoomByUser)],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[_buildChatRoom(listPublicChatRoom)],
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
              builder: (BuildContext context, StateSetter setStateDepartment) {
            return Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                  child: Text(
                    'Send message',
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
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 15),
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
                                      value: valueDepart,
                                      hint: const Text(
                                          "Please select the unit to inquire"),
                                      iconSize: 36,
                                      items: render(listDepartment),
                                      onChanged: (value) async {
                                        final List<dynamic> listProblem =
                                            await getDataDropdownProblem(value);
                                        setStateDepartment(() {
                                          setState(() {
                                            valueVanDe = null;
                                            valueDepart = value;
                                            listT = listProblem;
                                          });
                                        });
                                      },
                                    ),
                                  )),
                              Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 15),
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
                                          "Please select a question to ask"),
                                      iconSize: 36,
                                      items: renderR(listT),
                                      onChanged: (value) {
                                        setStateDepartment(() {
                                          setState(() {
                                            valueVanDe = value;
                                          });
                                        });
                                      },
                                    ),
                                  )),
                              Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                  width: 340,
                                  child: StreamBuilder(
                                    stream: informationControl,
                                    builder: (context, snapshot) => TextField(
                                      controller: _informationController,
                                      decoration: InputDecoration(
                                          labelText: "Contact method",
                                          hintText: 'Insert Email/Phone',
                                          errorText: snapshot.hasError
                                              ? snapshot.error.toString()
                                              : null,
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
                                        labelText: "Title",
                                        hintText: 'Insert Title',
                                        errorText: snapshot.hasError
                                            ? snapshot.error.toString()
                                            : null,
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
                                                color: Colors.blue, width: 4))),
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
                                        labelText: "Make a question",
                                        hintText: 'Insert message',
                                        errorText: snapshot.hasError
                                            ? snapshot.error.toString()
                                            : null,
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
                                                color: Colors.blue, width: 4))),
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    importPdf();
                                  },
                                  color:
                                      hadFile ? Colors.redAccent : Colors.black,
                                  icon: const Icon(AppIcons.file_pdf)),
                              hadFile
                                  ? const Text(
                                      'One file selected',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.red),
                                    )
                                  : const Text(
                                      'No file selected',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          try {
                                            if (_onSendQuestionClicked()) {
                                              setState(() {
                                                _questionController.text = '';
                                                _informationController.text =
                                                    '';
                                                _titleController.text = '';
                                              });
                                            } else {
                                              showErrorMessage(
                                                  'Send message failed, check your internet connection');
                                            }
                                          } catch (e) {
                                            //
                                          }
                                        },
                                        label: const Text(
                                          'Send',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.send_rounded),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent),
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.all(10)),
                                    Expanded(
                                        child: ElevatedButton.icon(
                                      onPressed: () => {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MessengerPage()))
                                      },
                                      label: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                      icon:
                                          const Icon(Icons.cancel_presentation),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent),
                                    )),
                                    const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 30)),
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
      Reference ref = storage.ref().child("pdf/${file.name}");
      UploadTask uploadTask = ref.putFile(fileForFirebase);
      await uploadTask.whenComplete(() async {
        var url = await ref.getDownloadURL();
        pdfUrl = url.toString();
      }).catchError((onError) {
        return onError;
      });
    }
  }

  Widget getFooter() {
    List<IconData> iconItems = [
      Icons.message,
      AppIcons.chat,
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
        ),
      );
  List<DropdownMenuItem<dynamic>> renderR(List<dynamic> list) {
    return list.map(buildMenuItemM).toList();
  }

  _onSendQuestionClicked() async {
    var isValidData = isValid(_informationController.text,
        _questionController.text, _titleController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadPdf();
    if (isValidData) {
      if (!mounted) return;
      LoadingDialog.showLoadingDialog(context, "Please Wait...");
      createChatRoom(
          user.id!,
          _titleController.text,
          timeString,
          "Chưa trả lời",
          _informationController.text,
          valueDepart!,
          valueVanDe!,
          user.group!,
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
      String department,
      String category,
      String group,
      String mode,
      Function onSuccess) {
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
}
