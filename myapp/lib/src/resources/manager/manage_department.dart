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
import '../../models/DepartmentModel.dart';
import '../../models/EmployeeModel.dart';
import '../../models/UserModel.dart';
import '../dialog/edit_employee_dialog.dart';
import '../dialog/loading_dialog.dart';
import '../dialog/msg_dialog.dart';
import '../employee/detail_question_employee.dart';

class ManageDepartment extends StatefulWidget {
  @override
  _ManageDepartmentState createState() => _ManageDepartmentState();
}

class _ManageDepartmentState extends State<ManageDepartment> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  var user_auth = FirebaseAuth.instance.currentUser!;
  AuthBloc authBloc = new AuthBloc();
  EmployeeModel current_employee =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
  List<EmployeeModel> list_employee = [];

  TextEditingController _categoryController = new TextEditingController();
  StreamController _categoryControll = new StreamController();
  Stream get categoryStream => _categoryControll.stream;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  StreamController _emailControl = new StreamController();
  StreamController _nameControl = new StreamController();
  StreamController _phoneControl = new StreamController();
  StreamController _passwordControl = new StreamController();

  Stream get emailControl => _emailControl.stream;
  Stream get nameControl => _nameControl.stream;
  Stream get phoneControl => _phoneControl.stream;
  Stream get passwordControl => _passwordControl.stream;

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

  var leader = new Map();
  getLeader() async {
    await FirebaseFirestore.instance
        .collection('employee')
        .get()
        .then((value) => {
      setState(() {
        value.docs.forEach((element) {
          if(element['roles']=='Trưởng nhóm') {
            EmployeeModel employeeModel = EmployeeModel("", "", "", "", "", "", "", "", "", "");
            employeeModel.id = element['id'];
            employeeModel.name = element['name'];
            employeeModel.category = element['category'];
            employeeModel.email = element['email'];
            employeeModel.image = element['image'];
            employeeModel.password = element['password'];
            employeeModel.phone = element['phone'];
            employeeModel.department = element['department'];
            employeeModel.roles = element['roles'];
            employeeModel.status = element['status'];
            leader[element['department']] = employeeModel;
          }
        });
      })
    });
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

    await getListDepartment();
    await getListEmployee();
    await getLeader();
  }
  _buildDepartment(BuildContext context, DepartmentModel department) {
    return GestureDetector(
      onTap: () {
        return _modalBottomSheetEditDepartment(department);
      },
      child: Card(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                    Container(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                      child: Expanded(
                        child: Text(department.name,
                            textAlign: TextAlign.left,
                            style: TextStyle(
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
  _buildEmployee(BuildContext context, EmployeeModel employee, EmployeeModel leader) {
    return GestureDetector(
      onTap: () {
        changeLeader(leader, employee);
      },
      child: Card(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(5, 5, 5, 5)),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Expanded(
                      child: Text(employee.name,
                          textAlign: TextAlign.left,
                          style: TextStyle(
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
  var list_department = new Map();
  getListDepartment() async {
    await FirebaseFirestore.instance.collection('departments')
        .get()
        .then((value) => {
      setState(() {
        value.docs.forEach((element) {
          DepartmentModel departmentModel = DepartmentModel("", "", []);
          departmentModel.id = element['id'];
          departmentModel.name = element['name'];
          departmentModel.category = element['category'].cast<String>();

          list_department[departmentModel.id] = departmentModel;
        });
      })
    });
  }

  getListEmployee() async {
    await FirebaseFirestore.instance.collection('employee')
        .get()
        .then((value) => {
      setState(() {
        value.docs.forEach((element) {
          EmployeeModel employeeModel = EmployeeModel("", "", "", "", "", "", "", "", "", "");
          employeeModel.id = element['id'];
          employeeModel.name = element['name'];
          employeeModel.category = element['category'];
          employeeModel.email = element['email'];
          employeeModel.image = element['image'];
          employeeModel.password = element['password'];
          employeeModel.phone = element['phone'];
          employeeModel.department = element['department'];
          employeeModel.roles = element['roles'];
          employeeModel.status = element['status'];

          list_employee.add(employeeModel);
        });
      })
    });
  }
  _modalBottomSheetEditDepartment(DepartmentModel department) {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.6),
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
                      child: Text('Chỉnh sửa khoa',
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
                            height: MediaQuery.of(context).size.height * 0.5,
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
                                      //stream: categoryControl,
                                      builder: (context, snapshot) => TextField(
                                        //controller: _categoryController,
                                        controller: TextEditingController()
                                          ..text = department.name,
                                        decoration:
                                        InputDecoration(
                                            labelText:
                                            "Tên khoa",
                                            hintText:
                                            'Nhập Tên khoa',
                                            enabledBorder:
                                            OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                borderSide: BorderSide(color:Colors.pinkAccent, width:1,)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10),
                                                borderSide: BorderSide(
                                                    color: Colors.pink,
                                                    width:
                                                    4))),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                                  Container(
                                    child:Column(
                                      children: [
                                        Text('Trưởng khoa',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 1.0,
                                          color: Colors.black38),
                                        ),
                                        Text(leader[department.id].name,
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.0,
                                              color: Colors.red),
                                        ),
                                      ],
                                    )
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(0, 40, 0, 10)),
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
                                                backgroundColor: MaterialStateProperty.all(Colors.pinkAccent)
                                            ),
                                            onPressed: () {
                                              //_onChangeCategoryClicked(employee.id, value_category);
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
                                                  backgroundColor: MaterialStateProperty.all(Colors.pinkAccent)
                                              ),
                                                onPressed: () =>
                                                    {Navigator.pop(context)},
                                                label: Text(
                                                  'Thoát',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                              icon: Icon(Icons.cancel_presentation),
                                            ),
                                        ),
                                      ],
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
                                      return _modalBottomSheetChangeLeader(leader[department.id]);
                                    },
                                      child: Text(
                                        "Thay đổi trưởng khoa",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.red),

                                      ),
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
              ),
            );
          });
        });

  }
  _modalBottomSheetChangeLeader(EmployeeModel leader){
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.85),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                  child: Text('Thay đổi trưởng khoa',
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
                      Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          //padding: EdgeInsets.only(),
                          itemCount: list_employee.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildEmployee(context, list_employee[index], leader);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
  changeLeader(EmployeeModel old_leader, EmployeeModel new_leader){
    var ref = FirebaseFirestore.instance.collection('employee');
    LoadingDialog.showLoadingDialog(context, "loading...");
    ref.doc(old_leader.id).update({
      'category': list_department[old_leader.department].category.first,
      'roles': 'Tư vấn viên'
    });
    ref.doc(new_leader.id).update({
      'department': old_leader.department,
      'category': '',
      'roles': 'Trưởng nhóm'
    });
    LoadingDialog.hideLoadingDialog(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ManageDepartment()));

  }
  _modalBottomSheetAddDepartment() {
    return showModalBottomSheet(
        isScrollControlled: true,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.6),
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
                        child: Text('Thêm Khoa',
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
                              height: MediaQuery.of(context).size.height * 0.5,
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
                                          //stream: informationControl,
                                          builder: (context, snapshot) =>TextField(
                                            //controller: _informationController,
                                            decoration:
                                            InputDecoration(
                                                labelText:
                                                "Tên khoa",
                                                hintText:
                                                'Nhập Tên khoa',
                                                enabledBorder:
                                                OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color:Colors.pinkAccent, width:1,)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .pink,
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
                                                backgroundColor: MaterialStateProperty.all(Colors.pinkAccent)
                                              ),
                                              onPressed: () {
                                                //_onAddEmployeeClicked();
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
                                                  backgroundColor: MaterialStateProperty.all(Colors.pinkAccent)
                                              ),
                                              onPressed: () =>
                                              {Navigator.pop(context)},
                                              label: Text(
                                                'Thoát',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                              icon: Icon(Icons.cancel_presentation),
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
                      new HomePageManager()));
            }
        ),
        title: const Text("Quản lý các khoa"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: Column(
          children: <Widget>[
            Padding(
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
                  Container(
                    height: MediaQuery.of(context).size.height * 0.78,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      //padding: EdgeInsets.only(),
                      itemCount: list_department.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildDepartment(context, list_department.values.elementAt(index));
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
              return _modalBottomSheetAddDepartment();
            },
            child: Icon(
              Icons.add,
              size: 25,
            ),
            backgroundColor: Colors.pink
          //params
        ),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.miniEndFloat
    );
  }
}
