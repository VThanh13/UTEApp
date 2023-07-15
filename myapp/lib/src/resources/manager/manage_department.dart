import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/resources/manager/home_page_manager.dart';

import '../../blocs/auth_bloc.dart';
import '../../models/DepartmentModel.dart';
import '../../models/EmployeeModel.dart';
import '../dialog/loading_dialog.dart';

class ManageDepartment extends StatefulWidget {
  const ManageDepartment({super.key});

  @override
  State<ManageDepartment> createState() => _ManageDepartmentState();
}

class _ManageDepartmentState extends State<ManageDepartment> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  var userAuth = FirebaseAuth.instance.currentUser!;
  AuthBloc authBloc = AuthBloc();
  EmployeeModel currentEmployee = EmployeeModel();
  List<EmployeeModel> listEmployee = [];

  final StreamController _categoryController = StreamController();

  Stream get categoryStream => _categoryController.stream;

  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _phoneController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();

  final StreamController _emailControl = StreamController();
  final StreamController _nameControl = StreamController();
  final StreamController _phoneControl = StreamController();
  final StreamController _passwordControl = StreamController();

  Stream get emailControl => _emailControl.stream;
  Stream get nameControl => _nameControl.stream;
  Stream get phoneControl => _phoneControl.stream;
  Stream get passwordControl => _passwordControl.stream;

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

  var leader = {};
  getLeader() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .get()
        .then((value) => {
              setState(() {
                for (var element in value.docs) {
                  if (element['roles'] == 'Trưởng nhóm') {
                    EmployeeModel employeeModel = EmployeeModel();
                    employeeModel.id = element['id'];
                    employeeModel.name = element['name'];
                    employeeModel.category = element['category'].cast<String>();
                    employeeModel.email = element['email'];
                    employeeModel.image = element['image'];
                    employeeModel.password = element['password'];
                    employeeModel.phone = element['phone'];
                    employeeModel.department = element['department'];
                    employeeModel.roles = element['roles'];
                    employeeModel.status = element['status'];
                    leader[element['department']] = employeeModel;
                  }
                }
              })
            });
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
              currentEmployee.category = value.docs.first['category'].cast<String>(),
              currentEmployee.roles = value.docs.first['roles'],
              currentEmployee.status = value.docs.first['status'],
            });

    await getListDepartment();
    await getListEmployee();
    await getLeader();
  }

  _buildDepartment(BuildContext context, DepartmentModel department) {
    return GestureDetector(
      onTap: () {
        // ignore: void_checks
        return _modalBottomSheetEditDepartment(department);
      },
      child: Card(
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Expanded(
                      child: Text(department.name!,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0))),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _buildEmployee(
      BuildContext context, EmployeeModel employee, EmployeeModel leader) {
    return GestureDetector(
      onTap: () {
        changeLeader(leader, employee);
      },
      child: Card(
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Expanded(
                      child: Text(employee.name!,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0))),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  var listDepartment = {};
  getListDepartment() async {
    await FirebaseFirestore.instance
        .collection('departments')
        .get()
        .then((value) => {
              setState(() {
                for (var element in value.docs) {
                  DepartmentModel departmentModel = DepartmentModel();
                  departmentModel.id = element['id'];
                  departmentModel.name = element['name'];
                  departmentModel.category = element['category'].cast<String>();

                  listDepartment[departmentModel.id] = departmentModel;
                }
              })
            });
  }

  getListEmployee() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .get()
        .then((value) => {
              setState(() {
                for (var element in value.docs) {
                  EmployeeModel employeeModel = EmployeeModel();
                  employeeModel.id = element['id'];
                  employeeModel.name = element['name'];
                  employeeModel.category = element['category'].cast<String>();
                  employeeModel.email = element['email'];
                  employeeModel.image = element['image'];
                  employeeModel.password = element['password'];
                  employeeModel.phone = element['phone'];
                  employeeModel.department = element['department'];
                  employeeModel.roles = element['roles'];
                  employeeModel.status = element['status'];

                  listEmployee.add(employeeModel);
                }
              })
            });
  }

  _modalBottomSheetEditDepartment(DepartmentModel department) {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(
          Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.6),
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
                    'Chỉnh sửa khoa',
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
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              Container(
                                margin: const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                width: 400,
                                child: StreamBuilder(
                                  //stream: categoryControl,
                                  builder: (context, snapshot) => TextField(
                                    //controller: _categoryController,
                                    controller: TextEditingController()
                                      ..text = department.name!,
                                    decoration: InputDecoration(
                                        labelText: "Tên khoa",
                                        hintText: 'Nhập Tên khoa',
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Colors.blueAccent,
                                              width: 1,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Colors.blue,
                                                width: 4))),
                                  ),
                                ),
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              Column(
                                children: [
                              const Text(
                                'Trưởng nhóm tư vấn',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1.0,
                                    color: Colors.black38),
                              ),
                              Text(
                                leader[department.id].name,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                    color: Colors.red),
                              ),
                                ],
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 40, 0, 10)),
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
                                                    Colors.blueAccent)),
                                        onPressed: () {
                                          //_onChangeCategoryClicked(employee.id, value_category);
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
                                                    Colors.blueAccent)),
                                        onPressed: () =>
                                            {Navigator.pop(context)},
                                        label: const Text(
                                          'Thoát',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.cancel_presentation),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 50, 0, 10)),
                              const Divider(
                                color: Colors.black,
                                height: 5.0,
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                              GestureDetector(
                                onTap: () {
                                  // ignore: void_checks
                                  return _modalBottomSheetChangeLeader(
                                      leader[department.id]);
                                },
                                child: const Text(
                                  "Thay đổi trưởng nhóm",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red),
                                ),
                              ),
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

  _modalBottomSheetChangeLeader(EmployeeModel leader) {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(
          Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.85),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                child: Text(
                  'Thay đổi trưởng nhóm',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0),
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
                        //padding: EdgeInsets.only(),
                        itemCount: listEmployee.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildEmployee(
                              context, listEmployee[index], leader);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  changeLeader(EmployeeModel oldLeader, EmployeeModel newLeader) {
    var ref = FirebaseFirestore.instance.collection('employee');
    LoadingDialog.showLoadingDialog(context, "Please Wait...");
    ref.doc(oldLeader.id).update({
      'category': listDepartment[oldLeader.department].category.first,
      'roles': 'Tư vấn viên'
    });
    ref.doc(newLeader.id).update({
      'department': oldLeader.department,
      'category': '',
      'roles': 'Trưởng nhóm'
    });
    LoadingDialog.hideLoadingDialog(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ManageDepartment()));
  }

  _modalBottomSheetAddDepartment() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(
          Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.6),
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
                    'Thêm Khoa',
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
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              Container(
                                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                  width: 400,
                                  child: StreamBuilder(
                                    //stream: informationControl,
                                    builder: (context, snapshot) => TextField(
                                      //controller: _informationController,
                                      decoration: InputDecoration(
                                          labelText: "Tên khoa",
                                          hintText: 'Nhập Tên khoa',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                color: Colors.blueAccent,
                                                width: 1,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.blue,
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
                                                    Colors.blueAccent)),
                                        onPressed: () {
                                          //_onAddEmployeeClicked();
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
                                                    Colors.blueAccent)),
                                        onPressed: () =>
                                            {Navigator.pop(context)},
                                        label: const Text(
                                          'Thoát',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                        icon: const Icon(Icons.cancel_presentation),
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
                        builder: (BuildContext context) =>
                            const HomePageManager()));
              }),
          title: const Text("Quản lý các khoa"),
          backgroundColor: Colors.blueAccent,
        ),
        body: SafeArea(
          minimum: const EdgeInsets.only(left: 20, right: 10),
          child: Column(
            children: <Widget>[
              const Padding(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                  child: Text("Quản lý khoa",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0))),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.78,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        //padding: EdgeInsets.only(),
                        itemCount: listDepartment.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildDepartment(
                              context, listDepartment.values.elementAt(index));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              // ignore: void_checks
              return _modalBottomSheetAddDepartment();
            },
            backgroundColor: Colors.blue,
            child: const Icon(
              Icons.add,
              size: 25,
            )
            //params
            ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniEndFloat);
  }
}
