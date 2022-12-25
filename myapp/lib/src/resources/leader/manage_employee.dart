import 'dart:async';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/models/QuestionModel.dart';
import 'package:myapp/src/resources/home_page.dart';
import 'package:myapp/src/resources/manager/home_page_manager.dart';
import 'package:myapp/src/resources/messenger/detail_question.dart';

import '../../blocs/auth_bloc.dart';
import '../../models/EmployeeModel.dart';
import '../../models/UserModel.dart';
import '../dialog/edit_employee_dialog.dart';
import '../dialog/loading_dialog.dart';
import '../dialog/msg_dialog.dart';
import '../employee/detail_question_employee.dart';
import 'home_page_leader.dart';

class ManageEmployee extends StatefulWidget {
  @override
  _ManageEmployeeState createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<ManageEmployee> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  var user_auth = FirebaseAuth.instance.currentUser!;
  AuthBloc authBloc = new AuthBloc();
  EmployeeModel current_employee =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
  List<String> list_category = [];

  TextEditingController _categoryController = new TextEditingController();
  StreamController _categoryControll = new StreamController.broadcast();
  Stream get categoryStream => _categoryControll.stream;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _newPasswordController = new TextEditingController();

  StreamController _emailControl = new StreamController.broadcast();
  StreamController _nameControl = new StreamController.broadcast();
  StreamController _phoneControl = new StreamController.broadcast();
  StreamController _passwordControl = new StreamController.broadcast();
  StreamController _newPasswordControl = new StreamController.broadcast();

  Stream get emailControl => _emailControl.stream;
  Stream get nameControl => _nameControl.stream;
  Stream get phoneControl => _phoneControl.stream;
  Stream get passwordControl => _passwordControl.stream;
  Stream get newPasswordControl => _newPasswordControl.stream;

  String? value_category;

  var item_category = ['Học sinh THPT',
    'Sinh viên',
    'Phụ huynh',
    'Cựu sinh viên',
    'Khác'];

  @override
  void dispose() {
    authBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: user_auth.uid)
        .get()
        .then((value) => {
              current_employee.id = value.docs.first['id'],
              current_employee.name = value.docs.first['name'],
              current_employee.email = value.docs.first['email'],
              current_employee.image = value.docs.first['image'],
              current_employee.password = value.docs.first['password'],
              current_employee.phone = value.docs.first['phone'],
              current_employee.department = value.docs.first['department'],
              current_employee.category = value.docs.first['category'],
              current_employee.roles = value.docs.first['roles'],
              current_employee.status = value.docs.first['status']
            });

    await getListEmployeeByDepartment();
    await getListCategoy();
  }

  List<EmployeeModel> listEmployee = [];
  getListEmployeeByDepartment() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .where('department', isEqualTo: current_employee.department)
        .where('roles', isEqualTo: "Tư vấn viên")
        .get()
        .then((value) => {
              setState(() {
                value.docs.forEach((element) {
                  EmployeeModel employeeModel =
                      EmployeeModel("", "", "", "", "", "", "", "", "", "");
                  employeeModel.id = element['id'];
                  employeeModel.name = element['name'];
                  employeeModel.email = element['email'];
                  employeeModel.image = element['image'];
                  employeeModel.password = element['password'];
                  employeeModel.phone = element['phone'];
                  employeeModel.department = element['department'];
                  employeeModel.category = element['category'];
                  employeeModel.roles = element['roles'];
                  employeeModel.status = element['status'];

                  listEmployee.add(employeeModel);
                });
              })
            });
  }

  _buildEmployee(BuildContext context, EmployeeModel employee) {
    print(employee.name);
    return GestureDetector(
      onTap: () {
        return _modalBottomSheetEditEmployee(employee);
      },
      child: Card(
        child: Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(10, 5, 5, 5)),
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.tealAccent,
              child: CircleAvatar(
                backgroundImage: new NetworkImage(employee.image!),
                radius: 23,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                    child: Text(employee.name,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0))),
                Container(
                    padding: EdgeInsets.fromLTRB(20, 5, 0, 20),
                    child: Text(
                      employee.status == "enabled" ? "Active": "Inactive",
                      style: TextStyle(
                        color: employee.status == "enabled" ? Colors.green: Colors.red
                      ),
                      textAlign: TextAlign.left,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  getListCategoy() async {
    await FirebaseFirestore.instance.collection('departments')
        .where('id', isEqualTo: current_employee.department)
        .get()
        .then((value) => {
      setState((){
        list_category = value.docs.first["category"].cast<String>();
      })
    });
  }

  _modalBottomSheetEditEmployee(EmployeeModel employee) {
    bool isSwitched = employee.status == "enabled" ? true : false;
    value_category = employee.category;
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.75),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
            return Container(
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                      child: Text('Thông tin Tư vấn viên',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0),
                      ),
                  ),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    height: 150,
                                    child: Center(
                                      child: Stack(
                                        children: [
                                          new CircleAvatar(
                                            radius: 48,
                                            backgroundColor: Colors.tealAccent,
                                            child: CircleAvatar(
                                              backgroundImage: new NetworkImage(
                                                  employee.image!),
                                              radius: 46,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                                  Text(
                                    employee.roles!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                  Text(
                                    employee.name!,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                                  Container(
                                      margin: EdgeInsets
                                          .fromLTRB(
                                          10, 10, 10, 15),
                                      width: 400,
                                      padding: EdgeInsets
                                          .symmetric(
                                          horizontal:
                                          12,
                                          vertical: 4),
                                      decoration:
                                      BoxDecoration(
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            12),
                                        border: Border.all(
                                            color: Colors
                                                .orangeAccent,
                                            width: 4),
                                      ),
                                      child:
                                      DropdownButtonHideUnderline(
                                        child:
                                        DropdownButton(
                                          isExpanded: true,
                                          value: value_category,
                                          hint: Text("Vui lòng chọn lĩnh vực phụ trách"),
                                          iconSize: 36,
                                          items:list_category.map((option) {
                                            return DropdownMenuItem(
                                              child: Text("$option"),
                                              value: option,
                                            );
                                          }).toList(),
                                          onChanged:(selected_category){
                                            setStateKhoa(() {
                                              setState(() {
                                                this.value_category = selected_category;
                                              });
                                            });
                                          },
                                        ),
                                      )),
                                  Container(
                                    width: 300,
                                    height: 55,
                                    padding: EdgeInsets.all(0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  // Change your radius here
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                                backgroundColor: MaterialStateProperty.all(Colors.orangeAccent)

                                            ),
                                            onPressed: () {
                                              _onChangeCategoryClicked(employee.id, value_category);
                                              print('press save');
                                            },
                                            label: Text(
                                              'Lưu',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            icon: Icon(Icons.save_outlined),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(10)),
                                        Expanded(
                                            child: ElevatedButton.icon(
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    // Change your radius here
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                ),
                                                backgroundColor: MaterialStateProperty.all(Colors.orangeAccent)
                                              ),
                                                onPressed: () =>
                                                    {Navigator.pop(context)},
                                                label: Text(
                                                  'Thoát',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                              icon: Icon(Icons.cancel),
                                            ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.all(5)),
                                  // Container(
                                  //   width: 300,
                                  //   height: 45,
                                  //   child: ElevatedButton(
                                  //     style: ButtonStyle(
                                  //       backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                  //       shape: MaterialStateProperty.all(
                                  //         RoundedRectangleBorder(
                                  //           // Change your radius here
                                  //           borderRadius: BorderRadius.circular(16),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //     onPressed: () {
                                  //       _onCancelAccountClicked(employee.id, employee.status);
                                  //       print('press cancel account');
                                  //     },
                                  //     child: Text(
                                  //       employee.status == "enabled" ? "Vô hiệu hóa tài khoản": "Kích hoạt tài khoản",
                                  //       style: TextStyle(
                                  //           fontSize: 16,
                                  //           color: Colors.white),
                                  //     ),
                                  //   ),
                                  // ),
                                  new Divider(
                                    color: Colors.black,
                                    height: 5.0,
                                  ),
                                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                                  Container(
                                    child: GestureDetector(
                                      onTap: () {
                                        return _modalBottomSheetResetPassword(employee);
                                      },
                                      child: Text(
                                        "Reset Mật Khẩu",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red),

                                      ),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                                  new Divider(
                                    color: Colors.black,
                                    height: 5.0,
                                  ),
                                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                                  Container(
                                    child: GestureDetector(
                                      onTap: () {
                                        return _onCancelAccountClicked(employee.id, employee.status);
                                      },
                                      child: Text(
                                        employee.status == "enabled" ? "Vô hiệu hóa tài khoản": "Kích hoạt tài khoản",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red),

                                      ),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                                  // Row(
                                  //   children:[
                                  //     Padding(
                                  //     padding: EdgeInsets.only(left: 30),
                                  //       child: Text('Trạng thái tài khoản',
                                  //       style: TextStyle(
                                  //       fontSize: 16,
                                  //       color: Colors.black,
                                  //           fontWeight: FontWeight.w600)),
                                  //     ),
                                  //     Padding(
                                  //     padding: EdgeInsets.only(left: 90),
                                  //     child: Column(
                                  //       mainAxisAlignment: MainAxisAlignment.center,
                                  //       children:[ Transform.scale(
                                  //         scale: 1,
                                  //         child: Switch(
                                  //           onChanged: (value) {
                                  //             setState(() {
                                  //               isSwitched = value;
                                  //             });
                                  //           },
                                  //           value: isSwitched,
                                  //           activeColor: Colors.blue,
                                  //           activeTrackColor: Colors.grey,
                                  //           inactiveThumbColor: Colors.red,
                                  //           inactiveTrackColor: Colors.grey,
                                  //           )
                                  //         ),
                                  //     ]),
                                  //     ),
                                  // ],
                                  // ),
                                  ],
                              ),
                            ),
                          ),
                        ],
                    ),
                  ),
                ],
              ),
            );
          });
        });

  }
  _modalBottomSheetResetPassword(employee){
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.75),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
                return Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                        child: Text('Reset Password',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0),
                        ),
                      ),
                      SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                                    Container(
                                        margin:
                                        EdgeInsets.fromLTRB(
                                            10, 10, 10, 15),
                                        width: 400,
                                        child: StreamBuilder(
                                          stream: newPasswordControl,
                                          builder: (context, snapshot) =>TextField(
                                            controller: _newPasswordController,
                                            decoration:
                                            InputDecoration(
                                                labelText:
                                                "Password",
                                                hintText:
                                                'Nhập password',
                                                enabledBorder:
                                                OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color:Colors.orangeAccent, width:1,)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                    borderSide: BorderSide(
                                                        color: Colors.orange,
                                                        width:
                                                        4))),
                                          ),
                                        )
                                    ),
                                    Container(
                                      width: 300,
                                      height: 55,
                                      padding: EdgeInsets.all(0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    // Change your radius here
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),

                                                ),
                                                backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                                              ),
                                              onPressed: () {
                                                _onChangePasswordClicked(employee);
                                                print('press save');
                                              },
                                              label: Text(
                                                'Lưu',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                              icon: Icon(Icons.add),

                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.all(10)),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    // Change your radius here
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                ),
                                                backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                                              ),
                                              onPressed: () =>
                                              {Navigator.pop(context)},
                                              label: Text(
                                                'Thoát',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                              icon: Icon(Icons.cancel),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(5)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }
  bool isValidChangePass(String password) {
    if (password == null || password.length == 0) {
      _newPasswordControl.sink.addError("Nhập password");
      return false;
    }
    if (password.length < 6) {
      _newPasswordControl.sink.addError("Password phải từ 6 ký tự trở lên");
      return false;
    }

    return true;
  }
  _onChangePasswordClicked(employee){
    var isvalid = isValidChangePass(
        _newPasswordController.text);
    if (isvalid) {
      String password = _newPasswordController.text;
      LoadingDialog.showLoadingDialog(context, "loading...");

      FirebaseAuth.instance.signInWithEmailAndPassword(email: employee.email, password: employee.password);
      FirebaseAuth.instance.currentUser?.updatePassword(password);
      FirebaseAuth.instance.signInWithEmailAndPassword(email: current_employee.email, password: current_employee.password);

      changePassword(employee.id, password, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ManageEmployee()));
      });
    }
  }

  changePassword(id, password, Function onSuccess) async {
    var ref = FirebaseFirestore.instance.collection('employee');

    ref.doc(id).update({'password': password}).then((value) {
      onSuccess();
      print("change pass ok");
    }).catchError((err) {
      print("err");
    });
  }
  _modalBottomSheetAddEmployee() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.75),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
                return Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                        child: Text('Thêm Tư vấn viên',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0),
                        ),
                      ),
                      SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                                    Container(
                                        margin: EdgeInsets
                                            .fromLTRB(
                                            10, 10, 10, 15),
                                        width: 400,
                                        padding: EdgeInsets
                                            .symmetric(
                                            horizontal:
                                            12,
                                            vertical: 4),
                                        decoration:
                                        BoxDecoration(
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                              12),
                                          border: Border.all(
                                              color: Colors
                                                  .orangeAccent,
                                              width: 4),
                                        ),
                                        child:
                                        DropdownButtonHideUnderline(
                                          child:
                                          DropdownButton(
                                            isExpanded: true,
                                            value: value_category,
                                            hint: Text("Vui lòng chọn lĩnh vực phụ trách"),
                                            iconSize: 36,
                                            items:list_category.map((option) {
                                              return DropdownMenuItem(
                                                child: Text("$option"),
                                                value: option,
                                              );
                                            }).toList(),
                                            onChanged:(selected_category){
                                              setStateKhoa(() {
                                                setState(() {
                                                  this.value_category = selected_category;
                                                });
                                              });
                                            },
                                          ),
                                        ),
                                    ),
                                    Container(
                                        margin:
                                        EdgeInsets.fromLTRB(
                                            10, 10, 10, 15),
                                        width: 400,
                                        child: StreamBuilder(
                                          stream: emailControl,
                                          builder: (context, snapshot) =>TextField(
                                            controller: _emailController,
                                            decoration:
                                            InputDecoration(
                                                labelText:
                                                "Email",
                                                hintText:
                                                'Nhập Email',
                                                enabledBorder:
                                                OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color:Colors.orangeAccent, width:1,)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                    borderSide: BorderSide(
                                                        color: Colors.orange,
                                                        width:
                                                        4))),
                                          ),
                                        )
                                    ),
                                    Container(
                                        margin:
                                        EdgeInsets.fromLTRB(
                                            10, 10, 10, 15),
                                        width: 400,
                                        child: StreamBuilder(
                                          stream: nameControl,
                                          builder: (context, snapshot) =>TextField(
                                            controller: _nameController,
                                            decoration:
                                            InputDecoration(
                                                labelText:
                                                "Tên",
                                                hintText:
                                                'Nhập tên',
                                                enabledBorder:
                                                OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color:Colors.orangeAccent, width:1,)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                    borderSide: BorderSide(
                                                        color: Colors.orange,
                                                        width:
                                                        4))),
                                          ),
                                        )
                                    ),
                                    Container(
                                        margin:
                                        EdgeInsets.fromLTRB(
                                            10, 10, 10, 15),
                                        width: 400,
                                        child: StreamBuilder(
                                          stream: phoneControl,
                                          builder: (context, snapshot) =>TextField(
                                            controller: _phoneController,
                                            decoration:
                                            InputDecoration(
                                                labelText:
                                                "Số điện thoại",
                                                hintText:
                                                'Nhập số điện thoại',
                                                enabledBorder:
                                                OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color:Colors.orangeAccent, width:1,)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                    borderSide: BorderSide(
                                                        color: Colors.orange,
                                                        width:
                                                        4))),
                                          ),
                                        )
                                    ),
                                    Container(
                                        margin:
                                        EdgeInsets.fromLTRB(
                                            10, 10, 10, 15),
                                        width: 400,
                                        child: StreamBuilder(
                                          stream: passwordControl,
                                          builder: (context, snapshot) =>TextField(
                                            controller: _passwordController,
                                            decoration:
                                            InputDecoration(
                                                labelText:
                                                "Password",
                                                hintText:
                                                'Nhập password',
                                                enabledBorder:
                                                OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color:Colors.orangeAccent, width:1,)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                    borderSide: BorderSide(
                                                        color: Colors.orange,
                                                        width:
                                                        4))),
                                          ),
                                        )
                                    ),
                                    Container(
                                      width: 300,
                                      height: 55,
                                      padding: EdgeInsets.all(0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    // Change your radius here
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  
                                                  
                                                ),
                                                backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                                                
                                              ),
                                              
                                              onPressed: () {
                                                _onAddEmployeeClicked();
                                                print('press save');
                                              },
                                              label: Text(
                                                'Lưu',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                              icon: Icon(Icons.add),
                                              
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.all(10)),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    // Change your radius here
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                ),
                                                backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                                              ),
                                              onPressed: () =>
                                              {Navigator.pop(context)},
                                              label: Text(
                                                'Thoát',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                              icon: Icon(Icons.cancel),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(5)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        });

  }
  _onChangeCategoryClicked(id, category){
    LoadingDialog.showLoadingDialog(context, "loading...");
    changeCategory(id, category, () {
          LoadingDialog.hideLoadingDialog(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ManageEmployee()));
        });
  }

  changeCategory(id, category, Function onSuccess) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: id)
        .get();
    String doc_id = snapshot.docs.first.id;
    var ref = FirebaseFirestore.instance.collection('employee');

    ref.doc(doc_id).update({
      'category':category
    }).then((value) {
      onSuccess();
      print("update successful");
    }).catchError((err){
      //TODO
      print("err");
      print(err);
    });
  }
  _onCancelAccountClicked(id, status){
    LoadingDialog.showLoadingDialog(context, "loading...");
    cancelAccount(id, status, () {
      LoadingDialog.hideLoadingDialog(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ManageEmployee()));
    });
  }

  cancelAccount(id, status, Function onSuccess) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: id)
        .get();
    String doc_id = snapshot.docs.first.id;
    var ref = FirebaseFirestore.instance.collection('employee');

    ref.doc(doc_id).update({
      'status': status == 'enabled'? 'disabled' : 'enabled'
    }).then((value) {
      onSuccess();
      print("update successful");
    }).catchError((err){
      //TODO
      print("err");
      print(err);
    });
  }
  _onAddEmployeeClicked(){
    String email = _emailController.text;
    String name = _nameController.text;
    String phone = _phoneController.text;
    String password = _passwordController.text;
    String category = value_category!;
    String department = current_employee.department;
    if(isValid(email, name, phone, password)){
      LoadingDialog.showLoadingDialog(context, "loading...");
      authBloc.createEmployee(email, password, name, phone,
          department, category, () {
            LoadingDialog.hideLoadingDialog(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ManageEmployee()));
          },(msg){
            LoadingDialog.hideLoadingDialog(context);
            MsgDialog.showMsgDialog(context, "Sign-In", msg);

          });
    }
  }
  bool isValid(String email, String name, String phone, String password){
    if(email == null || email.length == 0){
      _emailControl.sink.addError("Nhập email");
      return false;
    }
    if(name == null || name.length == 0){
      _nameControl.sink.addError("Nhập tên");
      return false;
    }
    if(phone == null || phone.length == 0){
      _phoneControl.sink.addError("Nhập số điện thoại");
      return false;
    }
    if(password == null || password.length == 0){
      _passwordControl.sink.addError("Nhập mật khẩu");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                      new HomePageLeader()));
            }
        ),
        title: const Text("Quản lý Tư vấn viên"),
        backgroundColor: Colors.orangeAccent,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _modalBottomSheetAddEmployee();
          },
          child: Icon(
            Icons.add,
            size: 25,
          ),
          backgroundColor: Colors.orange
        //params
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: Column(
          children: <Widget>[
            const Padding(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: Text('Tư vấn viên',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0))),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      //padding: EdgeInsets.only(),
                      itemCount: listEmployee.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildEmployee(context, listEmployee[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
