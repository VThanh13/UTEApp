import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../blocs/auth_bloc.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';
import '../user/home_page.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class MyInfo extends StatefulWidget {
  const MyInfo({super.key});

  @override
  State<MyInfo> createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> with SingleTickerProviderStateMixin{
  AuthBloc authBloc = AuthBloc();


  late TabController _tabController;
  @override
  void initState(){
    super.initState();
    getCurrentUser();
    _tabController = TabController(length: 2, vsync: this);
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _passNew1Controller = TextEditingController();
  final TextEditingController _passNew2Controller = TextEditingController();

  final StreamController _nameControll = StreamController.broadcast();
  final StreamController _phoneControll = StreamController.broadcast();
  final StreamController _emailControll = StreamController.broadcast();
  final StreamController _passControll = StreamController.broadcast();
  final StreamController _passnew1Controll = StreamController.broadcast();
  final StreamController _passnew2Controll = StreamController.broadcast();

  Stream get emailStream => _emailControll.stream;
  Stream get nameStream => _nameControll.stream;
  Stream get phoneStream => _phoneControll.stream;
  Stream get passStream => _passControll.stream;
  Stream get passNew1Stream => _passnew1Controll.stream;
  Stream get passNew2Stream => _passnew2Controll.stream;

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
      _passControll.sink.addError("Please type your current password");
      return false;
    }
    _passControll.sink.add('');

    if (passNew1.isEmpty) {
      _passnew1Controll.sink.addError("Please type your new password");
      return false;
    }
    _passnew1Controll.sink.add('');

    if (passNew2.isEmpty) {
      _passnew2Controll.sink.addError("Please confirm your new password");
      return false;
    }
    _passnew2Controll.sink.add('');

    if (passNew1 != passNew2) {
      _passnew2Controll.sink.addError("Confirm password does not match");
      return false;
    }
    _passnew2Controll.sink.add('');

    if (passNew1.length < 6){
      _passnew1Controll.sink.addError("Password must be at least 6 characters");
      return false;
    }
    _passnew1Controll.sink.add('');

    if (hashPassword(pass) != userModel.password) {
      _passControll.sink.addError("Incorrect password");
      return false;
    }
    _passControll.sink.add('');

    if (passNew1 == pass) {
      _passnew1Controll.sink.addError("Your new password must be different than current password");
      return false;
    }
    _passnew1Controll.sink.add('');

    return true;
  }

  @override
  void dispose() {
    _nameControll.close();
    _emailControll.close();
    _phoneControll.close();
    _passControll.close();
    _passnew1Controll.close();
    _passnew2Controll.close();
    super.dispose();
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  var userAuth = FirebaseAuth.instance.currentUser!;
  UserModel userModel = UserModel();

  // Check if the user is signed in
  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(userAuth.uid)
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
      }),
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("user")
            .where("userId", isEqualTo: userAuth.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }

          // TODO: implement build
          return GestureDetector(
            onTap: () {
              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>const  HomePage(),
                        ),
                      );
                    }),
                title: const Text('Personal information'),
                backgroundColor: Colors.blueAccent,
              ),
              body: SafeArea(
                  minimum: const EdgeInsets.only(left: 20, right: 10),
                  child: SizedBox(
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
                                    backgroundImage: NetworkImage(userModel.image!),
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
                          userModel.name!,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
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
                                child: Text('Info',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,),
                              ),
                              Tab(
                                child: Text('Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: TabBarView(
                          controller: _tabController,
                          children: [
                            SingleChildScrollView(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                                      width: 400,
                                      child: StreamBuilder(
                                        stream: nameStream,
                                        builder: (context, snapshot) => TextField(
                                          controller: _nameController..text = userModel.name!,
                                          onChanged: (text) => {},
                                          decoration: InputDecoration(
                                            labelText: "Your name",
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
                                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                                      width: 400,
                                      child: StreamBuilder(
                                        stream: phoneStream,
                                        builder: (context, snapshot) => TextField(
                                          controller: _phoneController..text = userModel.phone!,
                                          onChanged: (text) => {},
                                          decoration: InputDecoration(
                                            labelText: "Your phone number",
                                            errorText: snapshot.hasError
                                                ? snapshot.error.toString()
                                                : null,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Colors.blueAccent,
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.blue, width: 4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                                      width: 400,
                                      child: StreamBuilder(
                                        stream: emailStream,
                                        builder: (context, snapshot) => TextField(
                                          controller: _emailController..text = userModel.email!,
                                          onChanged: (text) => {},
                                          decoration: InputDecoration(
                                            labelText: "Your Email",
                                            errorText: snapshot.hasError
                                                ? snapshot.error.toString()
                                                : null,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Colors.blueAccent,
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.blue, width: 4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                _onSaveClicked();
                                              },
                                              label: const Text(
                                                'Save',
                                                style: TextStyle(
                                                    fontSize: 16, color: Colors.white),
                                              ),
                                              icon: const Icon(Icons.save_outlined),
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
                                          0, 10, 0, 15),
                                      width: 400,
                                      child: StreamBuilder(
                                        stream: passStream,
                                        builder: (context, snapshot) =>
                                            TextField(
                                              decoration: InputDecoration(
                                                  labelText: "Current Password",
                                                  errorText: snapshot.hasError
                                                      ? snapshot.error.toString()
                                                      : null,
                                                  hintText:
                                                  'Please insert your password',
                                                  enabledBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10),
                                                      borderSide:
                                                      const BorderSide(
                                                        color: Colors
                                                            .blueAccent,
                                                        width: 1,
                                                      )),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(10),
                                                      borderSide:
                                                      const BorderSide(
                                                          color:
                                                          Colors.blue,
                                                          width: 4))),
                                              controller: _passController,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 15),
                                      width: 400,
                                      child: StreamBuilder(
                                        stream: passNew1Stream,
                                        builder: (context, snapshot) =>
                                            TextField(
                                              decoration: InputDecoration(
                                                  labelText: "New password",
                                                  errorText: snapshot.hasError
                                                      ? snapshot.error.toString()
                                                      : null,
                                                  hintText:
                                                  'Please insert new password',
                                                  enabledBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10),
                                                      borderSide:
                                                      const BorderSide(
                                                        color: Colors
                                                            .blueAccent,
                                                        width: 1,
                                                      )),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(10),
                                                      borderSide:
                                                      const BorderSide(
                                                          color:
                                                          Colors.blue,
                                                          width: 4))),
                                              controller: _passNew1Controller,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 15),
                                      width: 400,
                                      child: StreamBuilder(
                                        stream: passNew2Stream,
                                        builder: (context, snapshot) =>
                                            TextField(
                                              decoration: InputDecoration(
                                                  labelText:
                                                  "Confirm password",
                                                  errorText: snapshot.hasError
                                                      ? snapshot.error.toString()
                                                      : null,
                                                  hintText:
                                                  'Confirm your password',
                                                  enabledBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          10),
                                                      borderSide:
                                                      const BorderSide(
                                                        color: Colors
                                                            .blueAccent,
                                                        width: 1,
                                                      )),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(10),
                                                      borderSide:
                                                      const BorderSide(
                                                          color:
                                                          Colors.blue,
                                                          width: 4))),
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
                                              icon:
                                              const Icon(Icons.check),
                                              style: ElevatedButton
                                                  .styleFrom(
                                                  backgroundColor: Colors
                                                      .blueAccent),
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
                        ),),

                      ],
                    ),
                  )
              ),
            ),
          );
        });
  }

  _onSaveClicked() {
    var isvalid = isValid(
        _nameController.text, _emailController.text, _phoneController.text);

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "Please Wait...");
      changeInfo(
          _emailController.text, _nameController.text, _phoneController.text,
          () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyInfo()));
        showSuccessMessage('Update info success');
      });
    }
  }

  _onChangePassword() {
    var isvalid = isValidChangePass(
        _passController.text,
        _passNew1Controller.text,
        _passNew2Controller.text);

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "Please Wait...");
      userAuth.updatePassword(_passNew2Controller.text);
      changePassword(_passNew2Controller.text, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyInfo()));
        showSuccessMessage('Change password success');
      });
    }
  }

  void changeInfo(String email, String name, String phone, Function onSuccess) async {
    var ref = FirebaseFirestore.instance.collection('user');

    ref.doc(userAuth.uid)
        .update({'email': email, 'name': name, 'phone': phone}).then((value) {
      onSuccess();
    }).catchError((err) {

    });
  }

  void changePassword(String pass, Function onSuccess) async {
    String password = hashPassword(pass);

    var ref = FirebaseFirestore.instance.collection('user');
    ref.doc(userAuth.uid).update({'password': password}).then((value) {
      onSuccess();
    }).catchError((err) {});
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
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
                MaterialPageRoute(builder: (context) => const MyInfo()));
          });
        }).catchError((onError) {
          return onError;
        });
      } else {}
    } else {}
  }

  updateAvatar(id, imageUrl, Function onSuccess) async {
    var ref = FirebaseFirestore.instance.collection('user');
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
