import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/resources/dialog/loading_dialog.dart';
import 'package:myapp/src/resources/dialog/msg_dialog.dart';
import 'package:myapp/src/resources/home_page.dart';
import 'package:passwordfield/passwordfield.dart';

import 'package:myapp/src/blocs/auth_bloc.dart';
import 'package:myapp/src/resources/login_page.dart';

import '../../utils/color_utils.dart';
import '../reusable_widgets/reusable_widget.dart';
class RegisterPage extends StatefulWidget{
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  AuthBloc authBloc = new AuthBloc();

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();

  @override
  void dispose() {
    authBloc.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.white,
       iconTheme: IconThemeData(color: Color(0xff3277D8)),
       elevation: 0,
     ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Colors.white,

        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[

              logoWidget("assets/ute_logo.png"),
              Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 6),
              child: Text(
                " UTE APP",
                style: TextStyle(fontSize: 30, color: Colors.blue),
              ),
              ),
              Text(
                "Đăng kí người dùng mới",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 60, 0, 20),
              child: StreamBuilder(
                stream: authBloc.nameStream,
                builder: (context, snapshot) => TextField(
                  controller: _nameController,
                  style: TextStyle(fontSize: 25, color: Colors.black),
                  decoration: InputDecoration(
                    errorText:
                      snapshot.hasError ? snapshot.error.toString(): null,
                      labelText: "Họ tên",
                      prefixIcon: Container(
                          width: 50, child: Icon(Icons.account_circle_rounded)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                )),
              ),
              StreamBuilder(
                stream: authBloc.phoneStream,
                  builder: (context, snapshot) => TextField(
                    controller: _phoneController,
                    style: TextStyle(fontSize: 25, color: Colors.black),
                    decoration: InputDecoration(
                        labelText: "Số điện thoại",
                        errorText:
                        snapshot.hasError ? snapshot.error.toString() : null,
                        prefixIcon: Container(
                            width: 50, child: Icon(Icons.add_call)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(6)))),
                  )),
              Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: StreamBuilder(
                stream: authBloc.emailStream,
                builder: (context, snapshot)=> TextField(
                  controller: _emailController,
                  style: TextStyle(fontSize: 25, color: Colors.black),
                  decoration: InputDecoration(
                      labelText: "Email",
                      errorText: snapshot.hasError ? snapshot.error.toString() :null,
                      prefixIcon: Container(
                          width: 50, child: Icon(Icons.add_card_rounded)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                )),
              ),
              StreamBuilder(
                stream: authBloc.passStream,
                  builder: (context, snapshot) => TextField(
                    obscureText: true,
                    obscuringCharacter: "*",
                    controller: _passController,
                    style: TextStyle(fontSize: 25, color: Colors.black),
                    decoration: InputDecoration(

                        labelText: "Mật khẩu",

                        errorText: snapshot.hasError ? snapshot.error.toString() :null,
                        prefixIcon: Container(
                            width: 50, child: Icon(Icons.lock_outline)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(6)))),
                  )),

              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 40),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onSignUpClicked,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlueAccent,
                  ),
                  child: Text(
                    "Đăng kí",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: RichText(
                text: TextSpan(
                  text: "Đã có tài khoản ?",
                  style: TextStyle(color: Color(0xff606470), fontSize: 18 ),
                children: <TextSpan>[
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LoginPage()));
                        },
                    text: " Đăng nhập ngay",
                    style: TextStyle(color: Color(0xff3277D8), fontSize: 18))
                ]),
              ),)
            ],
          ),

        ),
      ),
    );
  }

  _onSignUpClicked(){

    var isValid = authBloc.isValid(_nameController.text,
        _emailController.text, _passController.text, _phoneController.text);
    if (isValid){

      LoadingDialog.showLoadingDialog(context, "loading...");
      authBloc.signUp(_emailController.text, _passController.text, _phoneController.text,
          _nameController.text, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => HomePage()));
      },(msg){
        LoadingDialog.hideLoadingDialog(context);
        MsgDialog.showMsgDialog(context, "Sign-In", msg);

          });

    }
  }
}