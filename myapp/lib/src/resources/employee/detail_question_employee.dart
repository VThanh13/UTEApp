import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../icons/app_icons_icons.dart';
import '../../models/AnswerModel.dart';
import '../../models/ChatRoomModel.dart';
import '../../models/EmployeeModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';
import '../dialog/search_question_dialog.dart';
import '../pdf_viewer.dart';
import 'messenger_employee.dart';

class DetailQuestionEmployee extends StatefulWidget {
  @override
  State<DetailQuestionEmployee> createState() => _DetailQuestionState();

  final ChatRoomModel chatRoom;

  const DetailQuestionEmployee({super.key, required this.chatRoom});
}

class Answer {
  String id;
  String content;
  String questionId;
  String time;
  EmployeeModel employee;
  String file;

  Answer(this.id, this.questionId, this.content, this.time, this.employee, this.file);
}

class Question {
  String id;
  String roomId;
  String content;
  String time;
  UserModel user;
  String file;

  Question(this.id, this.roomId, this.content, this.time, this.user, this.file);
}

class Message {
  String type;
  String id;
  String time;

  Message(this.type, this.id, this.time);
}

UserModel uModel = UserModel();

class _DetailQuestionState extends State<DetailQuestionEmployee> {

  late final ScrollController _scrollController;
  late final PageStorageKey _storageKey;
  double? _savedPosition;
  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getCurrentUser();
    _numItems = 10;
    getDepartmentName();
    super.initState();
    _storageKey = const PageStorageKey('user message scroll position');
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    SharedPreferences.getInstance().then((prefs) {
      double? savedPosition = prefs.getDouble('scrollPosition');
      // If a saved position was found, assign it to _savedPosition
      if (savedPosition != null) {
        setState(() {
          _savedPosition = savedPosition;
        });
      }
    });
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  String? value;
  String? valueKhoa;
  var selectedDerpartments;
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
  final TextEditingController _answerController = TextEditingController();

  final StreamController _answerControl = StreamController.broadcast();

  Stream get answerControl => _answerControl.stream;

  FirebaseAuth auth = FirebaseAuth.instance;
  var currentUserAuth = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel = EmployeeModel();
  EmployeeModel currentEmployee = EmployeeModel();

  final List<Question> listQuestion = [];
  final List<Answer> listAnswer = [];
  final List<Message> listMessage = [];
  var departmentName = {};

  Future<List> getDataDropdownProblem(String? valueKhoa) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("departments")
        .where("name", isEqualTo: valueKhoa)
        .get();

    List<dynamic> list = [];
    snapshot.docs.map((e) {
      list = (e.data() as Map)["category"];
      return list;
    }).toList();
    return list;
  }

  List<String> listDepartment = [];
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
    await getQuestionData();
    await getAnswerData();
  }

  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .doc(currentUserAuth.uid)
        .get()
        .then((value) => {
              setState(() {
                currentEmployee.id = value['id'];
                currentEmployee.name = value['name'];
                currentEmployee.email = value['email'];
                currentEmployee.image = value['image'];
                currentEmployee.password = value['password'];
                currentEmployee.phone = value['phone'];
                currentEmployee.department = value['department'];
                currentEmployee.category = value['category'].cast<String>();
                currentEmployee.roles = value['roles'];
                currentEmployee.status = value['status'];
              })
            });
  }

  getQuestionData() async {
    UserModel userModel = UserModel();
    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.chatRoom.userId)
        .get()
        .then((value) => {
              setState(() {
                userModel.id = value['userId'];
                userModel.name = value['name'];
                userModel.email = value['email'];
                userModel.image = value['image'];
                userModel.password = value['password'];
                userModel.phone = value['phone'];
                userModel.group = value['group'];
                userModel.status = value['status'];
              })
            });
    await FirebaseFirestore.instance
        .collection('questions')
        .where('room_id', isEqualTo: widget.chatRoom.id)
        .get()
        .then((value) => {
              // ignore: avoid_function_literals_in_foreach_calls
              value.docs.forEach((element) {
                Question question = Question("", "", "", "", userModel, "");
                question.id = element['id'];
                question.roomId = element['room_id'];
                question.content = element['content'];
                question.time = element['time'];
                question.file = element['file'];
                listQuestion.add(question);
                Message message =
                    Message('question', question.id, question.time);
                listMessage.add(message);
              })
            });
  }

  getAnswerData() async {
    List<AnswerModel> listAns = [];
    await FirebaseFirestore.instance
        .collection('answer')
        .where('room_id', isEqualTo: widget.chatRoom.id)
        .get()
        .then((value) => {
              setState(() {
                for (var element in value.docs) {
                  AnswerModel ans = AnswerModel();
                  ans.employee_id = element['employee_id'];
                  ans.id = element['id'];
                  ans.room_id = element['room_id'];
                  ans.content = element['content'];
                  ans.time = element['time'];
                  ans.file = element['file'];

                  listAns.add(ans);
                }
              })
            });
    Answer ans;
    // ignore: avoid_function_literals_in_foreach_calls
    listAns.forEach((element) async {
      EmployeeModel employeeModel = EmployeeModel();
      // Answer ans = Answer(element.id, element.room_id, element.content, element.time, employeeModel);
      await FirebaseFirestore.instance
          .collection('employee')
          .doc(element.employee_id)
          .get()
          .then((value) => {
                setState(() {
                  employeeModel.id = value['id'];
                  employeeModel.name = value['name'];
                  employeeModel.email = value['email'];
                  employeeModel.image = value['image'];
                  employeeModel.password = value['password'];
                  employeeModel.phone = value['phone'];
                  employeeModel.department = value['department'];
                  employeeModel.category = value['category'].cast<String>();
                  employeeModel.roles = value['roles'];
                  employeeModel.status = value['status'];
                  ans = Answer(element.id!, element.room_id!, element.content!,
                      element.time!, employeeModel, element.file!);
                  // ans.employee = employeeModel;
                  listAnswer.add(ans);
                  Message message = Message('answer', ans.id, ans.time);
                  listMessage.add(message);
                })
              });
    });
  }

  bool _isLoadingMore = false;
  int _numItems = 10;

  _buildMessage() {
    if (listMessage.isEmpty ||
        departmentName.isEmpty ||
        currentEmployee.category == null) {
      return const Center(
        child:
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
      );
    }
    listMessage.sort((a, b) => DateFormat("dd-MM-yyyy HH:mm:ss")
        .parse(a.time)
        .compareTo(DateFormat("dd-MM-yyyy HH:mm:ss").parse(b.time)));
    var messagesToShow = listMessage.take(_numItems);
    List<Widget> messageList = [];
    for (var message in messagesToShow) {
      if (message.type == "question") {
        messageList.add(GestureDetector(
            child: _buildQues(listQuestion
                .firstWhere((element) => element.id == message.id))));
      } else {
        messageList.add(GestureDetector(
            child: _buildAnswers(
                listAnswer.firstWhere((element) => element.id == message.id))));
      }
    }
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.maxFinite,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (!_isLoadingMore &&
                  notification.metrics.pixels ==
                      notification.metrics.maxScrollExtent) {
                setState(() {
                  _isLoadingMore = true;
                  _numItems += 10;
                });
                Future.delayed(const Duration(milliseconds: 500), () {
                  setState(() {
                    _isLoadingMore = false;
                  });
                });
              }
              return true;
            },
            child: SingleChildScrollView(
              child: Column(children: messageList),
            ),
          ),
        ),
      ],
    );
  }

  String name = '';

  _buildQues(Question question) {
    name = question.user.name!;
    return SizedBox(
      key: UniqueKey(),
      width: MediaQuery.of(context).size.width - 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '                      ${question.user.name}',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                ', ${question.time}',
                overflow: TextOverflow.visible,
                maxLines: 3,
                style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                    overflow: TextOverflow.visible),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blueAccent,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(question.user.image!),
                  radius: 20,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 100),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(top: 3, bottom: 5, left: 10),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      color: Colors.grey,
                    ),
                    child: Text(
                      question.content,
                      maxLines: 20,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (question.file != 'file.pdf' && !question.file.substring(question.file.length - 57).startsWith('.pdf'))
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 92,
                        child: Card(
                          margin: const EdgeInsets.only(top: 3, bottom: 5, left: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(question.file),
                          ),
                        ),
                      ),
                    ),
                  if (question.file != 'file.pdf' && question.file.substring(question.file.length - 57).startsWith('.pdf'))
                    (Container(
                      margin: const EdgeInsets.only(top: 3, bottom: 5, left: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        color: Colors.grey,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final url = question.file;
                              final file = await PDFApi.loadNetwork(url);
                              openPDF(context, file);
                            },
                            icon: const Icon(AppIcons.file_pdf,
                                color: Colors.black),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                            margin: const EdgeInsets.only(top: 3, bottom: 5),
                            child: const Text(
                              "File PDF",
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _buildAnswers(Answer answer) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '   ${answer.employee.name}',
                style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]),
              ),
              Text(
                ', ${answer.time}',
                overflow: TextOverflow.visible,
                maxLines: 3,
                style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                    overflow: TextOverflow.visible),
              ),
              Text('               '),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Container(
                        constraints: new BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 100),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 3, bottom: 5, right: 10),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          color: Colors.lightBlueAccent,
                        ),
                        child: Text(
                          answer.content,
                          maxLines: 20,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (answer.file != 'file.pdf' && !answer.file.substring(answer.file.length - 57).startsWith('.pdf'))
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 92,
                        child: Card(
                          margin: const EdgeInsets.only(top: 3, bottom: 5, right: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(answer.file),
                          ),
                        ),
                      ),
                    ),
                  if (answer.file != 'file.pdf' && answer.file.substring(answer.file.length - 57).startsWith('.pdf'))
                    (Container(
                      margin: const EdgeInsets.only(top: 3, bottom: 5, right: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        color: Colors.lightBlueAccent,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final url = answer.file;
                              final file = await PDFApi.loadNetwork(url);
                              openPDF(context, file);
                            },
                            icon: const Icon(AppIcons.file_pdf,
                                color: Color(0xED0565B2)),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                            margin: const EdgeInsets.only(top: 3, bottom: 5),
                            child: const Text(
                              "File PDF",
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xED0565B2)),
                            ),
                          ),
                        ],
                      ),
                    )),

                ],
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blueAccent,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(answer.employee.image!),
                  radius: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
      );

  bool isValid(String answer) {
    if (answer.isEmpty) {
      _answerControl.sink.addError("Insert answers");
      return false;
    }
    return true;
  }

  _modalBottomSheetChange() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.45)),
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
                    'Move question',
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
                        height: MediaQuery.of(context).size.height * 0.37,
                        child: Container(
                            child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
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
                                        color: Colors.blueAccent, width: 2),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: valueKhoa,
                                      hint: const Text(
                                          "Please choose department"),
                                      iconSize: 36,
                                      items: render(listDepartment),
                                      onChanged: (value) async {
                                        final List<dynamic> listProblem =
                                            await getDataDropdownProblem(value);
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
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                  width: 340,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.blueAccent, width: 2),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: valueVanDe,
                                      hint:
                                          const Text("Please choose category"),
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
                                padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                                margin: const EdgeInsets.only(top: 40),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          _onChangeQuestionClicked(
                                              widget.chatRoom.id);
                                        },
                                        label: const Text(
                                          'Save',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.save_outlined),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent),
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.all(10)),
                                    Expanded(
                                        child: ElevatedButton.icon(
                                      onPressed: () => {Navigator.pop(context)},
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
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }

  _onChangeQuestionClicked(id) {
    LoadingDialog.showLoadingDialog(context, "Please Wait...");
    changeQuestion(id, valueKhoa!, valueVanDe!, () {
      LoadingDialog.hideLoadingDialog(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const MessengerPageEmployee()));
    });
  }

  void changeQuestion(id, department, category, Function onSuccess) {
    var ref = FirebaseFirestore.instance.collection('chat_room');
    String departmentId = departmentName.keys
        .firstWhere((k) => departmentName[k] == department, orElse: () => null);
    ref.doc(id).update({
      'department': departmentId,
      'category': category,
    }).then((value) {
      onSuccess();
    }).catchError((err) {});
  }

  late PlatformFile file;
  bool hadFile = false;
  importPdf() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf']);
    if (result == null) return;

    if(result.files.first.path!.endsWith(".pdf")){
      // Check File Size
      final fileSize = result.files.first.size; // Kích thước tệp (byte)
      final maxFileSize = 5 * 1024 * 1024; // Giới hạn kích thước 5MB

      if (fileSize > maxFileSize) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Kích thước tệp PDF vượt quá giới hạn'),
            content: Text('Kích thước tệp PDF quá lớn, vui lòng chọn tệp nhỏ hơn.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }
    else{
      // Check File Size
      final fileSize = result.files.first.size; // Kích thước tệp (byte)
      final maxFileSize = 1024 * 1024; // Giới hạn kích thước 1MB

      if (fileSize > maxFileSize) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Kích thước ảnh vượt quá giới hạn'),
            content: Text('Kích thước ảnh quá lớn, vui lòng chọn ảnh nhỏ hơn.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

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
      }).catchError((onError) {});
    }
  }

  _onSendAnswerClicked() async {
    var isvalid = isValid(_answerController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadPdf();
    if (isvalid) {
      sendAnswer(currentEmployee.id!, _answerController.text, timeString, pdfUrl,
          widget.chatRoom.id!, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DetailQuestionEmployee(chatRoom: widget.chatRoom)));
      });
    }
    return 0;
  }

  void sendAnswer(String employeeId, String content, String time, String file,
      String roomId, Function onSuccess) {
    var ref = FirebaseFirestore.instance.collection('answer');
    String id = ref.doc().id;
    ref.doc(id).set({
      'id': id,
      'employee_id': employeeId,
      'file': file,
      'time': time,
      'content': content,
      'room_id': roomId,
    }).then((value) {
      updateChatRoomStatus(roomId);
      onSuccess();
    }).catchError((err) {});
  }

  void updateChatRoomStatus(String roomId) {
    var ref = FirebaseFirestore.instance.collection('chat_room');

    ref
        .doc(roomId)
        .update({'status': "Đã trả lời"})
        .then((value) {})
        .catchError((err) {});
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

  bool ableToAnswer() {
    if (currentEmployee.id != null && currentEmployee.id! == widget.chatRoom.category) {
      return true;
    }
    else if (currentEmployee.department != null && currentEmployee.department! == widget.chatRoom.department){
      if(currentEmployee.roles != null && currentEmployee.roles! == "Trưởng nhóm") {
        return true;
      } else if (currentEmployee.category != null && currentEmployee.category!.contains(widget.chatRoom.category)) {
        return true;
      }
    }
    return false;
  }

  double previousBottomInset = 0.0;
  late FocusNode _focusNode;

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Bàn phím biến mất
      print('Keyboard disappeared');
      setState(() {
        contentHeight = 0.83;
      });
    }
  }

  _inputAnswer() {
    return Listener(
      onPointerMove: (event) {
        final keyboardVisible = event.position.dy > MediaQuery.of(context).viewInsets.bottom;
        if (keyboardVisible) {
          // Bàn phím xuất hiện
          setState(() {
            contentHeight = 0.435;
          });
        } else {
          // Bàn phím biến mất
          setState(() {
            contentHeight = 0.83;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        width: double.maxFinite,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blueAccent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                importPdf();
              },
              icon: const Icon(
                AppIcons.file_pdf,
                size: 20,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(
              width: 230,
              child: StreamBuilder(
                stream: answerControl,
                builder: (context, snapshot) => TextField(
                  focusNode: _focusNode,
                  controller: _answerController,
                  decoration: InputDecoration(
                    errorText:
                    snapshot.hasError ? snapshot.error.toString() : null,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                try {
                  if (_onSendAnswerClicked()) {
                    setState(() {
                      _answerController.text = '';
                    });
                  } else {
                    showErrorMessage(
                        'Send message fail, check your internet connection');
                  }
                } catch (e) {
                  //
                }
              },
              icon: const Icon(
                Icons.send_sharp,
                size: 25,
                color: Colors.blueAccent,
              ),
            )
          ],
        ),
      )
    );
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _numItems += 10;
      });
    }
  }

  publicizeTheQuestion(id, Function onSuccess){
    var ref = FirebaseFirestore.instance.collection('chat_room');
    ref.doc(id).update({
      'mode': 'public',
    }).then((value) {
      onSuccess();
    }).catchError((err) {});
  }

  _onPublicizeTheQuestionClicked(){
    LoadingDialog.showLoadingDialog(context, "Please Wait...");
    publicizeTheQuestion(widget.chatRoom.id, () {
      LoadingDialog.hideLoadingDialog(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const MessengerPageEmployee()));
    });
  }

  Future<void> fetchData() async {
    // var url = Uri.parse('https://dummyjson.com/products/search?q=Laptop');
    String keyword = "";
    for (Question question in listQuestion) {
      keyword += question.content + " ";
    }

    String uri = "http://localhost:3000/api/v1/questions/search/?key_word=";
    uri = uri + keyword;
    var url = Uri.parse(uri);
    final response = await http.get(url);
    List<ChatRoomModel> chatRooms = [];

    if (response.statusCode == 200) {
      dynamic chatRoomsData = json.decode(response.body);

      setState(() {
        chatRoomsData["data"].forEach((element) {
          ChatRoomModel chatRoom = ChatRoomModel();
          chatRoom.id = element["room_id"];
          chatRoom.userId = element["user_id"];
          chatRoom.title = element["title"];
          chatRoom.time = element["time"];
          chatRoom.department = element["department"];
          chatRoom.category = element["category"];
          chatRoom.information = element["information"];
          chatRoom.group = element["group"];
          chatRoom.status = element["status"];
          chatRoom.mode = element["mode"];

          chatRooms.add(chatRoom);
        });
      });
      SearchQuestionDialog.showChatRoomDialog(context, chatRooms);
    } else {
      throw Exception('Failed to load data');
    }
  }

  _onSeeRelatedQuestions() async {
    fetchData();
  }

  actionModalPopup(){
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
                  _modalBottomSheetChange();
                },
                child: const Text(
                  'Move question',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
              if(widget.chatRoom.mode == "private")
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    _onPublicizeTheQuestionClicked();
                  },
                  child: const Text(
                    'Public this question',
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
                  _onSeeRelatedQuestions();
                },
                child: const Text(
                  'See related question',
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
        }
    );
  }

  var contentHeight = 0.83;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
                title: const Text('Message'),
                backgroundColor: Colors.blueAccent,
                actions: <Widget>[
                  IconButton(
                    onPressed: () {
                      actionModalPopup();
                    },
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ]
            ),
            // bottomNavigationBar: (ableToAnswer())? _inputAnswer():null,
            body: Stack(children: <Widget>[
              FutureBuilder(
                future: Future.delayed(Duration.zero),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (_savedPosition != null) {
                    _scrollController.animateTo(
                      _savedPosition!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                  return Column(
                    children: <Widget>[
                      SizedBox(
                        width: double.maxFinite,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: ableToAnswer() ? MediaQuery.of(context).size.height * contentHeight : MediaQuery.of(context).size.height * 0.89,
                                width: double.maxFinite,
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  key: _storageKey,
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),

                                  child: _buildMessage(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Positioned(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 0,
                  right: 0,
                  child: (ableToAnswer())? _inputAnswer():Text("")
              ),
            ])
        ),
    );
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
