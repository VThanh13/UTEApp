import 'package:flutter/material.dart';
import 'package:myapp/src/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/src/blocs/auth_bloc.dart';
import 'package:myapp/src/resources/home_page.dart';
import 'package:myapp/src/resources/login_page.dart';
void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(
    new AuthBloc(),
    MaterialApp(
      home: LoginPage(),
    )
  ));
}

