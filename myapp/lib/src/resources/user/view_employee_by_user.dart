import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/models/EmployeeModel.dart';
import 'package:myapp/src/models/UserModel.dart';
import 'messenger_page.dart';
import '../../blocs/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dialog/loading_dialog.dart';

class ViewEmployeeByUser extends StatefulWidget {
  @override
  State<ViewEmployeeByUser> createState() => _ViewEmployeeByUser();

  final EmployeeModel employee;

  const ViewEmployeeByUser(
      {super.key, required this.employee, required this.users});

  final UserModel users;
}

class _ViewEmployeeByUser extends State<ViewEmployeeByUser> {
  AuthBloc authBloc = AuthBloc();

  FirebaseAuth auth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser!;
  UserModel userModel = UserModel();

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));

  String departmentName = "";

  getDepartmentName() async {
    await FirebaseFirestore.instance
      .collection('departments')
      .doc(widget.employee.department)
      .get()
      .then((value) => {
        setState(() {
          departmentName = value["name"];
        })
      });
  }

  var listDepartmentName = {};
  getDepartment() async {
    await FirebaseFirestore.instance
      .collection('departments')
      .get()
      .then((value) => {
        setState(() {
          for (var element in value.docs) {
            listDepartmentName[element.id] = element["name"];
          }
        })
      });
  }

  getCurrentUser() async {
    await FirebaseFirestore.instance
      .collection('user')
      .doc(currentUser.uid)
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
  }

  @override
  void initState() {
    super.initState();
    getDepartmentName();
    getDepartment();
    getCurrentUser();
  }

  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  final StreamController _informationControl = StreamController.broadcast();
  final StreamController _questionControl = StreamController.broadcast();

  Stream get informationControl => _informationControl.stream;
  Stream get questionControl => _questionControl.stream;

  bool isValid(String information, String question) {
    if (information.isEmpty) {
      _informationControl.sink.addError("Insert your Email/Phone");
      return false;
    }

    if (question.isEmpty) {
      _questionControl.sink.addError("Insert message");
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _questionControl.close();
    _informationControl.close();
    super.dispose();
  }

  _onSendQuestionClicked() async {
    var isvalid = isValid(_informationController.text, _questionController.text);
    var time = DateTime.now();
    String timeString = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    await uploadPdf();
    if (isvalid) {
      if (!mounted) return;
      LoadingDialog.showLoadingDialog(context, "Please Wait...");
      createChatRoom(
          userModel.id!,
          "Send ${widget.employee.name}",
          timeString,
          "Chưa trả lời",
          _informationController.text,
          widget.employee.department!,
          widget.employee.id!,
          userModel.group!,
          "to employee",
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

  _modelBottomSheetSendMessage(){
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder:
              (BuildContext context,
              StateSetter setStateKhoa) {
            return Padding(
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
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(
                            0, 20, 0, 5),
                        width: 340,
                        child: StreamBuilder(
                          stream: informationControl,
                          builder: (context, snapshot) =>
                              TextField(
                                controller: _informationController
                                ..text = userModel.email!,
                                decoration: InputDecoration(
                                  labelText: "Contact method",
                                  hintText:
                                  'Insert your Email/Phone',
                                  errorText: snapshot.hasError? snapshot.error.toString() : null,
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
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                      Container(
                        width: 340,
                        margin: const EdgeInsets.fromLTRB(
                            0, 10, 0, 0),
                        child: StreamBuilder(
                          stream: questionControl,
                          builder: (context, snapshot) =>
                              TextField(
                                controller: _questionController,
                                maxLines: 50,
                                minLines: 7,
                                maxLength: 3000,
                                decoration: InputDecoration(
                                  hintMaxLines: 5,
                                  helperMaxLines: 5,
                                  labelText: "Send question",
                                  hintText: 'Insert your question',
                                  errorText: snapshot.hasError? snapshot.error.toString() : null,
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
                                        width: 4),
                                  ),
                                ),
                              ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            importPdf();
                          },
                          color: hadFile
                              ? Colors.redAccent
                              : Colors.black,
                          icon: const Icon(AppIcons.file_pdf)
                      ),
                      hadFile ? const Text(
                        'One file selected',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.red),
                      ) : const Text('No file selected',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _onSendQuestionClicked();
                                },
                                label: const Text(
                                  'Send',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                                icon: const Icon(
                                    Icons.mail_outline_rounded),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(10),),
                            Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                  {Navigator.pop(context)},
                                  label: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white),
                                  ),
                                  icon: const Icon(
                                      Icons.cancel_presentation),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent),
                                ),),
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
            );
          });
        });
  }

  _listCategory() {
    List<Widget> categoryList = [];
    for (var category in widget.employee.category!) {
      categoryList.add(
        Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.quiz_outlined,
                size: 30,),
              const Padding(padding: EdgeInsets.only(left: 15)),
              Expanded(
                  child: Text(category,
                    style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,))
            ],
          ),
        )
      );

    }
    return Column(children: categoryList);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    const SizedBox(
                      height: 300,
                      width: double.infinity,
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30))
                      ),
                      child: const ClipRRect(
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30)),
                        child: Image(
                          image: AssetImage("assets/images/cover.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_sharp,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 140,
                        width: 140,
                        margin: const EdgeInsets.only(top: 150),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(widget.employee.image!),
                            radius: 66,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    children: <Widget>[
                      Text(widget.employee.name!,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      Text(widget.employee.roles!,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 1),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.mark_chat_unread),
                          onPressed: () {
                            _modelBottomSheetSendMessage();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          label: const Text(
                            "Message",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.only(left: 15, bottom: 5,  top: 10),
                      child:  Text('Contact Info',
                        style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.mail_outline,
                            size: 30,),
                          const Padding(padding: EdgeInsets.only(left: 15)),
                          const Text('Email: ',
                            style: TextStyle(
                                fontSize: 17
                            ),),
                          Text(widget.employee.email!,
                            style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold,
                            ),)
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.phone,
                            size: 30,),
                          const Padding(padding: EdgeInsets.only(left: 15)),
                          const Text('Phone: ',
                            style: TextStyle(
                                fontSize: 17
                            ),),
                          Text(widget.employee.phone!,
                            style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold,
                            ),)
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.badge_outlined,
                            size: 30,),
                          const Padding(padding: EdgeInsets.only(left: 15)),
                          Text(departmentName,
                            style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,)
                        ],
                      ),
                    ),
                    if(widget.employee.category![0] != "")
                      _listCategory()
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
