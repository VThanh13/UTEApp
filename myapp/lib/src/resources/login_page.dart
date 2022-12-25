import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/resources/register_page.dart';
import 'package:myapp/src/resources/home_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import '../../utils/color_utils.dart';
import '../app.dart';
import '../blocs/auth_bloc.dart';
import '../reusable_widgets/reusable_widget.dart';
import 'dialog/loading_dialog.dart';
import 'dialog/msg_dialog.dart';
import 'employee/home_page_employee.dart';
import 'home_page.dart';
import 'leader/home_page_leader.dart';
import 'manager/home_page_manager.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthBloc authBloc = new AuthBloc();

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();

  @override
  void dispose() {
    authBloc.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Thoát ứng dụng'),
        content: new Text('Bạn có chắc chắn muốn thoát ứng dụng không?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('Hủy'),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: new Text('Thoát'),
          ),
        ],
      ),
    )) ?? false;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new WillPopScope(
        onWillPop: _onWillPop,
    child: Scaffold(
        body: SafeArea(
            child: Container(
                //padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                constraints: BoxConstraints.expand(),
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
                  padding: EdgeInsets.fromLTRB(
                      20, 10, 20, 50),
                  child: Column(children: <Widget>[
                    Container(
                      child: logoWidget("assets/ute_logo.png"),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: StreamBuilder(
                          stream: authBloc.emailStream,
                          builder: (context, snapshot) => TextField(
                                controller: _emailController,
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                                decoration: InputDecoration(
                                    labelText: "Email",
                                    errorText: snapshot.hasError
                                        ? snapshot.error.toString()
                                        : null,
                                    prefixIcon: Container(
                                        width: 50,
                                        child: Icon(Icons.person_outline)),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(6)))),
                              )),
                    ),
                    StreamBuilder(
                        stream: authBloc.passStream,
                        builder: (context, snapshot) => TextField(
                          obscureText: true,
                          obscuringCharacter: "*",
                              controller: _passController,
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white),
                              decoration: InputDecoration(
                                  labelText: "Mật khẩu",
                                  errorText: snapshot.hasError
                                      ? snapshot.error.toString()
                                      : null,
                                  prefixIcon: Container(
                                      width: 50,
                                      child: Icon(Icons.lock_outline)),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(6)))),
                            )),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _onLoginClick,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlueAccent,
                          ),
                          child: Text(
                            "Đăng nhập",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                      child: RichText(
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RegisterPage()));
                                },
                              text: "Đăng kí tài khoản mới",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20))
                        ]),
                      ),


                    )
                  ]),
                )))))
    );
  }

  _onLoginClick() {
    var isValid = authBloc.isValid_Login(
        _emailController.text, _passController.text);
    if (isValid) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      authBloc.signIn(_emailController.text, _passController.text,
              () async {
                var userr = FirebaseAuth.instance.currentUser!;
                var snapshot = await FirebaseFirestore.instance
                    .collection('user')
                    .where('userId', isEqualTo: userr.uid)
                    .where('status', isEqualTo: "enabled")
                    .get();
                if(snapshot.docs!= null && snapshot.docs.isNotEmpty){
                  LoadingDialog.hideLoadingDialog(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                }
                snapshot = await FirebaseFirestore.instance
                    .collection('employee')
                    .where('id', isEqualTo: userr.uid)
                    .where('status', isEqualTo: "enabled")
                    .get();
                if(snapshot.docs!= null && snapshot.docs.isNotEmpty){
                  if(snapshot.docs.first['roles'] == "Tư vấn viên") {
                    LoadingDialog.hideLoadingDialog(context);
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => HomePageEmployee()));
                  }
                  else if(snapshot.docs.first['roles'] == "Trưởng nhóm") {
                    LoadingDialog.hideLoadingDialog(context);
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => HomePageLeader()));
                  }
                  else if(snapshot.docs.first['roles'] == "Manager") {
                    LoadingDialog.hideLoadingDialog(context);
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => HomePageManager()));
                  }
                }
          }, (msg) {
            LoadingDialog.hideLoadingDialog(context);
            MsgDialog.showMsgDialog(context, "Sign-In", msg);
          });
    }
  }
}
