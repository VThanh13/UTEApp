import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/models/DepartmentModel.dart';
import 'package:myapp/src/models/EmployeeModel.dart';


import '../../models/NewfeedModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';
import '../user/messenger_page.dart';


class LeaderDetailPost extends StatefulWidget {
  const LeaderDetailPost({required this.newFeedModel, Key? key})
      : super(key: key);
  final NewfeedModel newFeedModel;

  @override
  State<LeaderDetailPost> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<LeaderDetailPost> {
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
      const maxFileSize = 5 * 1024 * 1024; // Giới hạn kích thước 5MB

      if (fileSize > maxFileSize) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Kích thước tệp PDF vượt quá giới hạn'),
            content: const Text('Kích thước tệp PDF quá lớn, vui lòng chọn tệp nhỏ hơn.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
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
      const maxFileSize = 1024 * 1024; // Giới hạn kích thước 1MB

      if (fileSize > maxFileSize) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Kích thước ảnh vượt quá giới hạn'),
            content: const Text('Kích thước ảnh quá lớn, vui lòng chọn ảnh nhỏ hơn.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
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
