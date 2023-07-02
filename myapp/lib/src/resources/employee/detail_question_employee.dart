import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import '../../../icons/app_icons_icons.dart';
import '../../models/AnswerModel.dart';
import '../../models/ChatRoomModel.dart';
import '../../models/EmployeeModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';
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

  Answer(this.id, this.questionId, this.content, this.time, this.employee);
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
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    getCurrentUser();
    _numItems = 10;
    getDepartmentName();
    super.initState();
  }

  String? value;
  String? valueKhoa;

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
                      element.time!, employeeModel);
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
          height: 560,
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
      width: MediaQuery.of(context).size.width - 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '   ${question.user.name}',
                style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]),
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blueAccent,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(question.user.image!),
                  radius: 20,
                ),
              ),
              const SizedBox(width: 10,),
              if (question.file != 'file.pdf')
                if (question.file
                    .substring(question.file.length - 100)
                    .startsWith('.pdf'))
                  (Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final url = question.file;
                              final file = await PDFApi.loadNetwork(url);
                              if (!mounted) return;
                              openPDF(context, file);
                            },
                            icon: const Icon(AppIcons.file_pdf,
                                color: Color(0xED0565B2)),
                          ),
                          const Text(
                            "File PDF",
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xED0565B2)),
                          ),
                        ],
                      ),
                    ],
                  )),

              SizedBox(
                width: MediaQuery.of(context).size.width - 96,
                height: question.file != 'file.pdf' &&
                    !question.file
                        .substring(question.file.length - 57)
                        .startsWith('.pdf')? 310: 60,
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.maxFinite,
                        height: 150,
                        child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            alignment: WrapAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(top: 3, bottom: 10),
                                decoration:  BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  color: Colors.grey[500],
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
                            ]),
                      ),
                    ),
                    if (question.file != 'file.pdf' &&
                        !question.file
                            .substring(question.file.length - 57)
                            .startsWith('.pdf'))
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 96,
                          child: Card(
                            margin: const EdgeInsets.all(5),
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
                  ],
                ),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '   ${answer.employee.name}',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[500],
                ),
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
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  alignment: WrapAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 3, bottom: 10),
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
                        overflow: TextOverflow.visible,
                        maxLines: 20,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
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
          )
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

  Widget _getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 22),
      backgroundColor: Colors.blue,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // FAB 1
        SpeedDialChild(
            child: const Icon(Icons.send),
            backgroundColor: Colors.blue,
            onTap: () {
              _modalBottomSheetAddAnswer();
            },
            label: 'Send answer',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.blueAccent),

        SpeedDialChild(
            child: const Icon(Icons.published_with_changes),
            backgroundColor: Colors.blue,
            onTap: () {
              _modalBottomSheetChange();
            },
            label: 'Move question',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.blueAccent),
      ],
    );
  }

  _modalBottomSheetChange() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.55)),
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
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: SingleChildScrollView(
                            child: SizedBox(
                          height: 300,
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
                                padding: const EdgeInsets.all(10),
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

  _modalBottomSheetAddAnswer() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.65)),
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
                    'Answer question',
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
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: SingleChildScrollView(
                            child: SizedBox(
                          height: 600,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                child: StreamBuilder(
                                  stream: answerControl,
                                  builder: (context, snapshot) => TextField(
                                    controller: _answerController,
                                    maxLines: 7,
                                    maxLength: 500,
                                    decoration: InputDecoration(
                                        hintMaxLines: 5,
                                        helperMaxLines: 5,
                                        labelText: "Answer question",
                                        hintText: 'Insert answer',
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
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      child: ElevatedButton.icon(
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
                                        label: const Text(
                                          'Send',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.send),
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

  _onSendAnswerClicked() {
    var isvalid = isValid(_answerController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);

    if (isvalid) {
      sendAnswer(currentEmployee.id!, _answerController.text, timeString,
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

  void sendAnswer(String employeeId, String content, String time,
      String roomId, Function onSuccess) {
    var ref = FirebaseFirestore.instance.collection('answer');
    String id = ref.doc().id;
    ref.doc(id).set({
      'id': id,
      'employee_id': employeeId,
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

  _inputAnswer() {
    return Container(
      height: 50,
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
            onPressed: () {},
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(name),
          actions: [
            IconButton(
              onPressed: () {
                _modalBottomSheetChange();
              },
              icon: const Icon(Icons.more_horiz),
            ),
          ],
          backgroundColor: Colors.blueAccent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 560,
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: _buildMessage(),
                    ),
                  ),
                  if (ableToAnswer()) _inputAnswer()
                ],
              ),
            ],
          ),
        ),
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
