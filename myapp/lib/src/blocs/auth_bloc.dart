import 'dart:async';

import 'package:myapp/src/fire_base/fire_base_auth.dart';

class AuthBloc {
  var _fireAuth = FireAuth();

  StreamController _nameController = new StreamController();
  StreamController _emailController = new StreamController();
  StreamController _passController = new StreamController();
  StreamController _phoneController = new StreamController();
  StreamController _groupController = new StreamController();

  Stream get nameStream => _nameController.stream;
  Stream get emailStream => _emailController.stream;
  Stream get passStream => _passController.stream;
  Stream get phoneStream => _phoneController.stream;
  Stream get groupStream => _groupController.stream;

  bool isValid_Login(String email, String pass){
    if (email == null || email.length == 0) {
      _emailController.sink.addError("Nhập email");
      return false;
    }
    _emailController.sink.add("");
    if (pass == null || pass.length < 6) {
      _passController.sink.addError("Mật khẩu phải trên 5 ký tự");
      return false;
    }
    _passController.sink.add("");

    return true;
  }

  bool isValidSignUp(String name, String email, String password, String phone) {
    if (name == null || name.length == 0) {
      _nameController.sink.addError("Nhập tên");
      return false;
    }
    _nameController.sink.add("");

    if (phone == null || phone.length == 0) {
      _phoneController.sink.addError("Nhập số điện thoại");
      return false;
    }
    _phoneController.sink.add("");

    if (email == null || email.length == 0) {
      _emailController.sink.addError("Nhập email");
      return false;
    }
    _emailController.sink.add("");

    if (password == null || password.length < 6) {
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
      String department, String category, Function onSuccess, Function(String) onRegisterError){
    _fireAuth.createEmployee(email, password, name, phone, department, category, onSuccess, onRegisterError);
  }

  void dispose() {
    _nameController.close();
    _emailController.close();
    _passController.close();
    _phoneController.close();
  }
}