import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../utils/color_utils.dart';
import '../../blocs/auth_bloc.dart';
import '../../reusable_widgets/reusable_widget.dart';
import '../dialog/loading_dialog.dart';
import '../dialog/msg_dialog.dart';
import 'home_page_admin.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

FirebaseAuth auth = FirebaseAuth.instance;

class _LoginAdminState extends State<LoginAdmin> {
  AuthBloc authBloc = AuthBloc();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void dispose() {
    authBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: SafeArea(
            child: Container(
                //padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                constraints: const BoxConstraints.expand(),
                // color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  hexStringToColor("CB2B93"),
                  hexStringToColor("9546C4"),
                  hexStringToColor("5E61F4")
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 50),
                  child: Column(children: <Widget>[
                    logoWidget("assets/ute_logo.png"),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: StreamBuilder(
                        stream: authBloc.emailStream,
                        builder: (context, snapshot) => TextField(
                          controller: _emailController,
                          style: const TextStyle(
                              fontSize: 25, color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Email",
                            errorText: snapshot.hasError
                                ? snapshot.error.toString()
                                : null,
                            prefixIcon: const SizedBox(
                                width: 50, child: Icon(Icons.person_outline)),
                            border: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    StreamBuilder(
                        stream: authBloc.passStream,
                        builder: (context, snapshot) => TextField(
                              obscureText: true,
                              obscuringCharacter: "*",
                              controller: _passController,
                              style:
                                  const TextStyle(fontSize: 25, color: Colors.white),
                              decoration: InputDecoration(
                                  labelText: "Mật khẩu",
                                  errorText: snapshot.hasError
                                      ? snapshot.error.toString()
                                      : null,
                                  prefixIcon: const SizedBox(
                                      width: 50,
                                      child: Icon(Icons.lock_outline)),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(6)))),
                            )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _onLoginClick,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlueAccent,
                          ),
                          child: const Text(
                            "Đăng nhập",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ]),
                )))));
  }

  _onLoginClick() {
    var isValid =
        authBloc.isValidLogin(_emailController.text, _passController.text);
    if (isValid) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      authBloc.signIn(_emailController.text, _passController.text, () async {
        var userR = FirebaseAuth.instance.currentUser!;
        var snapshot = await FirebaseFirestore.instance
            .collection('admin')
            .where('id', isEqualTo: userR.uid)
            .get();
        if (snapshot.docs.isNotEmpty) {
          LoadingDialog.hideLoadingDialog(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePageAdmin()));
        } else{}
      }, (msg) {
        LoadingDialog.hideLoadingDialog(context);
        MsgDialog.showMsgDialog(context, "Sign-In", msg);
      });
    }
  }
}
