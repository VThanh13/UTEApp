import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/src/resources/employee/home_page_employee.dart';
import 'package:myapp/src/resources/home_page.dart';
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
    User? user = FirebaseAuth.instance.currentUser;
    var currentUser = FirebaseAuth.instance.currentUser!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? group = prefs.getString("group");
    // String? roleEmp = prefs.getString("ttv") ;
    // String? roleTL = prefs.getString("tn") ;
    // String? roleMN = prefs.getString("mng") ;
    String? id = prefs.getString("id");
    String check ='';
    String check2 ='';
    // await FirebaseFirestore.instance
    //     .collection('user')
    //     .where('userId', isEqualTo: currentUser.uid)
    //     .get().then((value) =>{
    //   check = value.docs.first['group']
    // });

    FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: id)
        .get().then((value) =>{
      setState((){
        check2 = value.docs.first['roles'];
      })
    });
    // print(check2);
    // print(roleMN);
    // print(roleTL);
    // print(roleEmp);

    if(user != null){
      // if(check2 == "Trưởng nhóm"){
      //     setState(() {
      //       currentPage = const HomePageLeader();
      //     });
      //   }
      print('day la id $id');
      print("day la check2 $check2");
      setState(() {
        currentPage = const HomePageLeader();
      });
      // if(check2 == "Tư vấn viên"){
      //   setState(() {
      //     currentPage = const HomePageEmployee();
      //   });
      // }else if(check2 == "Trưởng nhóm"){
      //   setState(() {
      //     currentPage = const HomePageLeader();
      //   });
      // } else if(check2 == "Manager" ){
      //   setState(() {
      //     currentPage = const HomePageManager();
      //   });
      // }else{
      //   currentPage = const HomePage();
      // }
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

}

