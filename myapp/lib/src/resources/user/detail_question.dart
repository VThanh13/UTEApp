// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../icons/app_icons_icons.dart';
import '../../models/AnswerModel.dart';
import '../../models/ChatRoomModel.dart';
import '../../models/EmployeeModel.dart';
import '../../models/UserModel.dart';
import '../pdf_viewer.dart';

class DetailQuestion extends StatefulWidget {
  @override
  State<DetailQuestion> createState() => _DetailQuestionState();

  final ChatRoomModel chatRoom;

  const DetailQuestion({super.key, required this.chatRoom});
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

class _DetailQuestionState extends State<DetailQuestion> {
  String? value;
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

  FirebaseAuth auth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel = EmployeeModel();

  final List<Question> listQuestion = [];
  final List<Answer> listAnswer = [];
  final List<Message> listMessage = [];
  var departmentName = {};

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
    await getQuestionData();
    await getAnswerData();
  }

  getQuestionData() async {
    UserModel userModel = UserModel();
    await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: widget.chatRoom.userId)
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

    listAns.forEach((element) async {
      EmployeeModel employeeModel = EmployeeModel();
      Answer ans = Answer(element.id!, element.room_id!, element.content!,
          element.time!, employeeModel);
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
                  employeeModel.category =
                      value.docs.first['category'].cast<String>();
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

  bool _isLoadingMore = false;

  _buildMessage() {
    listMessage.sort((a, b) => DateFormat("dd-MM-yyyy HH:mm:ss")
        .parse(a.time)
        .compareTo(DateFormat("dd-MM-yyyy HH:mm:ss").parse(b.time)));
    // Only show the first _numItems items from the list
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
              controller: _scrollController,
              child: Column(children: messageList),
            ),
          ),
        ),
      ],
    );
  }

  _buildQues(Question question) {
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
              if (question.file != 'file.pdf')
                if (question.file
                    .substring(question.file.length - 100)
                    .startsWith('.pdf'))
                  (Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final url = question.file;
                              final file = await PDFApi.loadNetwork(url);
                              // ignore: use_build_context_synchronously
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
                width: MediaQuery.of(context).size.width - 92,
                height: question.file != 'file.pdf' &&
                        !question.file
                            .substring(question.file.length - 57)
                            .startsWith('.pdf')
                    ? 400
                    : 60,
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.maxFinite,
                        height: 150,
                        child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.end,
                            alignment: WrapAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin:
                                    const EdgeInsets.only(top: 3, bottom: 10),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  color: Colors.lightBlueAccent,
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
                        padding: const EdgeInsets.only(top: 35),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 92,
                          child: Card(
                            margin: const EdgeInsets.all(5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                question.file,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blueAccent,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(question.user.image!),
                  radius: 20,
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
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blueAccent,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(answer.employee.image!),
                  radius: 20,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  alignment: WrapAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 3, bottom: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        color: Colors.grey,
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
            ],
          )
        ],
      ),
    );
  }

  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
      );

  final TextEditingController _questionController = TextEditingController();
  final StreamController _questionControl = StreamController.broadcast();

  Stream get questionControl => _questionControl.stream;

  bool isValid(String question) {
    if (question.isEmpty) {
      _questionControl.sink.addError("Insert message");
      return false;
    }
    return true;
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

  _onSendQuestionClicked() async {
    var isValidData = isValid(_questionController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadPdf();
    if (isValidData) {
      sendQuestion(
          timeString, pdfUrl, _questionController.text, widget.chatRoom.id!,
          () async {
        listMessage.clear();
        setState(() {
          _questionController.text = '';
        });
        await getQuestionData();
        //getAnswerData();
        await _buildMessage();
      });
    }
    return 0;
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
      updateChatRoomStatus(roomId);
      onSuccess();
    }).catchError((err) {});
  }

  void updateChatRoomStatus(String roomId) {
    var ref = FirebaseFirestore.instance.collection('chat_room');
    ref
        .doc(roomId)
        .update({'status': "Chưa trả lời"})
        .then((value) {})
        .catchError((err) {});
  }

  final ScrollController _scrollController = ScrollController();
  int _numItems = 10;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getDepartmentName();
    super.initState();
    _numItems = 10;
    SharedPreferences.getInstance().then((prefs) {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Message'),
          backgroundColor: Colors.blueAccent,
        ),
        // bottomNavigationBar: (current_user.uid == widget.chatRoom.user_id)? _inputQuestion():null,
        body: SingleChildScrollView(
          controller: _scrollController,
          // key: _storageKey,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            children: <Widget>[
              SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        width: double.maxFinite,
                        child: SingleChildScrollView(
                          child: _buildMessage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (currentUser.uid == widget.chatRoom.userId) _inputQuestion(),
            ],
          ),
        ),
      ),
    );
  }

  _inputQuestion() {
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
              stream: questionControl,
              builder: (context, snapshot) => TextField(
                controller: _questionController,
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
                if (_onSendQuestionClicked()) {
                  setState(() {
                    _questionController.text = '';
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
          ),
        ],
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
