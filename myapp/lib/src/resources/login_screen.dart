import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/resources/forgot_password.dart';
import '../blocs/auth_bloc.dart';
import 'dialog/loading_dialog.dart';
import 'dialog/msg_dialog.dart';
import 'employee/home_page_employee.dart';
import 'user/home_page.dart';
import 'leader/home_page_leader.dart';
import 'manager/home_page_manager.dart';
import 'signup_screen.dart';
import 'package:myapp/src/widgets/inputTextWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<LoginScreen> {
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  AuthBloc authBloc = AuthBloc();

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit the app'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: const Text('Exit'),
          ),
        ],
      ),
    )) ?? false;
  }

  //final snackBar = SnackBar(content: Text('email ou mot de passe incorrect'));
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double r = (175 / 360); //  rapport for web test(304 / 540);
    final coverHeight = screenWidth * r;
    bool pinned = false;
    bool snap = false;
    bool floating = false;

    final widgetList = [
      const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to UTE App',
            style: TextStyle(
              fontFamily: 'Segoe UI',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xff000000),
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
      const SizedBox(
        height: 12.0,
      ),
      Form(
          key: _formKey,
          child: Column(
            children: [
              InputTextWidget(
                  controller: _emailController,
                  labelText: "Email",
                  icon: Icons.email,
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(
                height: 12.0,
              ),
              InputTextWidget(
                  controller: _pwdController,
                  labelText: "Password",
                  icon: Icons.lock,
                  obscureText: true,
                  keyboardType: TextInputType.text),
              Padding(
                padding: const EdgeInsets.only(right: 25.0, top: 10.0),
                child: Align(
                    alignment: Alignment.topRight,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordForm()));
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700]),
                        ),
                      ),
                    )),
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                height: 55.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _onLoginClick();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0.0,
                    minimumSize: Size(screenWidth, 150),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                        color: Colors.blue, // Color(0xffF05945),
                        borderRadius: BorderRadius.circular(12.0)),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "Sign In",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
      const SizedBox(
        height: 15.0,
      ),
      Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 10.0, top: 5.0),
            child: Container(
              decoration: BoxDecoration(
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey, //Color(0xfff05945),
                        offset: Offset(0, 0),
                        blurRadius: 3.0),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0)),
              width: (screenWidth / 2) - 40,
              height: 50,
              child: Material(
                borderRadius: BorderRadius.circular(12.0),
                child: InkWell(
                  onTap: () {
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.asset("assets/images/fb.png", fit: BoxFit.cover),
                        const SizedBox(
                          width: 7.0,
                        ),
                        const Text("Sign in with\nFacebook",
                        style: TextStyle(
                          fontSize: 12
                        ),)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 30.0, top: 5.0),
            child: Container(
              decoration: BoxDecoration(
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey, //Color(0xfff05945),
                        offset: Offset(0, 0),
                        blurRadius: 3.0),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0)),
              width: (screenWidth / 2) - 40,
              height: 50,
              child: Material(
                borderRadius: BorderRadius.circular(12.0),
                child: InkWell(
                  onTap: () {
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.asset("assets/images/google.png",
                            fit: BoxFit.cover),
                        const SizedBox(
                          width: 7.0,
                        ),
                        const Text("Sign in with\nGoogle",
                        style: TextStyle(
                          fontSize: 12
                        ),),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 15.0,
      ),
    ];
    return WillPopScope(
      onWillPop: _onWillPop,
    child: GestureDetector(
      onTap: () {WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();},

      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          // leading: Icon(Icons.arrow_back),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: pinned,
              snap: snap,
              floating: floating,
              expandedHeight: coverHeight - 25, //304,
              backgroundColor: const Color(0xFFdccdb4),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background:
                Image.asset("assets/images/cover.jpg", fit: BoxFit.cover),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(),
                    gradient: LinearGradient(
                        colors: <Color>[Color(0xFFdccdb4), Color(0xFFd8c3ab)])),
                width: screenWidth,
                height: 25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: screenWidth,
                      height: 25,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverList(
                delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
                  return widgetList[index];
                }, childCount: widgetList.length))
          ],
        ),
        bottomNavigationBar: Stack(
          children: [
            Container(
              height: 45.0,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?  ",
                    style: TextStyle(
                        color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                  Material(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()));
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    ),);
  }


  _onLoginClick() async {
    var isValid =
        authBloc.isValidLogin(_emailController.text, _pwdController.text);
    if (!isValid){
      MsgDialog.showMsgDialog(context, "Sign in failed", "Invalid Email or Password");
    }
    else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      LoadingDialog.showLoadingDialog(context, "Please Wait...");
      authBloc.signIn(_emailController.text, _pwdController.text, () async {
        var user_auth = FirebaseAuth.instance.currentUser!;
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user_auth.uid)
            .get()
            .then((snapshot) async {
          if (snapshot.exists) {
            await prefs.setString("id", user_auth.uid);
            await prefs.setString("roles", 'user');
            if (!mounted) return;
            LoadingDialog.hideLoadingDialog(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const HomePage()));
          }
        });
        await FirebaseFirestore.instance
            .collection('employee')
            .doc(user_auth.uid)
            .get()
            .then((snapshot) async {
          if (snapshot.exists) {
            await prefs.setString("id", user_auth.uid);
            await prefs.setString("roles", snapshot.get('roles'));

            if (snapshot.get('roles') == "Tư vấn viên") {
              if (!mounted) return;
              LoadingDialog.hideLoadingDialog(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomePageEmployee()));
            } else if (snapshot.get('roles') == "Trưởng nhóm") {
              if (!mounted) return;
              LoadingDialog.hideLoadingDialog(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomePageLeader()));
            } else if (snapshot.get('roles') == "Manager") {
              if (!mounted) return;
              LoadingDialog.hideLoadingDialog(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomePageManager()));
            }
          }
        });
      }, (msg) {
        LoadingDialog.hideLoadingDialog(context);
        MsgDialog.showMsgDialog(context, "Sign In failed", msg);
      });
    }
  }
}
