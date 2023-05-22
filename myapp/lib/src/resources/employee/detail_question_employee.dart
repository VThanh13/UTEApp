import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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

class Message{
  String type;
  String id;
  String time;

  Message(this.type, this.id, this.time);
}

UserModel uModel = UserModel("", " ", "", "", "", "", "", "");

class _DetailQuestionState extends State<DetailQuestionEmployee> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    getCurrentUser();
    getDepartmentName();
    super.initState();
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
  var current_user_auth = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel =
  EmployeeModel("", " ", "", "", "", "", "", "", "", "");
  EmployeeModel currentEmployee =
  EmployeeModel("", "", "", "", "", "", "", "", "", "");

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
        value.docs.forEach((element) {
          departmentName[element.id] = element["name"];
          listDepartment.add(element['name']);
        });
      })
    });
    await getQuestionData();
    await getAnswerData();
  }

  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: current_user_auth.uid)
        .get()
        .then((value) => {
      currentEmployee.id = value.docs.first['id'],
      currentEmployee.name = value.docs.first['name'],
      currentEmployee.email = value.docs.first['email'],
      currentEmployee.image = value.docs.first['image'],
      currentEmployee.password = value.docs.first['password'],
      currentEmployee.phone = value.docs.first['phone'],
      currentEmployee.department = value.docs.first['department'],
      currentEmployee.category = value.docs.first['category'],
      currentEmployee.roles = value.docs.first['roles'],
      currentEmployee.status = value.docs.first['status']
    });
  }

  getQuestionData() async {
    UserModel userModel = UserModel("", " ", "", "", "", "", "", "");
    await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: widget.chatRoom.user_id)
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
      })
    });
    await FirebaseFirestore.instance
        .collection('questions')
        .where('room_id', isEqualTo: widget.chatRoom.id)
        .get()
        .then((value) => {
      value.docs.forEach((element) {
        Question question = Question("", "", "", "", userModel, "");
        question.id = element['id'];
        question.roomId = element['room_id'];
        question.content = element['content'];
        question.time = element['time'];
        question.file = element['file'];
        listQuestion.add(question);
        Message message = Message('question', question.id, question.time);
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
        value.docs.forEach((element) {
          AnswerModel ans = AnswerModel("", "", "", "", "");
          ans.employee_id = element['employee_id'];
          ans.id = element['id'];
          ans.room_id = element['room_id'];
          ans.content = element['content'];
          ans.time = element['time'];

          listAns.add(ans);
        });
      })
    });

    listAns.forEach((element) async {
      EmployeeModel employeeModel =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
      Answer ans = Answer(element.id, element.room_id, element.content,
          element.time, employeeModel);
      await FirebaseFirestore.instance
          .collection('employee')
          .where('id', isEqualTo: element.employee_id)
          .get()
          .then((value) => {
        setState(() {
          employeeModel.id = value.docs.first['id'];
          employeeModel.name = value.docs.first['name'];
          employeeModel.email = value.docs.first['email'];
          employeeModel.image = value.docs.first['image'];
          employeeModel.password = value.docs.first['password'];
          employeeModel.phone = value.docs.first['phone'];
          employeeModel.department = value.docs.first['department'];
          employeeModel.category = value.docs.first['category'];
          employeeModel.roles = value.docs.first['roles'];
          employeeModel.status = value.docs.first['status'];
          ans.employee = employeeModel;
          listAnswer.add(ans);
          Message message = Message('answer', ans.id, ans.time);
          listMessage.add(message);
        })
      });
    });
  }

  _buildMessage(){
    if (listMessage.isEmpty || departmentName.isEmpty) {
      return const Center(
        child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator()),
      );
    }
    listMessage.sort((a, b)=> DateFormat("dd-MM-yyyy HH:mm:ss").parse(a.time).compareTo(DateFormat("dd-MM-yyyy HH:mm:ss").parse(b.time)));
    List<Widget> messageList = [];
    for (var message in listMessage) {
      if(message.type == "question") {
        messageList.add(GestureDetector(
            child: _buildQues(
                listQuestion.firstWhere((element) => element.id == message.id))
        ));
      }
      else{
        messageList.add(GestureDetector(
            child: _buildAnswers(
                listAnswer.firstWhere((element) => element.id == message.id))
        ));
      }
    }
    return Column(children: messageList);
  }

  _buildQues(Question question) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.tealAccent,
          child: CircleAvatar(
            backgroundImage:
            NetworkImage(question.user.image),
            radius: 20,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,

          children: <Widget>[
            SizedBox(
              width:
              MediaQuery.of(context).size.width - 75,
              child: Card(
                margin: const EdgeInsets.all(5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.grey,
                elevation: 10,
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.start,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: const <Widget>[],
                    ),
                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.fromLTRB(
                                5, 5, 5, 5)),
                        Text(
                          '   ' + question.user.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '   Lúc ' + question.time,
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                          style: const TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              overflow:
                              TextOverflow.visible),
                        ),
                      ],
                    ),
                    const Padding(
                        padding: EdgeInsets.fromLTRB(
                            5, 5, 5, 5)),
                    Container(
                        padding: const EdgeInsets.fromLTRB(
                            10, 0, 5, 5),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                question.content,
                                overflow:
                                TextOverflow.visible,
                                maxLines: 20,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w400),
                              ),
                            )
                          ],
                        )),

                    if(question.file!='file.pdf')
                      if(question.file.substring(question.file.length - 57).startsWith('.pdf'))(
                          Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed:() async {
                                      final url =
                                          question.file;
                                      final file = await PDFApi.loadNetwork(url);
                                      openPDF(context, file);
                                    },
                                    icon: const Icon(AppIcons.file_pdf,
                                        color: Color(0xED0565B2)),),
                                  const Text("File PDF đính kèm",
                                    overflow:
                                    TextOverflow.visible,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                        FontWeight.w400,
                                        color: Color(0xED0565B2)),
                                  ),
                                ],
                              ),
                            ],
                          )
                      )
                  ],
                ),
              ),
            ),
            if(question.file!='file.pdf' && !question.file.substring(question.file.length - 57).startsWith('.pdf'))
              SizedBox(
                  width:
                  MediaQuery.of(context).size.width - 75,
                  child: Card(
                    margin: const EdgeInsets.all(5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(question.file),
                    ),
                  )
              )
          ],
        ),
      ],
    );
  }
  _buildAnswers(Answer answer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              //width: MediaQuery.of(context).size.width -75,
              width: 285,
              child: Card(
                margin: const EdgeInsets.all(5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.lightBlueAccent,
                elevation: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
                        Text(
                          '   ' + answer.employee.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '   Lúc ' + answer.time,
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                          style: const TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.visible),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
                    Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 5, 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                answer.content,
                                overflow: TextOverflow.visible,
                                maxLines: 20,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.tealAccent,
          child: CircleAvatar(
            backgroundImage: NetworkImage(answer.employee.image),
            radius: 20,
          ),
        ),
      ],
    );

  }

  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
  );

  bool isValid(String answer) {
    if (answer.isEmpty) {
      _answerControl.sink.addError("Nhập câu trả lời");
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
            label: 'Gửi câu trả lời',
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
            label: 'Chuyển câu hỏi',
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
                return Container(
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                        child: Text(
                          'Chuyển câu hỏi',
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
                                                hint: const Text("Vui lòng chọn đơn vị"),
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
                                                hint: const Text("Vui lòng chọn vấn đề"),
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
                                                    'Lưu',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white),
                                                  ),
                                                  icon: const Icon(Icons.save_outlined),
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                      Colors.blueAccent),
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
                                                        backgroundColor:
                                                        Colors.blueAccent),
                                                  )),
                                              const Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 10, 0, 30)),
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
                  ),
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
                        'Trả lời câu hỏi',
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
                                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),),
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                        child: StreamBuilder(
                                          stream: answerControl,
                                          builder: (context, snapshot) => TextField(
                                            controller: _answerController,
                                            maxLines: 7,
                                            maxLength: 500,
                                            decoration: InputDecoration(
                                                hintMaxLines: 5,
                                                helperMaxLines: 5,
                                                labelText: "Trả lời câu hỏi",
                                                hintText: 'Nhập nội dung câu trả lời',
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
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  _onSendAnswerClicked();
                                                  print('press save');
                                                },
                                                label: const Text(
                                                  'Gửi',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                                icon: const Icon(Icons.send),
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
                                                    'Hủy',
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
    LoadingDialog.showLoadingDialog(context, "Loading...");
    changeQuestion(id, valueKhoa!, valueVanDe!, () {
      LoadingDialog.hideLoadingDialog(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MessengerPageEmployee()));
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
    }).catchError((err) {
      //TODO

    });
  }

  _onSendAnswerClicked() {
    var isvalid = isValid(_answerController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "Loading...");
      sendAnswer(currentEmployee.id, _answerController.text, timeString, widget.chatRoom.id,
              () {
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

  void sendAnswer(String employee_id, String content, String time, String room_id,
      Function onSuccess) {
    var ref = FirebaseFirestore.instance.collection('answer');
    String id = ref.doc().id;
    ref.doc(id).set({
      'id': id,
      'employee_id': employee_id,
      'time': time,
      'content': content,
      'room_id': room_id,
    }).then((value) {
      updateChatRoomStatus(room_id);
      onSuccess();
    }).catchError((err) {
    });
  }

  void updateChatRoomStatus(String room_id) {
    var ref = FirebaseFirestore.instance.collection('chat_room');

    ref.doc(room_id).update({'status': "Đã trả lời"}).then((value) {
    }).catchError((err) {
      //TODO
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

  bool ableToAnswer(){
    if(currentEmployee.category == widget.chatRoom.category)
      return true;

    else if(currentEmployee.category == "" && currentEmployee.department == widget.chatRoom.department)
      return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết câu hỏi"),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: ableToAnswer()? _getFAB():null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //Text("chi tiet cau hoi"),
              //Text(widget.question.title),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                  _buildMessage(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
