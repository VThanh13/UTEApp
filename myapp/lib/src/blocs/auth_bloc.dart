import 'dart:async';
import 'package:myapp/src/fire_base/fire_base_auth.dart';

class AuthBloc {
  final _fireAuth = FireAuth();

  final StreamController _nameController = StreamController();
  final StreamController _emailController = StreamController();
  final StreamController _passController = StreamController();
  final StreamController _phoneController = StreamController();
  final StreamController _groupController = StreamController();

  Stream get nameStream => _nameController.stream;
  Stream get emailStream => _emailController.stream;
  Stream get passStream => _passController.stream;
  Stream get phoneStream => _phoneController.stream;
  Stream get groupStream => _groupController.stream;

  bool isValidLogin(String email, String pass){
    if (email.isEmpty) {
      _emailController.sink.addError("Nhập email");
      return false;
    }
    _emailController.sink.add("");
    if (pass.length < 6) {
      _passController.sink.addError("Mật khẩu phải trên 5 ký tự");
      return false;
    }
    _passController.sink.add("");

    return true;
  }

  bool isValidSignUp(String name, String email, String password, String phone) {
    if (name.isEmpty) {
      _nameController.sink.addError("Nhập tên");
      return false;
    }
    _nameController.sink.add("");

    if (phone.isEmpty) {
      _phoneController.sink.addError("Nhập số điện thoại");
      return false;
    }
    _phoneController.sink.add("");

    if (email.isEmpty) {
      _emailController.sink.addError("Nhập email");
      return false;
    }
    _emailController.sink.add("");

    if (password.length < 6) {
      _passController.sink.addError("Mật khẩu phải trên 5 ký tự");
      return false;
    }
    _passController.sink.add("");

    return true;
  }

  void signUp(String email, String password, String phone, String name, String group,
      Function onSuccess, Function(String) onRegisterError){
    _fireAuth.signUp(email, password, name, phone, group, onSuccess, onRegisterError);
  }

  void signIn(String email, String pass, Function onSuccess,
      Function(String) onSignInError) {
    _fireAuth.signIn(email, pass, onSuccess, onSignInError);
  }

  void createEmployee(String email, String password, String name, String phone,
      String department, List<String> category, Function onSuccess, Function(String) onRegisterError){
    _fireAuth.createEmployee(email, password, name, phone, department, category, onSuccess, onRegisterError);
  }

  void dispose() {
    _nameController.close();
    _emailController.close();
    _passController.close();
    _phoneController.close();
  }
}