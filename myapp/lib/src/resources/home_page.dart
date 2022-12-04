import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/resources/about_page/my_file.dart';
import 'package:myapp/src/resources/about_page/my_info.dart';
import 'package:myapp/src/resources/about_page/about_university.dart';
import 'package:myapp/src/resources/about_page/admission_history.dart';
import 'package:myapp/src/resources/login_page.dart';
import 'package:myapp/src/resources/messenger/messenger_page.dart';
import 'package:myapp/src/resources/messenger/test.dart';
import 'package:myapp/src/screens/signin_screen.dart';
class HomePage extends StatefulWidget{
  // final String emai = "";
//
//   const HomePage({
//     Key? key,
//     required this.emaill,
//
// }): super(key: key);





  @override
  _HomePageState createState() => _HomePageState();


}

class _HomePageState extends State<HomePage>{
  FirebaseAuth auth = FirebaseAuth.instance;
  final userr = FirebaseAuth.instance.currentUser!;
  String name="";

  Future<String> getUsernameFromUID() async{
    final snapshot = await FirebaseFirestore.instance.collection('user').where("userId", isEqualTo: userr.uid).get();
    name = snapshot.docs.first['name'];


    return name;

  }












  // Check if the user is signed in
  getCurrentUser() async{
    final FirebaseAuth _auth =FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    final user = await _auth.currentUser;

    User ref = _firestore.collection("user").where("userId",isEqualTo: userr.uid) as User;

    print(ref);
    return ref;

  }



  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<QuerySnapshot>(
    //   future: FirebaseFirestore.instance.collection("user").where("email", isEqualTo: userr.email).get(),
    //   builder: (context, snapshot){
    //     if(!snapshot.hasData){
    //
    //     }
    //   },
    //
    //
    //
    // );
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        title: new Text("UTE APP"),

        actions: <Widget>[
          IconButton(

              onPressed: (){
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => MessengerPage()));
              },
              icon: Icon(AppIcons.chat,

              color: Colors.white,)
          ),
          IconButton(
              onPressed: (){
                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => TestPage()));
              },
              icon: Icon(AppIcons.bell_alt,
              color: Colors.white,))

        ],
      ),
      drawer: new Drawer(
        child: ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader (

                accountName: new Text(name),
                accountEmail: new Text(userr.email!),
                currentAccountPicture: new CircleAvatar(
                  backgroundImage: new NetworkImage('http://i.pravatar.cc/300'),
                ),
            ),
            new ListTile(
              title: new Text('Thông tin cá nhân'),
              onTap: (){
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new MyInfo())
                );
              },
            ),
            new Divider(
              color: Colors.black,
              height: 5.0,
            ),
            new ListTile(
              title: new Text('Giới thiệu về trường'),
              onTap: (){
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new AboutUniversity())
                );
              },
            ),
            new Divider(
              color: Colors.black,
              height: 5.0,
            ),
            new ListTile(
              title: new Text('Lịch sử tuyển sinh'),
              onTap: (){
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new AdmissionHistory())
                );
              },
            ),
            new Divider(
              color: Colors.black,
              height: 5.0,
            ),
            new ListTile(
              title: new Text('Hồ sơ của bạn'),
              onTap: (){
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new MyFile())
                );
              },
            ),
            new Divider(
              color: Colors.black,
              height: 5.0,
            ),
            new ListTile(
              title: new Text('Đăng xuất'),
              onTap: (){
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new LoginPage())
                );
              },
            ),


          ],
        ),
      ),
    );
  }
}