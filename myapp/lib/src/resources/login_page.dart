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
import 'home_page.dart';

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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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
                    logoWidget("assets/ute_logo.png"),
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

                      // child: SingleChildScrollView(
                      //   child: Column(
                      //     children: <Widget>[
                      //       SizedBox(
                      //         height: 140,
                      //       ),
                      //       Image.asset('logo_page.png'),
                      //       Padding(padding: EdgeInsets.fromLTRB(0, 40, 0, 6),
                      //       child: Text(
                      //         "Welcome back!",
                      //         style: TextStyle(fontSize: 22, color: Color(0xff333333)),
                      //       ),
                      //       ),
                      //       Text("Login to continue using UTE App",
                      //       style: TextStyle(fontSize: 16, color: Color(0xff606470)),
                      //       ),
                      //       Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      //         child: StreamBuilder(
                      //             stream: authBloc.emailStream,
                      //             builder: (context, snapshot)=> TextField(
                      //               controller: _emailController,
                      //               style: TextStyle(fontSize: 18, color: Colors.black),
                      //               decoration: InputDecoration(
                      //                   labelText: "Email",
                      //                   errorText: snapshot.hasError ? snapshot.error.toString() :null,
                      //                   prefixIcon: Container(
                      //                       width: 50, child: Image.asset("ic_email.png")),
                      //                   border: OutlineInputBorder(
                      //                       borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                      //                       borderRadius: BorderRadius.all(Radius.circular(6)))),
                      //             )),
                      //       ),
                      //       StreamBuilder(
                      //           stream: authBloc.passStream,
                      //           builder: (context, snapshot) => TextField(
                      //             controller: _passController,
                      //             style: TextStyle(fontSize: 18, color: Colors.black),
                      //             decoration: InputDecoration(
                      //                 labelText: "Password",
                      //                 errorText: snapshot.hasError ? snapshot.error.toString() :null,
                      //                 prefixIcon: Container(
                      //                     width: 50, child: Image.asset("ic_lock.png")),
                      //                 border: OutlineInputBorder(
                      //                     borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                      //                     borderRadius: BorderRadius.all(Radius.circular(6)))),
                      //           )),
                      //       // Padding(padding: EdgeInsets.fromLTRB(0, 145, 0, 20),
                      //       // child: TextField(
                      //       //   style: TextStyle(fontSize: 18, color: Colors.black),
                      //       //   decoration: InputDecoration(
                      //       //     labelText: "Email",
                      //       //     prefixIcon: Container(
                      //       //       width: 50,
                      //       //         child: Image.asset("ic_email.png")),
                      //       //     border: OutlineInputBorder(
                      //       //       borderSide: BorderSide(color: Color(0xffCED0D2), width: 1),
                      //       //       borderRadius: BorderRadius.all(Radius.circular(6)))),
                      //       // ),
                      //       // ),
                      //       // TextField(
                      //       //   style: TextStyle(fontSize: 18, color: Colors.black),
                      //       //   obscureText: true,
                      //       //   decoration: InputDecoration(
                      //       //     labelText: "Password",
                      //       //     prefixIcon: Container(
                      //       //       width: 50, child: Image.asset("ic_lock.png")),
                      //       //     border: OutlineInputBorder(
                      //       //       borderSide: BorderSide(color: Color(0xffCED0D2), width: 1 ),
                      //       //       borderRadius: BorderRadius.all(Radius.circular(6)))),
                      //       // ),
                      //       Container(
                      //         constraints: BoxConstraints.loose(Size(double.infinity, 30)),
                      //         alignment: AlignmentDirectional.centerEnd,
                      //         child: Padding(
                      //           padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      //           child: Text(
                      //             "Forgot password?",
                      //             style: TextStyle(fontSize: 16, color: Color(0xff606470)),
                      //           ),
                      //         ),
                      //       ),
                      //       Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 40),
                      //       child: SizedBox(
                      //         width: double.infinity,
                      //         height: 52,
                      //         child: ElevatedButton(
                      //           onPressed: _onLoginClick,
                      //           style: ElevatedButton.styleFrom(
                      //             primary: Color(0xff3277D8),
                      //
                      //           ),
                      //
                      //           child: Text(
                      //             "Login",
                      //             style: TextStyle(color: Colors.white, fontSize: 18),
                      //           ),
                      //
                      //            ),
                      //       ),
                      //       ),
                      //       Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                      //       child: RichText(
                      //         text: TextSpan(
                      //           text: "New user?",
                      //           style: TextStyle(color: Color(0xff606470), fontSize: 16),
                      //           children: <TextSpan> [
                      //             TextSpan(
                      //               recognizer: TapGestureRecognizer()
                      //                   ..onTap = (){
                      //                 Navigator.push(context,
                      //                 MaterialPageRoute(builder: (context) => RegisterPage()));
                      //                   },
                      //               text: "Sign up for a new account",
                      //               style: TextStyle(
                      //                 color: Color(0xff3277D8), fontSize: 16))
                      //           ]),
                      //
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                    )
                  ]),
                )))));
  }

  _onLoginClick() {
    // String email = _emailController.text;
    // String pass = _passController.text;
    // var authBloc = MyApp.of(context)?.authBloc;
    // LoadingDialog.showLoadingDialog(context, "Loading...");
    // authBloc?.signIn(email, pass, () {
    //   LoadingDialog.hideLoadingDialog(context);
    //   Navigator.push(context,
    //       MaterialPageRoute(builder: (context) => HomePage()));
    // }, (msg) {
    //   LoadingDialog.hideLoadingDialog(context);
    //   MsgDialog.showMsgDialog(context, "Sign-In", msg);
    // });


    var isValidd = authBloc.isValidd(
        _emailController.text, _passController.text);
    if (isValidd) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      authBloc.signIn(_emailController.text, _passController.text,
              () {
            LoadingDialog.hideLoadingDialog(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomePage()));
          }, (msg) {
            LoadingDialog.hideLoadingDialog(context);
            MsgDialog.showMsgDialog(context, "Sign-In", msg);
          });
    }
  }
}
