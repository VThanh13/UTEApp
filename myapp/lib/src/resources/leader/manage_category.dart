import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../blocs/auth_bloc.dart';
import '../../models/EmployeeModel.dart';
import 'home_page_leader.dart';

class ManageCategory extends StatefulWidget {
  const ManageCategory({super.key});

  @override
  State<ManageCategory> createState() => _ManageCategoryState();
}

class _ManageCategoryState extends State<ManageCategory> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  var userAuth = FirebaseAuth.instance.currentUser!;
  AuthBloc authBloc = AuthBloc();
  EmployeeModel currentEmployee = EmployeeModel();
  List<String> listCategory = [];

  final TextEditingController _categoryController = TextEditingController();
  final StreamController _categoryControl = StreamController.broadcast();
  Stream get categoryControl => _categoryControl.stream;

  final TextEditingController _categoryEditController = TextEditingController();
  final StreamController _categoryEditControl = StreamController.broadcast();
  Stream get categoryEditControl => _categoryEditControl.stream;

  String? valueCategory;
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
      .where('id', isEqualTo: userAuth.uid)
      .get()
      .then((value) => {
        setState(() {
          currentEmployee.id = value.docs.first['id'];
          currentEmployee.name = value.docs.first['name'];
          currentEmployee.email = value.docs.first['email'];
          currentEmployee.image = value.docs.first['image'];
          currentEmployee.password = value.docs.first['password'];
          currentEmployee.phone = value.docs.first['phone'];
          currentEmployee.department = value.docs.first['department'];
          currentEmployee.category = value.docs.first['category'].cast<String>();
          currentEmployee.roles = value.docs.first['roles'];
          currentEmployee.status = value.docs.first['status'];
        })
      });

    await getListCategory();
  }

  _buildCategory(BuildContext context, String category, index) {
    return GestureDetector(
      onTap: () {
        // ignore: void_checks
        return _modalBottomSheetEditCategory(category, index);
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
                      child: Text(category,
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

  getListCategory() async {
    await FirebaseFirestore.instance
      .collection('departments')
      .where('id', isEqualTo: currentEmployee.department)
      .get()
      .then((value) => {
        setState(() {
          listCategory = value.docs.first["category"].cast<String>();
          departmentName = value.docs.first["name"];
        })
      });
  }

  _modalBottomSheetEditCategory(String category, index) {
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
          return Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
                child: Text(
                  'Chỉnh sửa lĩnh vực',
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
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
                            Container(
                                margin: const EdgeInsets.fromLTRB(10, 10, 10, 15),
                                width: 400,
                                child: StreamBuilder(
                                  stream: categoryEditControl,
                                  builder: (context, snapshot) => TextField(
                                    controller: _categoryEditController
                                      ..text = category,
                                    decoration: InputDecoration(
                                        labelText: "Tên lĩnh vực",
                                        hintText: 'Nhập Tên lĩnh vực',
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
                                        _onChangeCategoryClicked(
                                            category, index);
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
                                      icon: const Icon(Icons.cancel),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(5)),
                            SizedBox(
                              width: 300,
                              height: 45,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      // Change your radius here
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  _onDeleteCategoryClicked(index);
                                },
                                child: const Text(
                                  "Xóa",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
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
          );
        });
  }

  _modalBottomSheetAddCategory() {
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
                    'Thêm Lĩnh vực',
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
                                    stream: categoryControl,
                                    builder: (context, snapshot) => TextField(
                                      controller: _categoryController,
                                      decoration: InputDecoration(
                                          labelText: "Tên lĩnh vực",
                                          hintText: 'Nhập Tên lĩnh vực',
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
                                          _onAddCategoryClicked();
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

  _onAddCategoryClicked() {
    String category = _categoryController.text;
    listCategory.add(category);
    if (category.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('departments')
          .doc(currentEmployee.department)
          .update({"category": FieldValue.arrayUnion(listCategory)});
    }
  }

  _onChangeCategoryClicked(category, index) {
    listCategory[index] = _categoryEditController.text;
    FirebaseFirestore.instance
        .collection('departments')
        .doc(currentEmployee.department)
        .update({"category": FieldValue.arrayUnion(listCategory)});
  }

  _onDeleteCategoryClicked(index) {
    listCategory.removeAt(index);
    FirebaseFirestore.instance
        .collection('departments')
        .doc(currentEmployee.department)
        .update({"category": FieldValue.arrayUnion(listCategory)});
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
        title: const Text("Quản lý lĩnh vực trong khoa"),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _modalBottomSheetAddCategory();
          },
          backgroundColor: Colors.blue,
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
            Padding(
                padding: const EdgeInsets.fromLTRB(5, 20, 5, 10),
                child: Text(departmentName,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0))),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.78,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      //padding: EdgeInsets.only(),
                      itemCount: listCategory.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildCategory(
                            context, listCategory[index], index);
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
