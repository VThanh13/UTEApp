import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/resources/register_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

import '../app.dart';
import 'dialog/loading_dialog.dart';
import 'dialog/msg_dialog.dart';
import 'home_page.dart';


class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Colors.white,

        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 140,
              ),
              Image.asset('logo_page.png'),
              Padding(padding: EdgeInsets.fromLTRB(0, 40, 0, 6),
              child: Text(
                "Welcome back!",
                style: TextStyle(fontSize: 22, color: Color(0xff333333)),
              ),
              ),
              Text("Login to continue using UTE App",
              style: TextStyle(fontSize: 16, color: Color(0xff606470)),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 145, 0, 20),
              child: TextField(
                style: TextStyle(fontSize: 18, color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Container(
                    width: 50,
                      child: Image.asset("ic_email.png")),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(6)))),
              ),
              ),
              TextField(
                style: TextStyle(fontSize: 18, color: Colors.black),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Container(
                    width: 50, child: Image.asset("ic_lock.png")),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffCED0D2), width: 1 ),
                    borderRadius: BorderRadius.all(Radius.circular(6)))),
              ),
              Container(
                constraints: BoxConstraints.loose(Size(double.infinity, 30)),
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(fontSize: 16, color: Color(0xff606470)),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 40),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onLoginClick,
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xff3277D8),

                  ),

                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),

                   ),
              ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: RichText(
                text: TextSpan(
                  text: "New user?",
                  style: TextStyle(color: Color(0xff606470), fontSize: 16),
                  children: <TextSpan> [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                          ..onTap = (){
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context) => RegisterPage()));
                          },
                      text: "Sign up for a new account",
                      style: TextStyle(
                        color: Color(0xff3277D8), fontSize: 16))
                  ]),

                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  void _onLoginClick() {
    String email = _emailController.text;
    String pass = _passController.text;
    var authBloc = MyApp.of(context)?.authBloc;
    LoadingDialog.showLoadingDialog(context, "Loading...");
    authBloc?.signIn(email, pass, () {
      LoadingDialog.hideLoadingDialog(context);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomePage()));
    }, (msg) {
      LoadingDialog.hideLoadingDialog(context);
      MsgDialog.showMsgDialog(context, "Sign-In", msg);
    });
  }
}