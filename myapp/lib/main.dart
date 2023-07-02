import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/src/resources/employee/home_page_employee.dart';
import 'package:myapp/src/resources/user/home_page.dart';
import 'package:myapp/src/resources/leader/home_page_leader.dart';
import 'package:myapp/src/resources/login_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/resources/manager/home_page_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main()  async{
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  // runApp(MyApp(
  //   AuthBloc(),
  //   const MaterialApp(
  //     // home: LoginPage(),
  //       home: LoginScreen(),
  //       debugShowCheckedModeBanner: false,
  //       //home: LoginAdmin(),
  //
  //   )
  // ));
  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp>{
  Widget currentPage = const LoginScreen();

  checkLogin() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("id");

    if(id != null  && id != ""){
      var currentUser = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.uid)
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          setState(() {
            currentPage = const HomePage();
          });
        }
      });

      await FirebaseFirestore.instance
          .collection('employee')
          .doc(currentUser.uid)
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {

          if (snapshot.get('roles') == "Tư vấn viên") {
            setState(() {
              currentPage = const HomePageEmployee();
            });
          } else if (snapshot.get('roles') == "Trưởng nhóm") {
            setState(() {
              currentPage = const HomePageLeader();
            });
          } else if (snapshot.get('roles') == "Manager") {
            setState(() {
              currentPage = const HomePageManager();
            });
          }
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: currentPage,
      debugShowCheckedModeBanner: false,
    );
  }
  // adb kill-server
  // adb start-server

}

