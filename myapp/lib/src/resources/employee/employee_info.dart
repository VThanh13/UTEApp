import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/src/resources/leader/home_page_leader.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../blocs/auth_bloc.dart';
import '../../models/EmployeeModel.dart';
import '../dialog/loading_dialog.dart';
import '../manager/home_page_manager.dart';
import 'home_page_employee.dart';

class EmployeeInfo extends StatefulWidget {
  const EmployeeInfo({super.key});

  @override
  State<EmployeeInfo> createState() => _MyInfoState();
}

class _MyInfoState extends State<EmployeeInfo>
    with SingleTickerProviderStateMixin {
  AuthBloc authBloc = AuthBloc();
  var userAuth = FirebaseAuth.instance.currentUser!;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _passNew1Controller = TextEditingController();
  final TextEditingController _passNew2Controller = TextEditingController();

  final StreamController _nameControll = StreamController.broadcast();
  final StreamController _phoneControll = StreamController.broadcast();
  final StreamController _emailControll = StreamController.broadcast();
  final StreamController _passwordControll = StreamController.broadcast();
  final StreamController _passControll = StreamController.broadcast();
  final StreamController _passnew1Controll = StreamController.broadcast();
  final StreamController _passnew2Controll = StreamController.broadcast();

  Stream get emailStream => _emailControll.stream;
  Stream get nameStream => _nameControll.stream;
  Stream get phoneStream => _phoneControll.stream;
  Stream get passwordStream => _passwordControll.stream;
  Stream get passStream => _passControll.stream;
  Stream get passnew1Stream => _passnew1Controll.stream;
  Stream get passnew2Stream => _passnew2Controll.stream;

  bool isValid(String name, String email, String phone) {
    if (name.isEmpty) {
      _nameControll.sink.addError("Please insert your name");
      return false;
    }
    _nameControll.sink.add("");

    if (email.isEmpty) {
      _emailControll.sink.addError("Please insert your email");
      return false;
    }
    _emailControll.sink.add("");

    if (phone.isEmpty) {
      _phoneControll.sink.addError("Please insert your phone number");
      return false;
    }
    _phoneControll.sink.add("");

    return true;
  }

  bool isValidChangePass(String pass, String passNew1, String passNew2) {
    if (pass.isEmpty) {
      _passControll.sink.addError("Please insert your password");
      return false;
    }
    _passControll.sink.add('');

    if (passNew1.isEmpty) {
      _passnew1Controll.sink.addError("Please insert your new password");
      return false;
    }
    _passnew1Controll.sink.add('');

    if (passNew2.isEmpty) {
      _passnew2Controll.sink.addError("Confirm new password");
      return false;
    }
    _passnew2Controll.sink.add('');

    if (passNew1 != passNew2) {
      _passnew2Controll.sink.addError("New password not match");
      return false;
    }
    _passnew2Controll.sink.add('');

    return true;
  }

  @override
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
  var userAu = FirebaseAuth.instance.currentUser!;
  EmployeeModel currentEmployee = EmployeeModel();
  String departmentName = "";
  getEmployee() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: userAu.uid)
        .get()
        .then((value) => {
              setState(() {
                currentEmployee.id = value.docs.first['id'];
                currentEmployee.name = value.docs.first['name'];
                currentEmployee.email = value.docs.first['email'];
                currentEmployee.image = value.docs.first['image'];
                currentEmployee.password = value.docs.first['password'];
                currentEmployee.phone = value.docs.first['phone'];
                currentEmployee.department = value.docs.first['department'];
                currentEmployee.category =
                    value.docs.first['category'].cast<String>();
                currentEmployee.roles = value.docs.first['roles'];
                currentEmployee.status = value.docs.first['status'];
              })
            });

    await getDepartmentName();
  }

  getDepartmentName() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('departments')
        .where('id', isEqualTo: currentEmployee.department)
        .get()
        .then((value) => {
              setState(() {
                departmentName = value.docs.first["name"];
              })
            });
  }

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    getEmployee();
    _tabController = TabController(length: 2, vsync: this);
    //getDepartmentName();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("employee")
            .where("id", isEqualTo: userAu.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }
          snapshot.data!.docs.map((e) {
            //getDepartmentName(setState);
            return currentEmployee;
          }).toString();
          return GestureDetector(
            onTap: () {
              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (currentEmployee.roles == "Tư vấn viên") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const HomePageEmployee()));
                      } else if (currentEmployee.roles == "Trưởng nhóm") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const HomePageLeader(),
                          ),
                        );
                      } else if (currentEmployee.roles == "Manager") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const HomePageManager(),
                          ),
                        );
                      }
                    }),
                title: const Text('Personal information'),
                backgroundColor: Colors.blueAccent,
              ),
              body: SafeArea(
                minimum: const EdgeInsets.only(left: 20, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 0)),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      height: 100,
                      child: Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: Colors.tealAccent,
                              child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(currentEmployee.image!),
                                radius: 40,
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 2,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                  color: Colors.green,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    uploadImage();
                                  },
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  icon: const Icon(
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
                    Text(
                      currentEmployee.name!,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      currentEmployee.roles!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Container(
                      height: 46,
                      width: 283,
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.blue,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(
                            child: Text(
                              'Info',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Tab(
                            child: Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          SingleChildScrollView(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Column(
                                children: [
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 10),
                                    width: 400,
                                    child: StreamBuilder(
                                      stream: nameStream,
                                      builder: (context, snapshot) => TextField(
                                        controller: _nameController
                                          ..text = currentEmployee.name!,
                                        onChanged: (text) => {},
                                        decoration: InputDecoration(
                                          labelText: "Your name",
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
                                              width: 4,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 10),
                                      width: 400,
                                      child: StreamBuilder(
                                        stream: phoneStream,
                                        builder: (context, snapshot) =>
                                            TextField(
                                          controller: _phoneController
                                            ..text = currentEmployee.phone!,
                                          onChanged: (text) => {},
                                          decoration: InputDecoration(
                                            labelText: "Your phone number",
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
                                                width: 4,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                                  Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 10),
                                      width: 400,
                                      child: StreamBuilder(
                                        stream: emailStream,
                                        builder: (context, snapshot) =>
                                            TextField(
                                          controller: _emailController
                                            ..text = currentEmployee.email!,
                                          onChanged: (text) => {},
                                          decoration: InputDecoration(
                                              labelText: "Your Email",
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
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                    width: 400,
                                    child: TextField(
                                      readOnly: true,
                                      controller: TextEditingController()
                                        ..text = departmentName,
                                      onChanged: (text) => {},
                                      decoration: InputDecoration(
                                        labelText: "Your department",
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
                                                if (_onSaveClicked()) {
                                                  showSuccessMessage(
                                                      'Update info success');
                                                } else {
                                                  showErrorMessage(
                                                      'Update info failed');
                                                }
                                              } catch (e) {
                                                //
                                              }
                                            },
                                            label: const Text(
                                              'Save',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            icon:
                                                const Icon(Icons.save_outlined),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blueAccent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        15, 10, 15, 15),
                                    width: 400,
                                    child: StreamBuilder(
                                      stream: passStream,
                                      builder: (context, snapshot) => TextField(
                                        decoration: InputDecoration(
                                          labelText: "Password",
                                          errorText: snapshot.hasError
                                              ? snapshot.error.toString()
                                              : null,
                                          hintText:
                                              'Please insert your password',
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
                                              width: 4,
                                            ),
                                          ),
                                        ),
                                        controller: _passController,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        15, 10, 15, 15),
                                    width: 400,
                                    child: StreamBuilder(
                                      stream: passnew1Stream,
                                      builder: (context, snapshot) => TextField(
                                        decoration: InputDecoration(
                                            labelText: "New password",
                                            errorText: snapshot.hasError
                                                ? snapshot.error.toString()
                                                : null,
                                            hintText:
                                                'Please insert new password',
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
                                        controller: _passNew1Controller,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        15, 10, 15, 15),
                                    width: 400,
                                    child: StreamBuilder(
                                      stream: passnew2Stream,
                                      builder: (context, snapshot) => TextField(
                                        decoration: InputDecoration(
                                          labelText: "Confirm password",
                                          hintText: 'Confirm your password',
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
                                              width: 4,
                                            ),
                                          ),
                                        ),
                                        controller: _passNew2Controller,
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
                                                if (_onChangePassword()) {
                                                  setState(() {
                                                    _passController.text = '';
                                                    _passNew1Controller.text =
                                                        '';
                                                    _passNew2Controller.text =
                                                        '';
                                                  });
                                                } else {
                                                  setState(() {
                                                    _passController.text = '';
                                                    _passNew1Controller.text =
                                                        '';
                                                    _passNew2Controller.text =
                                                        '';
                                                  });
                                                  showErrorMessage(
                                                      'Change password failed');
                                                }
                                              } catch (e) {
                                                //
                                              }
                                            },
                                            label: const Text(
                                              'Save',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            icon: const Icon(Icons.check),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blueAccent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
    var isValidData = isValid(
        _nameController.text, _emailController.text, _phoneController.text);

    if (isValidData) {
      LoadingDialog.showLoadingDialog(context, "Please Wait...");
      changeInfo(
          _emailController.text, _nameController.text, _phoneController.text,
          () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomePageLeader()));
        showSuccessMessage('Update info success');
      });
    }
  }

  _onChangePassword() {
    var isvalid = isValidChangePass(
      _passController.text,
      _passNew1Controller.text,
      _passNew2Controller.text,
    );

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "Please Wait...");
      userAu.updatePassword(_passNew2Controller.text);
      changePassword(_passNew2Controller.text, () {
        LoadingDialog.hideLoadingDialog(context);
        if (currentEmployee.roles == "Tư vấn viên") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomePageEmployee()));
        } else if (currentEmployee.roles == "Trưởng nhóm") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const HomePageLeader(),
            ),
          );
        } else if (currentEmployee.roles == "Manager") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const HomePageManager(),
            ),
          );
        }
        showSuccessMessage('Change password success');
      });
    }
  }

  void changePassword(String pass, Function onSuccess) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: userAu.uid)
        .get();
    String id = snapshot.docs.first.id;
    var ref = FirebaseFirestore.instance.collection('employee');

    ref.doc(id).update({'password': pass}).then((value) {
      onSuccess();
    }).catchError((err) {});
  }

  void changeInfo(
      String email, String name, String phone, Function onSuccess) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: userAu.uid)
        .get();
    String id = snapshot.docs.first.id;
    var ref = FirebaseFirestore.instance.collection('employee');
    ref
        .doc(id)
        .update({'email': email, 'name': name, 'phone': phone}).then((value) {
      onSuccess();
    }).catchError((err) {});
  }

  uploadImage() async {
    final imagePicker = ImagePicker();
    String imageUrl;
    //PickedFile image;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      //Select Image
      var image = await imagePicker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        var file = File(image.path);
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child("avatar/${image.name}");
        UploadTask uploadTask = ref.putFile(file);
        await uploadTask.whenComplete(() async {
          var url = await ref.getDownloadURL();
          imageUrl = url.toString();
          updateAvatar(userAuth.uid, imageUrl, () {
            LoadingDialog.hideLoadingDialog(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const EmployeeInfo()));
          });
        }).catchError((onError) {
          return onError;
        });
      } else {}
    } else {}
  }

  updateAvatar(id, imageUrl, Function onSuccess) async {
    var ref = FirebaseFirestore.instance.collection('employee');

    ref.doc(id).update({'image': imageUrl}).then((value) {
      onSuccess();
    }).catchError((err) {
      return err;
    });
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blueAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
