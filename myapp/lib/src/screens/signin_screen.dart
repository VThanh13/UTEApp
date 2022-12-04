// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:myapp/src/resources/home_page.dart';
// import 'package:myapp/src/screens/reset_password.dart';
// import 'package:myapp/src/screens/signup_screen.dart';
//
// import '../../utils/color_utils.dart';
// import '../reusable_widgets/reusable_widget.dart';
//
// class SignInScreen extends StatefulWidget{
//   const SignInScreen({Key? key}) : super(key: key);
//
//   @override
//   _SignInScreenState createState() => _SignInScreenState();
// }
//
// class _SignInScreenState extends State<SignInScreen> {
//   TextEditingController _passwordTextController = TextEditingController();
//   TextEditingController _emailTextController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(colors: [
//             hexStringToColor("CB2B93"),
//             hexStringToColor("9546C4"),
//             hexStringToColor("5E61F4")
//           ],begin: Alignment.topCenter, end: Alignment.bottomCenter
//           )
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.2, 20, 50),
//             child: Column(
//               children: <Widget>[
//                 logoWidget("assets/ute_logo.png"),
//                 SizedBox(
//                   child: Padding(
//                     padding: EdgeInsets.fromLTRB(0, 30, 0, 100),
//                   ),
//                   height: 30,),
//                 reusableTextField("Nhập username của bạn", Icons.person_outline, false,
//                     _emailTextController),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 reusableTextField("Nhập password của bạn", Icons.lock_outline, true,
//                 _passwordTextController),
//                 SizedBox(
//                   height: 5,
//                 ),
//                 forgetPassword(context),
//                 firebaseUIButton(context, "Sign In", () {
//                   FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailTextController.text,
//                       password: _passwordTextController.text).then((value) {
//                         Navigator.push(context,
//                         MaterialPageRoute(builder: (context) => HomePage()));
//                   }).onError((error, stackTrace) {
//                     print("Error ${error.toString()}");
//                   });
//                 }),
//                 signUpOption()
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   Row signUpOption() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text("Don't have account?",
//             style: TextStyle(color: Colors.white70)),
//         GestureDetector(
//           onTap: () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (context) => SignUpScreen()));
//           },
//           child: const Text(
//             " Sign Up",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//         )
//       ],
//     );
//   }
//   Widget forgetPassword(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: 35,
//       alignment: Alignment.bottomRight,
//       child: TextButton(
//         child: const Text(
//           "Forgot Password?",
//           style: TextStyle(color: Colors.white70),
//           textAlign: TextAlign.right,
//         ),
//         onPressed: () => Navigator.push(
//             context, MaterialPageRoute(builder: (context) => ResetPassword())),
//       ),
//     );
//   }
//
// }