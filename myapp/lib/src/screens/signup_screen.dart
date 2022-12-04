// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:myapp/src/resources/home_page.dart';
//
// import '../../utils/color_utils.dart';
// import '../reusable_widgets/reusable_widget.dart';
//
// class SignUpScreen extends StatefulWidget{
//   const SignUpScreen({Key? key}) : super(key: key);
//
//
//
//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//
//
//
//
//   TextEditingController _passwordTextController = TextEditingController();
//   TextEditingController _emailTextController = TextEditingController();
//   TextEditingController _userNameTextController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           "Sign Up",
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           decoration: BoxDecoration(
//               gradient: LinearGradient(colors: [
//                 hexStringToColor("CB2B93"),
//                 hexStringToColor("9546C4"),
//                 hexStringToColor("5E61F4")
//               ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
//           child: SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
//                 child: Column(
//                   children: <Widget>[
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     reusableTextField("Enter UserName", Icons.person_outline, false,
//                         _userNameTextController),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     reusableTextField("Enter Email Id", Icons.person_outline, false,
//                         _emailTextController),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     reusableTextField("Enter Password", Icons.lock_outlined, true,
//                         _passwordTextController),
//                     const SizedBox(
//                       height: 20,
//                       // child: ElevatedButton(onPressed:  _onSignUpClick,
//                       //     style: ElevatedButton.styleFrom(
//                       //       primary: Color(0xff3277D8),
//                       //     ),
//                       //     child: Text(
//                       //       "Signup",
//                       //       style: TextStyle(color: Colors.white, fontSize: 18),
//                       //     )),
//                     ),
//                     firebaseUIButton(context, "Sign Up", () {
//                       FirebaseAuth.instance
//                           .createUserWithEmailAndPassword(
//                           email: _emailTextController.text,
//                           password: _passwordTextController.text)
//                           .then((value) {
//                         print("Created New Account");
//                         Navigator.push(context,
//                             MaterialPageRoute(builder: (context) => HomePage()));
//                       }).onError((error, stackTrace) {
//                         print("Error ${error.toString()}");
//                       });
//                     })
//                   ],
//                 ),
//               ))),
//     );
//   }
//
//   // _onSignUpClick(){
//   //
//   // }
//   //
//   // _createusers(String userId, String username, String email, String password){
//   //   var user = { "username": username, "email": email, "password": password};
//   //   var ref = FirebaseFirestore.instance.collection("users");
//   //   ref.child(userId).set
//   //
//   // }
//
//
//
// }