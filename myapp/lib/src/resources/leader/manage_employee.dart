import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../blocs/auth_bloc.dart';
import '../../models/EmployeeModel.dart';
import '../dialog/loading_dialog.dart';
import '../dialog/msg_dialog.dart';
import 'home_page_leader.dart';

class ManageEmployee extends StatefulWidget {
  const ManageEmployee({super.key});

  @override
  State<ManageEmployee> createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<ManageEmployee> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  var userAuth = FirebaseAuth.instance.currentUser!;
  AuthBloc authBloc = AuthBloc();
  EmployeeModel currentEmployee =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
  List<String> listCategory = [];

  final StreamController _categoryControll = StreamController.broadcast();
  Stream get categoryStream => _categoryControll.stream;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final StreamController _emailControl = StreamController.broadcast();
  final StreamController _nameControl = StreamController.broadcast();
  final StreamController _phoneControl = StreamController.broadcast();
  final StreamController _passwordControl = StreamController.broadcast();
  final StreamController _newPasswordControl = StreamController.broadcast();

  Stream get emailControl => _emailControl.stream;
  Stream get nameControl => _nameControl.stream;
  Stream get phoneControl => _phoneControl.stream;
  Stream get passwordControl => _passwordControl.stream;
  Stream get newPasswordControl => _newPasswordControl.stream;

  String? valueCategory;

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
        .where('id', isEqualTo: userAuth.uid)
        .get()
        .then((value) => {
              currentEmployee.id = value.docs.first['id'],
              currentEmployee.name = value.docs.first['name'],
              currentEmployee.email = value.docs.first['email'],
              currentEmployee.image = value.docs.first['image'],
              currentEmployee.password = value.docs.first['password'],
              currentEmployee.phone = value.docs.first['phone'],
              currentEmployee.department = value.docs.first['department'],
              currentEmployee.category = value.docs.first['category'],
              currentEmployee.roles = value.docs.first['roles'],
              currentEmployee.status = value.docs.first['status']
            });

    await getListEmployeeByDepartment();
    await getListCategory();
  }

  List<EmployeeModel> listEmployee = [];
  getListEmployeeByDepartment() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .where('department', isEqualTo: currentEmployee.department)
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
    return GestureDetector(
      onTap: () {
        return _modalBottomSheetEditEmployee(employee);
      },
      child: Card(
        child: Row(
          children: <Widget>[
            const Padding(padding: EdgeInsets.fromLTRB(10, 5, 5, 5)),
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.tealAccent,
              child: CircleAvatar(
                backgroundImage: NetworkImage(employee.image!),
                radius: 23,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 0, 10),
                    child: Text(employee.name,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0))),
                Container(
                    padding: const EdgeInsets.fromLTRB(20, 5, 0, 20),
                    child: Text(
                      employee.status == "enabled" ? "Active" : "Inactive",
                      style: TextStyle(
                          color: employee.status == "enabled"
                              ? Colors.green
                              : Colors.red),
                      textAlign: TextAlign.left,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  getListCategory() async {
    await FirebaseFirestore.instance
        .collection('departments')
        .where('id', isEqualTo: currentEmployee.department)
        .get()
        .then((value) => {
              setState(() {
                listCategory = value.docs.first["category"].cast<String>();
              })
            });
  }

  _modalBottomSheetEditEmployee(EmployeeModel employee) {
    bool isSwitched = employee.status == "enabled" ? true : false;
    valueCategory = employee.category;
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(
          Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.75),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
            return Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                  child: Text(
                    'Thông tin Tư vấn viên',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                height: 150,
                                child: Center(
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 48,
                                        backgroundColor: Colors.tealAccent,
                                        child: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(employee.image!),
                                          radius: 46,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              Text(
                                employee.roles!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              Text(
                                employee.name!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                  width: 400,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.orangeAccent, width: 4),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: valueCategory,
                                      hint: const Text(
                                          "Vui lòng chọn lĩnh vực phụ trách"),
                                      iconSize: 36,
                                      items: listCategory.map((option) {
                                        return DropdownMenuItem(
                                          value: option,
                                          child: Text("$option"),
                                        );
                                      }).toList(),
                                      onChanged: (selectedCategory) {
                                        setStateKhoa(() {
                                          setState(() {
                                            valueCategory = selectedCategory;
                                          });
                                        });
                                      },
                                    ),
                                  )),
                              Container(
                                width: 300,
                                height: 55,
                                padding: const EdgeInsets.all(0),
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
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.orangeAccent)),
                                        onPressed: () {
                                          _onChangeCategoryClicked(
                                              employee.id, valueCategory);
                                        },
                                        label: const Text(
                                          'Lưu',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.save_outlined),
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.all(10)),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ButtonStyle(
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                // Change your radius here
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.orangeAccent)),
                                        onPressed: () =>
                                            {Navigator.pop(context)},
                                        label: const Text(
                                          'Thoát',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.cancel),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
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
                              const Divider(
                                color: Colors.black,
                                height: 5.0,
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                              GestureDetector(
                                onTap: () {
                                  return _modalBottomSheetResetPassword(
                                      employee);
                                },
                                child: const Text(
                                  "Reset Mật Khẩu",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red),
                                ),
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                              const Divider(
                                color: Colors.black,
                                height: 5.0,
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                              GestureDetector(
                                onTap: () {
                                  return _onCancelAccountClicked(
                                      employee.id, employee.status);
                                },
                                child: Text(
                                  employee.status == "enabled"
                                      ? "Vô hiệu hóa tài khoản"
                                      : "Kích hoạt tài khoản",
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.red),
                                ),
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
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
            );
          });
        });
  }

  _modalBottomSheetResetPassword(employee) {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(
          Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.75),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
            return Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                  child: Text(
                    'Reset Password',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                  width: 400,
                                  child: StreamBuilder(
                                    stream: newPasswordControl,
                                    builder: (context, snapshot) => TextField(
                                      controller: _newPasswordController,
                                      decoration: InputDecoration(
                                          labelText: "Password",
                                          hintText: 'Nhập password',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Colors.orangeAccent,
                                                width: 1,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.orange,
                                                  width: 4))),
                                    ),
                                  )),
                              Container(
                                width: 300,
                                height: 55,
                                padding: const EdgeInsets.all(0),
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
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.orangeAccent),
                                        ),
                                        onPressed: () {
                                          _onChangePasswordClicked(employee);
                                        },
                                        label: const Text(
                                          'Lưu',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.add),
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.all(10)),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              // Change your radius here
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.orangeAccent),
                                        ),
                                        onPressed: () =>
                                            {Navigator.pop(context)},
                                        label: const Text(
                                          'Thoát',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.cancel),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }

  bool isValidChangePass(String password) {
    if (password.isEmpty) {
      _newPasswordControl.sink.addError("Nhập password");
      return false;
    }
    if (password.length < 6) {
      _newPasswordControl.sink.addError("Password phải từ 6 ký tự trở lên");
      return false;
    }

    return true;
  }

  _onChangePasswordClicked(employee) {
    var isvalid = isValidChangePass(_newPasswordController.text);
    if (isvalid) {
      String password = _newPasswordController.text;
      LoadingDialog.showLoadingDialog(context, "loading...");

      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: employee.email, password: employee.password);
      FirebaseAuth.instance.currentUser?.updatePassword(password);
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: currentEmployee.email, password: currentEmployee.password);

      changePassword(employee.id, password, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ManageEmployee()));
      });
    }
  }

  changePassword(id, password, Function onSuccess) async {
    var ref = FirebaseFirestore.instance.collection('employee');

    ref.doc(id).update({'password': password}).then((value) {
      onSuccess();
    }).catchError((err) {});
  }

  _modalBottomSheetAddEmployee() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(
          Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.75),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateKhoa) {
            return Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                  child: Text(
                    'Thêm Tư vấn viên',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                width: 400,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.orangeAccent, width: 4),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    value: valueCategory,
                                    hint: const Text(
                                        "Vui lòng chọn lĩnh vực phụ trách"),
                                    iconSize: 36,
                                    items: listCategory.map((option) {
                                      return DropdownMenuItem(
                                        value: option,
                                        child: Text("$option"),
                                      );
                                    }).toList(),
                                    onChanged: (selectedCategory) {
                                      setStateKhoa(() {
                                        setState(() {
                                          valueCategory = selectedCategory;
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                  width: 400,
                                  child: StreamBuilder(
                                    stream: emailControl,
                                    builder: (context, snapshot) => TextField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                          labelText: "Email",
                                          hintText: 'Nhập Email',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Colors.orangeAccent,
                                                width: 1,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.orange,
                                                  width: 4))),
                                    ),
                                  )),
                              Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                  width: 400,
                                  child: StreamBuilder(
                                    stream: nameControl,
                                    builder: (context, snapshot) => TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                          labelText: "Tên",
                                          hintText: 'Nhập tên',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Colors.orangeAccent,
                                                width: 1,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.orange,
                                                  width: 4))),
                                    ),
                                  )),
                              Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                  width: 400,
                                  child: StreamBuilder(
                                    stream: phoneControl,
                                    builder: (context, snapshot) => TextField(
                                      controller: _phoneController,
                                      decoration: InputDecoration(
                                          labelText: "Số điện thoại",
                                          hintText: 'Nhập số điện thoại',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Colors.orangeAccent,
                                                width: 1,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.orange,
                                                  width: 4))),
                                    ),
                                  )),
                              Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                  width: 400,
                                  child: StreamBuilder(
                                    stream: passwordControl,
                                    builder: (context, snapshot) => TextField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                          labelText: "Password",
                                          hintText: 'Nhập password',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Colors.orangeAccent,
                                                width: 1,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.orange,
                                                  width: 4))),
                                    ),
                                  )),
                              Container(
                                width: 300,
                                height: 55,
                                padding: const EdgeInsets.all(0),
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
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.orangeAccent),
                                        ),
                                        onPressed: () {
                                          _onAddEmployeeClicked();
                                        },
                                        label: const Text(
                                          'Lưu',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.add),
                                      ),
                                    ),
                                    const Padding(padding: EdgeInsets.all(10)),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              // Change your radius here
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.orangeAccent),
                                        ),
                                        onPressed: () =>
                                            {Navigator.pop(context)},
                                        label: const Text(
                                          'Thoát',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.cancel),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }

  _onChangeCategoryClicked(id, category) {
    LoadingDialog.showLoadingDialog(context, "loading...");
    changeCategory(id, category, () {
      LoadingDialog.hideLoadingDialog(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ManageEmployee()));
    });
  }

  changeCategory(id, category, Function onSuccess) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: id)
        .get();
    String docId = snapshot.docs.first.id;
    var ref = FirebaseFirestore.instance.collection('employee');

    ref.doc(docId).update({'category': category}).then((value) {
      onSuccess();
    }).catchError((err) {
      //TODO
    });
  }

  _onCancelAccountClicked(id, status) {
    LoadingDialog.showLoadingDialog(context, "loading...");
    cancelAccount(id, status, () {
      LoadingDialog.hideLoadingDialog(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ManageEmployee()));
    });
  }

  cancelAccount(id, status, Function onSuccess) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('employee')
        .where('id', isEqualTo: id)
        .get();
    String docId = snapshot.docs.first.id;
    var ref = FirebaseFirestore.instance.collection('employee');

    ref.doc(docId).update(
        {'status': status == 'enabled' ? 'disabled' : 'enabled'}).then((value) {
      onSuccess();
    }).catchError((err) {
      //TODO
    });
  }

  _onAddEmployeeClicked() {
    String email = _emailController.text;
    String name = _nameController.text;
    String phone = _phoneController.text;
    String password = _passwordController.text;
    String category = valueCategory!;
    String department = currentEmployee.department;
    if (isValid(email, name, phone, password)) {
      LoadingDialog.showLoadingDialog(context, "loading...");
      authBloc.createEmployee(
          email, password, name, phone, department, category, () {
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ManageEmployee()));
      }, (msg) {
        LoadingDialog.hideLoadingDialog(context);
        MsgDialog.showMsgDialog(context, "Sign-In", msg);
      });
    }
  }

  bool isValid(String email, String name, String phone, String password) {
    if (email.isEmpty) {
      _emailControl.sink.addError("Nhập email");
      return false;
    }
    if (name.isEmpty) {
      _nameControl.sink.addError("Nhập tên");
      return false;
    }
    if (phone.isEmpty) {
      _phoneControl.sink.addError("Nhập số điện thoại");
      return false;
    }
    if (password.isEmpty) {
      _passwordControl.sink.addError("Nhập mật khẩu");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const HomePageLeader()));
            }),
        title: const Text("Quản lý Tư vấn viên"),
        backgroundColor: Colors.orangeAccent,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _modalBottomSheetAddEmployee();
          },
          backgroundColor: Colors.orange,
          child: const Icon(
            Icons.add,
            size: 25,
          )
          //params
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: Text(
                'Tư vấn viên',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
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
