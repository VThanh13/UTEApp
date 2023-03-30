import 'package:flutter/material.dart';
import 'package:myapp/src/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/src/blocs/auth_bloc.dart';
import 'package:myapp/src/resources/admin/login_admin.dart';
import 'package:myapp/src/resources/home_page.dart';
import 'package:myapp/src/resources/login_page.dart';
import 'package:myapp/src/resources/login_page2.dart';
import 'package:myapp/src/resources/login_screen.dart';
import 'package:myapp/src/screens/signin_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main()  async{
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(
    new AuthBloc(),
    MaterialApp(
      // home: LoginPage(),
        home: LoginScreen(),
        //home: LoginAdmin(),

    )
  ));
  FlutterNativeSplash.remove();
}

