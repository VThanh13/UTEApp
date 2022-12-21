import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../blocs/auth_bloc.dart';
import '../../models/EmployeeModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';
import '../home_page.dart';

class EmployeeInfo extends StatefulWidget {
  @override
  _MyInfoState createState() => new _MyInfoState();
}

class _MyInfoState extends State<EmployeeInfo> {
  AuthBloc authBloc = new AuthBloc();
  var user_auth = FirebaseAuth.instance.currentUser!;
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  TextEditingController _passnew1Controller = new TextEditingController();
  TextEditingController _passnew2Controller = new TextEditingController();

  StreamController _nameControll = new StreamController.broadcast();
  StreamController _phoneControll = new StreamController.broadcast();
  StreamController _emailControll = new StreamController.broadcast();
  StreamController _passwordControll = new StreamController.broadcast();
  StreamController _passControll = new StreamController.broadcast();
  StreamController _passnew1Controll = new StreamController.broadcast();
  StreamController _passnew2Controll = new StreamController.broadcast();

  Stream get emailStream => _emailControll.stream;
  Stream get nameStream => _nameControll.stream;
  Stream get phoneStream => _phoneControll.stream;
  Stream get passwordStream => _passwordControll.stream;
  Stream get passStream => _passControll.stream;
  Stream get passnew1Stream => _passnew1Controll.stream;
  Stream get passnew2Stream => _passnew2Controll.stream;

  bool isValid(String name, String email, String phone) {
    if (name == null || name.length == 0) {
      _nameControll.sink.addError("Nhập tên");
      return false;
    }
    _nameControll.sink.add("");

    if (email == null || email.length == 0) {
      _emailControll.sink.addError("Nhập email");
      return false;
    }
    _emailControll.sink.add("");

    if (phone == null || phone.length == 0) {
      _phoneControll.sink.addError("Nhập số điện thoại");
      return false;
    }
    _phoneControll.sink.add("");

    return true;
  }

  bool isValidChangePass(
      String pass, String passnew1, String passnew2, String password) {
    if (pass == null || pass.length == 0) {
      _passControll.sink.addError("Nhập password");
      return false;
    }
    if (passnew1 == null || passnew1.length == 0) {
      _passnew1Controll.sink.addError("Nhập mật khẩu mới");
      return false;
    }

    if (passnew2 == null || passnew2.length == 0) {
      _passnew2Controll.sink.addError("Xác nhận mật khẩu");
      return false;
    }

    if (passnew1 != passnew2) {
      _passnew2Controll.sink.addError("Mật khẩu không trùng khớp");
      return false;
    }
    if (pass != password) {
      _passControll.sink.addError("Mật khẩu không đúng");
      return false;
    }

    return true;
  }

  void dispose() {
    _nameControll.close();
    _emailControll.close();

    _phoneControll.close();
    _passwordControll.close();
    _passControll.close();
    _passnew1Controll.close();
    _passnew2Controll.close();
    super.dispose();
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  var userr = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel =
      new EmployeeModel("", "", "", "", "", "", "", "", "", "");
  String departmentName = "";
  getEmployee() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: userr.uid)
        .get()
        .then((value) => {
              //setState((){
              employeeModel.id = value.docs.first['id'],
              employeeModel.name = value.docs.first['name'],
              employeeModel.email = value.docs.first['email'],
              employeeModel.image = value.docs.first['image'],
              employeeModel.password = value.docs.first['password'],
              employeeModel.phone = value.docs.first['phone'],
              employeeModel.department = value.docs.first['department'],
              employeeModel.category = value.docs.first['category'],
              employeeModel.roles = value.docs.first['roles'],
              employeeModel.status = value.docs.first['status']
              //})
            });

    await getDepartmentName();
  }

  getDepartmentName() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('departments')
        .where('id', isEqualTo: employeeModel.department)
        .get()
        .then((value) => {
              setState(() {
                departmentName = value.docs.first["name"];
              })
            });
  }

  @override
  void initState() {
    super.initState();
    getEmployee();
    //getDepartmentName();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("employee")
            .where("id", isEqualTo: userr.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Container(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }
          snapshot.data!.docs.map((e) {
            //getDepartmentName(setState);
            return employeeModel;
          }).toString();
          // TODO: implement build
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Thông tin cá nhân'),
            ),
            body: SafeArea(
              minimum: const EdgeInsets.only(left: 20, right: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      height: 150,
                      child: Center(
                        child: Stack(
                          children: [
                            new CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.tealAccent,
                              child: CircleAvatar(
                                backgroundImage:
                                    new NetworkImage(employeeModel.image!),
                                radius: 50,
                              ),
                            ),
                            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 4,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                  color: Colors.green,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    uploadImage();
                                  },
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
                    Text(
                      employeeModel.roles!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Text(
                      employeeModel.name!,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
                    Container(
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                        width: 400,
                        child: StreamBuilder(
                          stream: nameStream,
                          builder: (context, snapshot) => TextField(
                            controller: _nameController
                              ..text = employeeModel.name!,
                            onChanged: (text) => {},
                            decoration: InputDecoration(
                                labelText: "Tên của bạn",
                                errorText: snapshot.hasError
                                    ? snapshot.error.toString()
                                    : null,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.orangeAccent,
                                      width: 1,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.orange, width: 4))),
                          ),
                        )),
                    Container(
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                        width: 400,
                        child: StreamBuilder(
                          stream: phoneStream,
                          builder: (context, snapshot) => TextField(
                            controller: _phoneController
                              ..text = employeeModel.phone!,
                            onChanged: (text) => {},
                            decoration: InputDecoration(
                                labelText: "SĐT của bạn",
                                errorText: snapshot.hasError
                                    ? snapshot.error.toString()
                                    : null,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.orangeAccent,
                                      width: 1,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.orange, width: 4))),
                          ),
                        )),
                    Container(
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                        width: 400,
                        child: StreamBuilder(
                          stream: emailStream,
                          builder: (context, snapshot) => TextField(
                            controller: _emailController
                              ..text = employeeModel.email!,
                            onChanged: (text) => {},
                            decoration: InputDecoration(
                                labelText: "Email của bạn",
                                errorText: snapshot.hasError
                                    ? snapshot.error.toString()
                                    : null,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.orangeAccent,
                                      width: 1,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.orange, width: 4))),
                          ),
                        )),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                      width: 400,
                      child: StreamBuilder(
                        stream: passwordStream,
                        builder: (context, snapshot) => TextField(
                          readOnly: true,
                          controller: _passwordController
                            ..text = employeeModel.password!,
                          onChanged: (text) => {},
                          decoration: InputDecoration(
                              labelText: "Mật khẩu của bạn",
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.orangeAccent,
                                    width: 1,
                                  )),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.orange, width: 4))),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                      width: 400,
                      child: TextField(
                        readOnly: true,
                        controller: TextEditingController()
                          ..text = departmentName,
                        onChanged: (text) => {},
                        decoration: InputDecoration(
                            labelText: "Khoa của bạn",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.orangeAccent,
                                  width: 1,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.orange, width: 4))),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                print('press save');
                                _onSaveClicked();
                              },
                              label: Text(
                                'Lưu',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              icon: Icon(Icons.save_outlined),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orangeAccent
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          Expanded(
                              child: ElevatedButton.icon(
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Column(
                                            children: <Widget>[
                                              Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                                              Text(
                                                "Đổi mật khẩu",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    15, 10, 15, 15),
                                                width: 400,
                                                child: StreamBuilder(
                                                  stream: passStream,
                                                  builder:
                                                      (context, snapshot) =>
                                                          TextField(
                                                    decoration: InputDecoration(
                                                        labelText: "Mật khẩu",
                                                        hintText:
                                                            'Nhập mật khẩu của bạn',
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: Colors.orangeAccent,
                                                                  width: 1,
                                                                )),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .orange,
                                                                    width: 4))),
                                                    controller: _passController,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    15, 10, 15, 15),
                                                width: 400,
                                                child: StreamBuilder(
                                                  stream: passnew1Stream,
                                                  builder:
                                                      (context, snapshot) =>
                                                          TextField(
                                                    decoration: InputDecoration(
                                                        labelText:
                                                            "Mật khẩu mới",
                                                        hintText:
                                                            'Nhập mật khẩu mới của bạn',
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: Colors.orangeAccent,
                                                                  width: 1,
                                                                )),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors.orange,
                                                                    width: 4))),
                                                    controller:
                                                        _passnew1Controller,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    15, 10, 15, 15),
                                                width: 400,
                                                child: StreamBuilder(
                                                  stream: passnew2Stream,
                                                  builder:
                                                      (context, snapshot) =>
                                                          TextField(
                                                    decoration: InputDecoration(
                                                        labelText:
                                                            "Xác nhận mật khẩu",
                                                        hintText:
                                                            'Nhập lại mật khẩu của bạn',
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: Colors.orangeAccent,
                                                                  width: 1,
                                                                )),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .orange,
                                                                    width: 4))),
                                                    controller:
                                                        _passnew2Controller,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: () {
                                                          _onChangePassword();
                                                          print('press save');
                                                        },
                                                        label: Text(
                                                          'Lưu',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        icon: Icon(Icons.check),
                                                        style: ElevatedButton.styleFrom(
                                                          primary: Colors.orangeAccent
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(10)),
                                                    Expanded(
                                                        child: ElevatedButton.icon(
                                                            onPressed: () => {
                                                                  Navigator.pop(
                                                                      context)
                                                                },
                                                            label: Text(
                                                              'Thoát',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                        icon: Icon(Icons.cancel_rounded),
                                                        style: ElevatedButton.styleFrom(
                                                          primary: Colors.orangeAccent
                                                        ),)),
                                                  ],
                                                ),
                                              )
                                            ],
                                          );
                                        });
                                  },
                                  label: const Text('Đổi mật khẩu'),
                              icon: Icon(Icons.security_rounded),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orangeAccent
                              ),)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _onSaveClicked() {
    var isvalid = isValid(
        _nameController.text, _emailController.text, _phoneController.text);

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      changeInfo(
          _emailController.text, _nameController.text, _phoneController.text,
          () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      });
    }
  }

  _onChangePassword() {
    var isvalid = isValidChangePass(
        _passController.text,
        _passnew1Controller.text,
        _passnew2Controller.text,
        _passwordController.text);

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      userr.updatePassword(_passnew2Controller.text);
      changePassword(_passnew2Controller.text, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      });
    }
  }

  void changePassword(String pass, Function onSuccess) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: userr.uid)
        .get();
    String id = snapshot.docs.first.id;
    var ref = FirebaseFirestore.instance.collection('employee');

    ref.doc(id).update({'password': pass}).then((value) {
      onSuccess();
      print("change pass ok");
    }).catchError((err) {
      print("err");
    });
  }

  void changeInfo(
      String email, String name, String phone, Function onSuccess) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: userr.uid)
        .get();
    String id = snapshot.docs.first.id;
    var user = {"email": email, "name": name, "phone": phone};

    var ref = FirebaseFirestore.instance.collection('employee');

    ref

        .doc(id)
        .update({'email': email, 'name': name, 'phone': phone}).then((value) {
      onSuccess();
      print("add user");
    }).catchError((err) {
      //TODO
      print("err");
    });
  }
  uploadImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    String image_url;
    //PickedFile image;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Select Image
      var image = await _imagePicker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        var file = File(image.path);
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref =
        storage.ref().child("avatar/"+image.name);
        UploadTask uploadTask = ref.putFile(file);
        await uploadTask.whenComplete(() async {
          var url = await ref.getDownloadURL();
          image_url = url.toString();
          updateAvatar(user_auth.uid, image_url, () {
            LoadingDialog.hideLoadingDialog(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EmployeeInfo()));
          });
        }).catchError((onError) {
          print(onError);
        });
        print('Avatar');
      } else {
        print('No Image Path Received');
      }
    } else {
      print('Permission not granted. Try Again with permission access');
    }
  }

  updateAvatar(id, image_url, Function onSuccess) async {
    var ref = FirebaseFirestore.instance.collection('employee');

    ref.doc(id).update({
      'image': image_url
    }).then((value) {
      onSuccess();
      print("update successful");
    }).catchError((err){
      //TODO
      print("err");
      print(err);
    });
  }
}


