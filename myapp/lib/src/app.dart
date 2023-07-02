import 'package:flutter/material.dart';
import 'package:myapp/src/blocs/auth_bloc.dart';
class MyApp extends InheritedWidget {
  final AuthBloc authBloc;
  @override
  // ignore: overridden_fields
  final Widget child;
  const MyApp(this.authBloc, this.child, {super.key}) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return false;
  }

  static MyApp? of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<MyApp>();
  }

}