import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetCheck{
  bool isInternetConnect = true;

  Future<void> isInternetConnectFunc() async {
    isInternetConnect = await InternetConnectionChecker().hasConnection;
  }
}