import 'package:flutter/material.dart';
import 'package:myapp/src/resources/dialog/loading_dialog.dart';
import 'package:myapp/src/resources/dialog/msg_dialog.dart';
import 'package:myapp/src/resources/home_page.dart';

import 'package:myapp/src/blocs/auth_bloc.dart';
import 'package:myapp/src/resources/login_page.dart';
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
              SizedBox(
                height: 80,
              ),
              Image.asset("logo_page.png"),
              Padding(padding: EdgeInsets.fromLTRB(0, 40, 0, 6),
              child: Text(
                "Welcome to UTE!",
                style: TextStyle(fontSize: 22, color: Color(0xff333333)),
              ),
              ),
              Text(
                "Signup with UTE in simple steps",
                style: TextStyle(fontSize: 16, color: Color(0xff606470)),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 80, 0, 20),
              child: StreamBuilder(
                stream: authBloc.nameStream,
                builder: (context, snapshot) => TextField(
                  controller: _nameController,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                    errorText:
                      snapshot.hasError ? snapshot.error.toString(): null,
                      labelText: "Name",
                      prefixIcon: Container(
                          width: 50, child: Image.asset("ic_user.png")),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                )),
              ),
              StreamBuilder(
                stream: authBloc.phoneStream,
                  builder: (context, snapshot) => TextField(
                    controller: _phoneController,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                        labelText: "Phone Number",
                        errorText:
                        snapshot.hasError ? snapshot.error.toString() : null,
                        prefixIcon: Container(
                            width: 50, child: Image.asset("ic_phone.png")),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(6)))),
                  )),
              Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: StreamBuilder(
                stream: authBloc.emailStream,
                builder: (context, snapshot)=> TextField(
                  controller: _emailController,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                      labelText: "Email",
                      errorText: snapshot.hasError ? snapshot.error.toString() :null,
                      prefixIcon: Container(
                          width: 50, child: Image.asset("ic_email.png")),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                )),
              ),
              StreamBuilder(
                stream: authBloc.passStream,
                  builder: (context, snapshot) => TextField(
                    controller: _passController,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                        labelText: "Password",
                        errorText: snapshot.hasError ? snapshot.error.toString() :null,
                        prefixIcon: Container(
                            width: 50, child: Image.asset("ic_lock.png")),
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
                    primary: Color(0xff3277D8),
                  ),
                  child: Text(
                    "Signup",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: RichText(
                text: TextSpan(
                  text: "Already a User",
                  style: TextStyle(color: Color(0xff606470), fontSize: 16 ),
                children: <TextSpan>[
                  TextSpan(
                    text: "Login now",
                    style: TextStyle(color: Color(0xff3277D8), fontSize: 16))
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