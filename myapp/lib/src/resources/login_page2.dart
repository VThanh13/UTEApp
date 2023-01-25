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

class LoginPage2 extends StatefulWidget {
  @override
  _LoginPage2State createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
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
          child: Column(
            children: [
              Container(
                child: ClipRRect(
                  child: Image.network("https://topsinhvien.vn/wp-content/uploads/2021/06/h-spkt-tphcm-2020-1.jpg",
                  ),
                ),
              ),
              Container(
                height: 400,
              ),
            ],
          ),
    ))
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
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(userr.uid)
                    .get()
                    .then((snapshot){
                  if(snapshot.exists){
                    LoadingDialog.hideLoadingDialog(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  }
                });
                await FirebaseFirestore.instance
                    .collection('employee')
                    .doc(userr.uid)
                    .get()
                    .then((snapshot){
                  if(snapshot.exists){
                    if(snapshot.get('roles') == "Tư vấn viên") {
                      LoadingDialog.hideLoadingDialog(context);
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => HomePageEmployee()));
                    }
                    else if(snapshot.get('roles') == "Trưởng nhóm") {
                      LoadingDialog.hideLoadingDialog(context);
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => HomePageLeader()));
                    }
                    else if(snapshot.get('roles') == "Manager") {
                      LoadingDialog.hideLoadingDialog(context);
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => HomePageManager()));
                    }
                  }
                });

          }, (msg) {
            LoadingDialog.hideLoadingDialog(context);
            MsgDialog.showMsgDialog(context, "Sign-In", msg);
          });
    }
  }
}
