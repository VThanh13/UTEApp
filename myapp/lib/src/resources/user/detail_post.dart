import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/models/DepartmentModel.dart';
import 'package:myapp/src/models/EmployeeModel.dart';

import 'package:intl/intl.dart';

import '../../../icons/app_icons_icons.dart';
import '../../models/NewfeedModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';
import 'messenger_page.dart';

class DetailPostScreen extends StatefulWidget {
  const DetailPostScreen({required this.newFeedModel, Key? key})
      : super(key: key);
  final NewfeedModel newFeedModel;

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  EmployeeModel employeeModel = EmployeeModel();
  DepartmentModel departmentModel = DepartmentModel();
  var data = <String, dynamic>{};

  Future<void> getPostInformation() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: widget.newFeedModel.employeeId)
        .get()
        .then((value) => {
              setState(() {
                employeeModel.id = value.docs.first['id'];
                employeeModel.name = value.docs.first['name'];
                employeeModel.password = value.docs.first['password'];
                employeeModel.phone = value.docs.first['phone'];
                employeeModel.image = value.docs.first['image'];
                employeeModel.department = value.docs.first['department'];
                employeeModel.roles = value.docs.first['roles'];
                employeeModel.status = value.docs.first['status'];
                employeeModel.email = value.docs.first['email'];
                employeeModel.category = value.docs.first['category'] ?? [];
              }),
            });
  }

  UserModel userData = UserModel();
  var currentUser = FirebaseAuth.instance.currentUser!;

  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: currentUser.uid)
        .get()
        .then((value) => {
      setState(() {
        userData.id = value.docs.first['userId'];
         userData.name = value.docs.first['name'];
        userData.email = value.docs.first['email'];
        userData.image = value.docs.first['image'];
        userData.password = value.docs.first['password'];
        userData.phone = value.docs.first['phone'];
        userData.group = value.docs.first['group'];
        userData.status = value.docs.first['status'];
      }),
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


  @override
  void initState() {
    getCurrentUser();
    getPostInformation();

    super.initState();
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
                    height: 480,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              height: 4,
                              width: 150,
                              margin: const EdgeInsets.only(top: 5,bottom: 10),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                color: Colors.blue,
                              ),
                            ),
                            const Text(
                              "You have question for this post?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w500),
                            ),
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              width: double.infinity,
                              child: StreamBuilder(
                                stream: informationControl,
                                builder: (context, snapshot) => TextField(
                                  controller: _informationController
                                    ..text = userData.email!,
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
                              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                          try {
                                          if (_onSendQuestionClicked()) {
                                            setState(() {
                                              _informationController.text = '';
                                              _questionController.text = '';

                                            });
                                            Navigator.pop(context);
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

  _modelBottomSheetSendMessage() {
    showModalBottomSheet(
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
                  onTap: (){
                    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: SizedBox(
                      height: 480,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 4,
                              width: 150,
                              margin: const EdgeInsets.only(top: 5,bottom: 10),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                color: Colors.blue,
                              ),
                            ),
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
                                    ..text = userData.email!,
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
                              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                              padding: const EdgeInsets.fromLTRB(30 , 0, 30, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _onSendMessageClicked();
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
          userData.id!,
          "Send ${employeeModel.name}",
          timeString,
          "Chưa trả lời",
          _informationController.text,
          employeeModel.department!,
          widget.newFeedModel.employeeId!,
          userData.group!,
          "to employee",
              () {});
    }
    return 0;
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

  _onSendQuestionClicked() async {
    var isvalid =
    isValid(_informationController.text, _questionController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadPdf();
    if (isvalid) {
      if (!mounted) return;
      LoadingDialog.showLoadingDialog(context, "Please Wait...");
      createChatRoom(
          userData.id!,
          "Post ${widget.newFeedModel.content}",
          timeString,
          "Chưa trả lời",
          _informationController.text,
          employeeModel.department!,
          '',
          userData.group!,
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

  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  final StreamController _informationControl = StreamController.broadcast();
  final StreamController _questionControl = StreamController.broadcast();

  Stream get informationControl => _informationControl.stream;
  Stream get questionControl => _questionControl.stream;

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

  @override
  void dispose() {
    super.dispose();
    _questionControl.close();
    _informationControl.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getPostInformation() ,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back_sharp),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.blueAccent,
                                  child: CircleAvatar(
                                    backgroundImage:
                                    NetworkImage(employeeModel.image!),
                                    radius: 22,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employeeModel.name!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                Text(
                                  widget.newFeedModel.time!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11),
                                ),
                              ],
                            )
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
                                            _modalBottomSheetAddQuestion(
                                                widget.newFeedModel);
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
                            icon: const Icon(Icons.more_vert_outlined)),

                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      height: 0,
                      color: Color(0xffAAAAAA),
                      indent: 0,
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                      child: Text(
                        widget.newFeedModel.content!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.newFeedModel.file != 'file.pdf')
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                        child: Image.network(
                          widget.newFeedModel.file!,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }else if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }else{
            return const SizedBox();
          }

        },
      ),
    );
  }
}
