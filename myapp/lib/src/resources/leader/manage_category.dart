import 'dart:async';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/models/QuestionModel.dart';
import 'package:myapp/src/resources/home_page.dart';
import 'package:myapp/src/resources/messenger/detail_question.dart';

import '../../blocs/auth_bloc.dart';
import '../../models/EmployeeModel.dart';
import '../../models/UserModel.dart';
import '../dialog/edit_employee_dialog.dart';
import '../dialog/loading_dialog.dart';
import '../dialog/msg_dialog.dart';
import '../employee/detail_question_employee.dart';

class ManageCategory extends StatefulWidget {
  @override
  _ManageCategoryState createState() => _ManageCategoryState();
}

class _ManageCategoryState extends State<ManageCategory> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  var user_auth = FirebaseAuth.instance.currentUser!;
  AuthBloc authBloc = new AuthBloc();
  EmployeeModel current_employee =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
  List<String> list_category = [];

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

    await getListCategoy();
  }

  _buildCategory(BuildContext context, String category) {
    return GestureDetector(
      onTap: () {
        return _modalBottomSheetEditCategory(category);
      },
      child: Card(
        child: Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(10, 5, 5, 5)),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                    child: Text(category,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0))),
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
  _modalBottomSheetEditCategory(String category) {
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
                      child: Text('Lĩnh vực',
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
                                        0, 10, 0, 15),
                                    width: 340,
                                    child: StreamBuilder(
                                      //stream: categoryControl,
                                      builder: (context, snapshot) => TextField(
                                        //controller: _categoryController,
                                        controller: TextEditingController()
                                          ..text = category,
                                        decoration:
                                        InputDecoration(
                                            labelText:
                                            "Lĩnh vực",
                                            hintText:
                                            'Nhập Lĩnh vực',
                                            enabledBorder:
                                            OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                borderSide: BorderSide(color:Colors.blueAccent, width:1,)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10),
                                                borderSide: BorderSide(
                                                    color: Colors
                                                        .blue,
                                                    width:
                                                    4))),
                                      ),
                                    ),
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
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  // Change your radius here
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              //_onChangeCategoryClicked(employee.id, value_category);
                                              print('press save');
                                            },
                                            child: Text(
                                              'Lưu',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(10)),
                                        Expanded(
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    // Change your radius here
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                ),
                                              ),
                                                onPressed: () =>
                                                    {Navigator.pop(context)},
                                                child: Text(
                                                  'Thoát',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                            ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.all(5)),
                                  Container(
                                    width: 300,
                                    height: 45,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            // Change your radius here
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        //_onCancelAccountClicked(employee.id, employee.status);
                                        print('press cancel account');
                                      },
                                      child: Text(
                                        "Xóa",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white),
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
                                                  .blueAccent,
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
                                            0, 10, 0, 15),
                                        width: 340,
                                        child: StreamBuilder(
                                          //stream: informationControl,
                                          builder: (context, snapshot) =>TextField(
                                            //controller: _informationController,
                                            decoration:
                                            InputDecoration(
                                                labelText:
                                                "Email",
                                                hintText:
                                                'Nhập Email',
                                                enabledBorder:
                                                OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color:Colors.blueAccent, width:1,)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .blue,
                                                        width:
                                                        4))),
                                          ),
                                        )
                                    ),
                                    Container(
                                        margin:
                                        EdgeInsets.fromLTRB(
                                            0, 10, 0, 15),
                                        width: 340,
                                        child: StreamBuilder(
                                          //stream: informationControl,
                                          builder: (context, snapshot) =>TextField(
                                            //controller: _informationController,
                                            decoration:
                                            InputDecoration(
                                                labelText:
                                                "Tên",
                                                hintText:
                                                'Nhập tên',
                                                enabledBorder:
                                                OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color:Colors.blueAccent, width:1,)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .blue,
                                                        width:
                                                        4))),
                                          ),
                                        )
                                    ),
                                    Container(
                                        margin:
                                        EdgeInsets.fromLTRB(
                                            0, 10, 0, 15),
                                        width: 340,
                                        child: StreamBuilder(
                                          //stream: informationControl,
                                          builder: (context, snapshot) =>TextField(
                                            //controller: _informationController,
                                            decoration:
                                            InputDecoration(
                                                labelText:
                                                "Số điện thoại",
                                                hintText:
                                                'Nhập số điện thoại',
                                                enabledBorder:
                                                OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color:Colors.blueAccent, width:1,)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .blue,
                                                        width:
                                                        4))),
                                          ),
                                        )
                                    ),
                                    Container(
                                        margin:
                                        EdgeInsets.fromLTRB(
                                            0, 10, 0, 15),
                                        width: 340,
                                        child: StreamBuilder(
                                          //stream: informationControl,
                                          builder: (context, snapshot) =>TextField(
                                            //controller: _informationController,
                                            decoration:
                                            InputDecoration(
                                                labelText:
                                                "Password",
                                                hintText:
                                                'Nhập password',
                                                enabledBorder:
                                                OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color:Colors.blueAccent, width:1,)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .blue,
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
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    // Change your radius here
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                //_onAddEmployeeClicked();
                                                print('press save');
                                              },
                                              child: Text(
                                                'Lưu',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.all(10)),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    // Change your radius here
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                ),
                                              ),
                                              onPressed: () =>
                                              {Navigator.pop(context)},
                                              child: Text(
                                                'Thoát',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
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
        title: const Text("Quản lý lĩnh vực trong khoa"),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: Column(
          children: <Widget>[
            const Padding(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: Text("Khoa Công nghệ thông tin",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0))),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      //padding: EdgeInsets.only(),
                      itemCount: list_category.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildCategory(context, list_category[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: SizedBox.fromSize(
                size: Size(56, 56), // button width and height
                child: ClipOval(
                  child: Material(
                    color: Colors.blue, // button color
                    child: InkWell(
                      splashColor: Colors.green, // splash color
                      onTap: () {
                        return _modalBottomSheetAddEmployee();
                      }, // button pressed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.add), // text
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
