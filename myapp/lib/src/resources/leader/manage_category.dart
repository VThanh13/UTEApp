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
  StreamController _categoryControl = new StreamController.broadcast();
  Stream get categoryControl => _categoryControl.stream;

  TextEditingController _categoryEditController = new TextEditingController();
  StreamController _categoryEditControl = new StreamController.broadcast();
  Stream get categoryEditControl => _categoryEditControl.stream;


  String? value_category;
  String departmentName = "";

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
  _buildCategory(BuildContext context, String category, index) {
    return GestureDetector(
      onTap: () {
        return _modalBottomSheetEditCategory(category, index);
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
                        child: Text(category,
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

  getListCategoy() async {
    await FirebaseFirestore.instance.collection('departments')
        .where('id', isEqualTo: current_employee.department)
        .get()
        .then((value) => {
      setState((){
        list_category = value.docs.first["category"].cast<String>();
        departmentName = value.docs.first["name"];
      })
    });
  }
  _modalBottomSheetEditCategory(String category, index) {
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
            return Container(
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                      child: Text('Chỉnh sửa lĩnh vực',
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
                            height: MediaQuery.of(context).size.height * 0.45,
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
                                        stream: categoryEditControl,
                                        builder: (context, snapshot) =>TextField(
                                          controller: _categoryEditController
                                            ..text = category,
                                          decoration:
                                          InputDecoration(
                                              labelText:
                                              "Tên lĩnh vực",
                                              hintText:
                                              'Nhập Tên lĩnh vực',
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
                                              _onChangeCategoryClicked(category, index);
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
                                        _onDeleteCategoryClicked(index);
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

  }
  _modalBottomSheetAddCategory() {
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
                        child: Text('Thêm Lĩnh vực',
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
                                          stream: categoryControl,
                                          builder: (context, snapshot) =>TextField(
                                            controller: _categoryController,
                                            decoration:
                                            InputDecoration(
                                                labelText:
                                                "Tên lĩnh vực",
                                                hintText:
                                                'Nhập Tên lĩnh vực',
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
                                                _onAddCategoryClicked();
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
  _onAddCategoryClicked(){
    String category = _categoryController.text;
    list_category.add(category);
    if(category != null && category.length != 0){
      FirebaseFirestore.instance.collection('departments')
          .doc(current_employee.department)
          .update({"category": FieldValue.arrayUnion(list_category)});
    }
  }
  _onChangeCategoryClicked(category, index){
    list_category[index] = _categoryEditController.text;
    FirebaseFirestore.instance.collection('departments')
        .doc(current_employee.department)
        .update({"category": FieldValue.arrayUnion(list_category)});
  }
  _onDeleteCategoryClicked(index){
    list_category.removeAt(index);
    FirebaseFirestore.instance.collection('departments')
          .doc(current_employee.department)
          .update({"category": FieldValue.arrayUnion(list_category)});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        title: const Text("Quản lý lĩnh vực trong khoa"),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _modalBottomSheetAddCategory();
          },
          child: Icon(
            Icons.add,
            size: 25,
          ),
          backgroundColor: Colors.blue
        //params
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                child: Text(departmentName,
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
                      itemCount: list_category.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildCategory(context, list_category[index], index);
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
