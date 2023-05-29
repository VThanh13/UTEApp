import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

class Message{
  String type;
  String id;
  String time;

  Message(this.type, this.id, this.time);
}

UserModel uModel = UserModel("", " ", "", "", "", "", "", "");

class _DetailQuestionState extends State<DetailQuestion> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
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

  FirebaseAuth auth = FirebaseAuth.instance;
  var current_user = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel =
  EmployeeModel("", " ", "", "", "", "", "", "", "", "");

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
        value.docs.forEach((element) {
          departmentName[element.id] = element["name"];
        });
      })
    });
    await getQuestionData();
    await getAnswerData();
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
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '   ${question.user.name}',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500]
                  ),
                ),
                Text(
                  ', ${question.time}',
                  overflow: TextOverflow.visible,
                  maxLines: 3,
                  style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                      overflow:
                      TextOverflow.visible),
                ),
              ],
            ),
            SizedBox(
              width:
              MediaQuery.of(context).size.width - 75,
              child: Card(
                margin: const EdgeInsets.all(5),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                ),
                color: Colors.lightBlueAccent,
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
              ),
            const SizedBox(height: 10,)
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.tealAccent,
          child: CircleAvatar(
            backgroundImage:
            NetworkImage(question.user.image),
            radius: 20,
          ),
        ),
      ],
    );
  }

  _buildAnswers(Answer answer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.tealAccent,
          child: CircleAvatar(
            backgroundImage: NetworkImage(answer.employee.image),
            radius: 20,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: [
                Text(
                  '   ${answer.employee.name}',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  ', ${answer.time}',
                  overflow: TextOverflow.visible,
                  maxLines: 3,
                  style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                      overflow:
                      TextOverflow.visible),
                ),
              ],
            ),
            SizedBox(
              //width: MediaQuery.of(context).size.width -75,
              width: 285,
              child: Card(
                margin: const EdgeInsets.all(5),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                ),
                color: Colors.grey,
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
            const SizedBox(height: 10,)
          ],
        ),

      ],
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
  // _modalBottomSheetAddQuestion() {
  //   return showModalBottomSheet(
  //       isScrollControlled: true,
  //       constraints: BoxConstraints.loose(Size(
  //           MediaQuery.of(context).size.width,
  //           MediaQuery.of(context).size.height * 0.75)),
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(20),
  //             topRight: Radius.circular(20),
  //           )),
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Column(
  //           children: <Widget>[
  //             const Padding(
  //               padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
  //               child: Text(
  //                 'Send message',
  //                 style: TextStyle(
  //                     fontSize: 24,
  //                     fontWeight: FontWeight.w600,
  //                     letterSpacing: 1.0),
  //               ),
  //             ),
  //             SingleChildScrollView(
  //               physics: const BouncingScrollPhysics(),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: <Widget>[
  //                   SizedBox(
  //                     height: MediaQuery.of(context).size.height * 0.65,
  //                     child: SingleChildScrollView(
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         children: <Widget>[
  //                           const Padding(
  //                               padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
  //                           Container(
  //                             width: 340,
  //                             margin: const EdgeInsets.fromLTRB(0, 10, 0, 15),
  //                             child: StreamBuilder(
  //                               stream: questionControl,
  //                               builder: (context, snapshot) => TextField(
  //                                 controller: _questionController,
  //                                 maxLines: 50,
  //                                 minLines: 10,
  //                                 maxLength: 3000,
  //                                 decoration: InputDecoration(
  //                                     hintMaxLines: 5,
  //                                     helperMaxLines: 5,
  //                                     labelText: "Send message",
  //                                     hintText: 'Insert message',
  //                                     enabledBorder: OutlineInputBorder(
  //                                       borderRadius:
  //                                       BorderRadius.circular(10),
  //                                       borderSide: const BorderSide(
  //                                         color: Colors.blueAccent,
  //                                         width: 1,
  //                                       ),
  //                                     ),
  //                                     focusedBorder: OutlineInputBorder(
  //                                         borderRadius:
  //                                         BorderRadius.circular(10),
  //                                         borderSide: const BorderSide(
  //                                             color: Colors.blue,
  //                                             width: 4))),
  //                               ),
  //                             ),
  //                           ),
  //                           IconButton(
  //                               onPressed: () {
  //                                 importPdf();
  //                               },
  //                               icon: const Icon(AppIcons.file_pdf)),
  //                           Container(
  //                             padding: const EdgeInsets.all(10),
  //                             child: Row(
  //                               mainAxisAlignment:
  //                               MainAxisAlignment.spaceAround,
  //                               children: <Widget>[
  //                                 Expanded(
  //                                   child: ElevatedButton.icon(
  //                                     onPressed: () {
  //                                       _onSendQuestionClicked();
  //                                     },
  //                                     label: const Text(
  //                                       'Send',
  //                                       style: TextStyle(
  //                                           fontSize: 16,
  //                                           color: Colors.white),
  //                                     ),
  //                                     icon: const Icon(Icons.send_rounded),
  //                                     style: ElevatedButton.styleFrom(
  //                                         primary: Colors.blueAccent),
  //                                   ),
  //                                 ),
  //                                 const Padding(padding: EdgeInsets.all(10)),
  //                                 Expanded(
  //                                     child: ElevatedButton.icon(
  //                                       onPressed: () =>
  //                                       {Navigator.pop(context)},
  //                                       label: const Text(
  //                                         'Cancel',
  //                                         style: TextStyle(
  //                                             fontSize: 16,
  //                                             color: Colors.white),
  //                                       ),
  //                                       icon: const Icon(Icons.cancel_presentation),
  //                                       style: ElevatedButton.styleFrom(
  //                                           primary: Colors.blueAccent),
  //                                     )),
  //                                 const Padding(
  //                                     padding: EdgeInsets.fromLTRB(
  //                                         0, 10, 0, 30)),
  //                               ],
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }

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

  _onSendQuestionClicked() async {
    var isvalid = isValid(_questionController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadPdf();
    if (isvalid) {
      sendQuestion(timeString, pdfUrl, _questionController.text, widget.chatRoom.id, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DetailQuestion(chatRoom: widget.chatRoom)));
      });
    }
    return 0;
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

  // Widget _getFAB() {
  //   return SpeedDial(
  //     animatedIcon: AnimatedIcons.menu_close,
  //     animatedIconTheme: const IconThemeData(size: 22),
  //     backgroundColor: Colors.blue,
  //     visible: true,
  //     curve: Curves.bounceIn,
  //     children: [
  //       // FAB 1
  //       SpeedDialChild(
  //           child: const Icon(Icons.send),
  //           backgroundColor: Colors.blue,
  //           onTap: () {
  //             _modalBottomSheetAddQuestion();
  //           },
  //           label: 'Send message',
  //           labelStyle: const TextStyle(
  //               fontWeight: FontWeight.w500,
  //               color: Colors.white,
  //               fontSize: 16.0),
  //           labelBackgroundColor: Colors.blueAccent),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: (){
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: AppBar(
          title: const Text('Message'),
          backgroundColor: Colors.blueAccent,
        ),
        // floatingActionButton: (current_user.uid == widget.chatRoom.user_id)? _getFAB():null,
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SafeArea(
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 10)),
              Container(
                height: 505,
                margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: _buildMessage(),
                ),
              ),
              SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 250,
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: StreamBuilder(
                            stream: questionControl,
                            builder: (context, snapshot) => TextField(
                              controller: _questionController,
                              maxLines: 10,
                              minLines: 1,
                              maxLength: 3000,
                              decoration: InputDecoration(
                                  hintMaxLines: 5,
                                  helperMaxLines: 5,
                                  labelText: "Send message",
                                  hintText: 'Insert message',
                                  errorText: snapshot.hasError? snapshot.error.toString() : null,
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
                                          width: 3))),
                            ),
                          ),
                        ),
                        Padding(padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                          child: IconButton(
                            onPressed: (){
                              importPdf();
                            },
                            icon: const Icon(AppIcons.file_pdf,
                              size: 20,
                              color: Colors.redAccent,),
                          ),),
                        Padding(padding: const EdgeInsets.fromLTRB(0, 0, 2, 0),
                          child: IconButton(
                            onPressed: (){
                              try{
                                if( _onSendQuestionClicked()){
                                  setState(() {
                                    _questionController.text = '';
                                  });
                                }else{
                                  showErrorMessage('Send message fail, check your internet connection');
                                }
                              }catch(e){
                                //
                              }
                            },
                            icon: const Icon(Icons.send_sharp,
                              size: 25,
                              color: Colors.blueAccent,),
                          ),)
                      ],
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }
  void showErrorMessage(String message) {
    final snackBar = SnackBar(content: Text(message,
      style: const TextStyle(color: Colors.white),
    ),backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
