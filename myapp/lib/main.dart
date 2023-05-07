import 'package:flutter/material.dart';
import 'package:myapp/src/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/src/blocs/auth_bloc.dart';
import 'package:myapp/src/resources/login_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main()  async{
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(
    AuthBloc(),
    const MaterialApp(
      // home: LoginPage(),
        home: LoginScreen(),
        debugShowCheckedModeBanner: false,
        //home: LoginAdmin(),

    )
  ));
  FlutterNativeSplash.remove();
}

