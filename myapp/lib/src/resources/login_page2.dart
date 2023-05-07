import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/resources/home_page.dart';
import '../blocs/auth_bloc.dart';
import 'dialog/loading_dialog.dart';
import 'dialog/msg_dialog.dart';
import 'employee/home_page_employee.dart';
import 'leader/home_page_leader.dart';
import 'manager/home_page_manager.dart';

class LoginPage2 extends StatefulWidget {
  const LoginPage2({super.key});

  @override
  State<LoginPage2> createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  AuthBloc authBloc = AuthBloc();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void dispose() {
    authBloc.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thoát ứng dụng'),
        content: const Text('Bạn có chắc chắn muốn thoát ứng dụng không?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: const Text('Thoát'),
          ),
        ],
      ),
    )) ?? false;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        onWillPop: _onWillPop,
    child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ClipRRect(
                child: Image.network("https://topsinhvien.vn/wp-content/uploads/2021/06/h-spkt-tphcm-2020-1.jpg",
                ),
              ),
              Container(
                height: 400,
              ),
            ],
          ),
    ),
    ),
    );
  }

  _onLoginClick() {
    var isValid = authBloc.isValidLogin(
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
