import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/blocs/auth_bloc.dart';
import 'package:myapp/src/resources/login_page.dart';
import '../reusable_widgets/reusable_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  AuthBloc authBloc = AuthBloc();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
        iconTheme: const IconThemeData(color: Color(0xff3277D8)),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        constraints: const BoxConstraints.expand(),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              logoWidget("assets/ute_logo.png"),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 6),
                child: Text(
                  " UTE APP",
                  style: TextStyle(fontSize: 30, color: Colors.blue),
                ),
              ),
              const Text(
                "Đăng kí người dùng mới",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 60, 0, 20),
                child: StreamBuilder(
                    stream: authBloc.nameStream,
                    builder: (context, snapshot) => TextField(
                          controller: _nameController,
                          style: const TextStyle(fontSize: 25, color: Colors.black),
                          decoration: InputDecoration(
                              errorText: snapshot.hasError
                                  ? snapshot.error.toString()
                                  : null,
                              labelText: "Họ tên",
                              prefixIcon: const SizedBox(
                                  width: 50,
                                  child: Icon(Icons.account_circle_rounded)),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xffCED0D2), width: 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)))),
                        )),
              ),
              StreamBuilder(
                  stream: authBloc.phoneStream,
                  builder: (context, snapshot) => TextField(
                        controller: _phoneController,
                        style: const TextStyle(fontSize: 25, color: Colors.black),
                        decoration: InputDecoration(
                            labelText: "Số điện thoại",
                            errorText: snapshot.hasError
                                ? snapshot.error.toString()
                                : null,
                            prefixIcon: const SizedBox(
                                width: 50, child: Icon(Icons.add_call),
                            ),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xffCED0D2), width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6),
                                    ),
                            ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: StreamBuilder(
                    stream: authBloc.emailStream,
                    builder: (context, snapshot) => TextField(
                          controller: _emailController,
                          style: const TextStyle(fontSize: 25, color: Colors.black),
                          decoration: InputDecoration(
                              labelText: "Email",
                              errorText: snapshot.hasError
                                  ? snapshot.error.toString()
                                  : null,
                              prefixIcon: const SizedBox(
                                  width: 50,
                                  child: Icon(Icons.add_card_rounded)),
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xffCED0D2), width: 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)))),
                        )),
              ),
              StreamBuilder(
                  stream: authBloc.passStream,
                  builder: (context, snapshot) => TextField(
                        obscureText: true,
                        obscuringCharacter: "*",
                        controller: _passController,
                        style: const TextStyle(fontSize: 25, color: Colors.black),
                        decoration: InputDecoration(
                            labelText: "Mật khẩu",
                            errorText: snapshot.hasError
                                ? snapshot.error.toString()
                                : null,
                            prefixIcon: const SizedBox(
                                width: 50, child: Icon(Icons.lock_outline)),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xffCED0D2), width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)))),
                      )),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onSignUpClicked,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlueAccent,
                    ),
                    child: const Text(
                      "Đăng kí",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: RichText(
                  text: TextSpan(
                      text: "Đã có tài khoản ?",
                      style: const TextStyle(color: Color(0xff606470), fontSize: 18),
                      children: <TextSpan>[
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()));
                              },
                            text: " Đăng nhập ngay",
                            style: const TextStyle(
                                color: Color(0xff3277D8), fontSize: 18))
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _onSignUpClicked() {
    // var isValid = authBloc.isValid(_nameController.text,
    //     _emailController.text, _passController.text, _phoneController.text);
    // if (isValid){
    //
    //   LoadingDialog.showLoadingDialog(context, "loading...");
    //   authBloc.signUp(_emailController.text, _passController.text, _phoneController.text,
    //       _nameController.text, () {
    //     LoadingDialog.hideLoadingDialog(context);
    //     Navigator.push(context,
    //       MaterialPageRoute(builder: (context) => HomePage()));
    //   },(msg){
    //     LoadingDialog.hideLoadingDialog(context);
    //     MsgDialog.showMsgDialog(context, "Sign-In", msg);
    //
    //       });
    //
    // }
  }
}
