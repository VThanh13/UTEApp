import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
class FireAuth {

  FirebaseAuth _fireBaseAuth = FirebaseAuth.instance;
  void createEmployee(String email, String password, String name, String phone,
  String department, String category, Function onSuccess, Function(String) onRegisterError){
    _fireBaseAuth
        .createUserWithEmailAndPassword(email: email, password: password).then((user){
      _createEmployee(user.user!.uid, email, password, name, phone, department, category, onSuccess, onRegisterError);
      print(user);
    }).catchError((err){
      //TODO
      _onSignUpErr(err.code, onRegisterError);
    });

  }
  void signUp(String email, String pass, String name, String phone,
      Function onSuccess, Function(String) onRegisterError){
    _fireBaseAuth
    .createUserWithEmailAndPassword(email: email, password: pass).then((user){
      _createUser(user.user!.uid, email, pass, name, phone, onSuccess, onRegisterError);
      print(user);
    }).catchError((err){
      //TODO
      _onSignUpErr(err.code, onRegisterError);
    });

  }

  void signIn(String email, String pass, Function onSuccess,
      Function(String) onSignInError) {
    _fireBaseAuth
        .signInWithEmailAndPassword(email: email, password: pass)
        .then((user) {
      print(user);
      onSuccess();
    }).catchError((err) {
      print("err: " + err.toString());
      onSignInError("Đăng nhập thất bại, vui lòng thử lại");
    });
  }

  _createUser(String userId, String email, String pass, String name, String phone, Function onSuccess,
      Function(String) onRegisterError) {
    var ref = FirebaseFirestore.instance.collection('user');
    ref.doc(userId).set({'userId': userId,
    'email':email,
    'pass':pass,
    'name':name,
    'phone': phone,
    'status': "enabled",
    'image': 'https://firebasestorage.googleapis.com/v0/b/uteapp-7ab04.appspot.com/o/avatar%2Fdefault_avatar.jpg?alt=media&token=3c5e96ba-7e96-4299-871f-c16285df1e2a'}).then((value) {
      onSuccess();
      print("add user");
    }).catchError((err){
      //TODO
      onRegisterError("Đăng ký không thành công, vui lòng thử lại");
    });
  }
  _createEmployee(String userId, String email, String password, String name, String phone,
      String department, String category, Function onSuccess, Function(String) onRegisterError) {
    var ref = FirebaseFirestore.instance.collection('employee');
    ref.doc(userId).set({
      'id': userId,
      'email': email,
      'name': name,
      'phone': phone,
      'roles': "Tư vấn viên",
      'password': password,
      'image': 'https://firebasestorage.googleapis.com/v0/b/uteapp-7ab04.appspot.com/o/avatar%2Fdefault_avatar.jpg?alt=media&token=3c5e96ba-7e96-4299-871f-c16285df1e2a',
      'department': department,
      'category': category,
      'status': "enabled",
    }
    ).then((value) {
      onSuccess();
      print("add nice");
    }).catchError((err){
      //TODO
      onRegisterError("Đăng ký không thành công, vui lòng thử lại");
    });
  }
  void _onSignUpErr(String code, Function(String) onRegisterError) {
    print(code);
    switch (code) {
      case "ERROR_INVALID_EMAIL":
      case "ERROR_INVALID_CREDENTIAL":
        onRegisterError("Email không hợp lệ");
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        onRegisterError("Email đã tồn tại");
        break;
      case "ERROR_WEAK_PASSWORD":
        onRegisterError("Mật khẩu không đủ mạnh");
        break;
      default:
        onRegisterError("Đăng ký không thành công, vui lòng thử lại");
        break;
    }
  }
}