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
import '../home_page.dart';

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
    _tabController = TabController(length: 2, vsync: this);
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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

  bool isValidChangePass(
      String pass, String passNew1, String passNew2, String password) {
    if (pass.isEmpty) {
      _passControll.sink.addError("Please insert your password");
      return false;
    }
    if (passNew1.isEmpty) {
      _passnew1Controll.sink.addError("Please insert your new password");
      return false;
    }

    if (passNew2.isEmpty) {
      _passnew2Controll.sink.addError("Confirm new password");
      return false;
    }

    if (passNew1 != passNew2) {
      _passnew2Controll.sink.addError("New password not match");
      return false;
    }
    if (pass != password) {
      _passControll.sink.addError("Password not true");
      return false;
    }

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
  var userR = FirebaseAuth.instance.currentUser!;
  String name = "1234";
  UserModel userModel = UserModel("", " ", "", "", "", "", "", "");

  Future<String> getUserNameFromUID() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: userR.uid)
        .get();
    return snapshot.docs.first['name'];
  }

  // Check if the user is signed in
  getCurrentUser() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: userR.uid)
        .get();
    userModel = snapshot.docs.first as UserModel;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("user")
            .where("userId", isEqualTo: userR.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }
          snapshot.data!.docs.map((e) {
            userModel.id = (e.data() as Map)['userId'];
            userModel.name = (e.data() as Map)['name'];
            userModel.email = (e.data() as Map)['email'];
            userModel.image = (e.data() as Map)['image'];
            userModel.password = (e.data() as Map)['password'];
            userModel.phone = (e.data() as Map)['phone'];
            userModel.status = (e.data() as Map)['status'];
            return userModel;
          }).toString();


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
                                    backgroundImage: NetworkImage(userModel.image),
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
                          userModel.name,
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
                                          controller: _nameController..text = userModel.name,
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
                                          controller: _phoneController..text = userModel.phone,
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
                                          controller: _emailController..text = userModel.email,
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
                                                  primary: Colors.blueAccent),
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
                                                  labelText: "Password",
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
                                                _onChangePassword();
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
                                                  primary: Colors
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
                        )),

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
      LoadingDialog.showLoadingDialog(context, "loading...");
      changeInfo(
          _emailController.text, _nameController.text, _phoneController.text,
          () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyInfo()));
      });
    }
  }

  _onChangePassword() {
    var isvalid = isValidChangePass(
        _passController.text,
        _passNew1Controller.text,
        _passNew2Controller.text,
        _passwordController.text);

    if (isvalid) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      userR.updatePassword(_passNew2Controller.text);
      changePassword(_passNew2Controller.text, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyInfo()));
      });
    }
  }

  void changeInfo(
      String email, String name, String phone, Function onSuccess) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: userR.uid)
        .get();
    String id = snapshot.docs.first.id;
    var user = {"email": email, "name": name, "phone": phone};

    var ref = FirebaseFirestore.instance.collection('user');

    ref
        .doc(id)
        .update({'email': email, 'name': name, 'phone': phone}).then((value) {
      onSuccess();
    }).catchError((err) {
      //TODO
    });
  }

  void changePassword(String pass, Function onSuccess) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: userR.uid)
        .get();
    String id = snapshot.docs.first.id;
    var ref = FirebaseFirestore.instance.collection('user');

    ref.doc(id).update({'password': pass}).then((value) {
      onSuccess();
    }).catchError((err) {});
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
        Reference ref = storage.ref().child("avatar/" + image.name);
        UploadTask uploadTask = ref.putFile(file);
        await uploadTask.whenComplete(() async {
          var url = await ref.getDownloadURL();
          image_url = url.toString();
          updateAvatar(userR.uid, image_url, () {
            LoadingDialog.hideLoadingDialog(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MyInfo()));
          });
        }).catchError((onError) {});
      } else {}
    } else {}
  }

  updateAvatar(id, imageUrl, Function onSuccess) async {
    var ref = FirebaseFirestore.instance.collection('user');
    ref.doc(id).update({'image': imageUrl}).then((value) {
      onSuccess();
    }).catchError((err) {
      //TODO
    });
  }
}
