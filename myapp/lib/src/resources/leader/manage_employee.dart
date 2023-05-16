import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

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

  bool status = false;

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
        _modalBottomSheetEditEmployee(employee);
      },
      child: Card(
        child: Row(
          children: <Widget>[
            const Padding(padding: EdgeInsets.fromLTRB(10, 15, 5, 15)),
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.tealAccent,
              child: CircleAvatar(
                backgroundImage: NetworkImage(employee.image!),
                radius: 26,
              ),
            ),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        padding: const EdgeInsets.fromLTRB(10, 15, 0, 5),
                        child: Text(employee.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ))),
                    Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 20),
                        child: Text(
                          employee.status == "enabled" ? "Active" : "Inactive",
                          style: TextStyle(
                              color: employee.status == "enabled"
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 14,
                              fontStyle: FontStyle.italic),
                          textAlign: TextAlign.left,
                        )),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: const Icon(
                    Icons.edit_note,
                    size: 30,
                  ),
                )
              ],
            ))
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
                  padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
                  child: Text(
                    'Employee Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
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
                                height: 110,
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
                              Text(
                                employee.name!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                employee.roles!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              Container(
                                height: 180,
                                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Colors.grey[200]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Change category',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            10, 10, 10, 15),
                                        width: 400,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.blueAccent,
                                              width: 4),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                            isExpanded: true,
                                            value: valueCategory,
                                            hint: const Text(
                                                "Please choose category"),
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
                                                  valueCategory =
                                                      selectedCategory;
                                                });
                                              });
                                            },
                                          ),
                                        )),
                                    Container(
                                      height: 50,
                                      padding: const EdgeInsets.fromLTRB(
                                          40, 0, 40, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              style: ButtonStyle(
                                                  shape:
                                                      MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      // Change your radius here
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              13),
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.blueAccent)),
                                              onPressed: () {
                                                try{
                                                  if(_onChangeCategoryClicked(
                                                      employee.id, valueCategory)){

                                                  }else{
                                                    Navigator.pop(context);
                                                    showErrorMessage('Update failed');
                                                  }
                                                }catch(e){
                                                  //
                                                }
                                              },
                                              label: const Text(
                                                'Save',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                              icon: const Icon(
                                                  Icons.save_outlined),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Padding(padding: EdgeInsets.all(5)),
                              Container(
                                height: 110,
                                width: double.infinity,
                                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 250,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Change status account',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(top: 5)),
                                          Expanded(
                                              child: Text(
                                            'You can change status for your partner account.'
                                            'If status is Active, your partner can use app for work.'
                                            'If status is Inactive, your partner can\'t login App.'
                                            'You can change between Active and Inactive!',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 50,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FlutterSwitch(
                                              value:
                                                  employee.status == 'enabled'
                                                      ? status = true
                                                      : false,
                                              onToggle: (val) {
                                                try{
                                                  if(_onCancelAccountClicked(
                                                      employee.id,
                                                      employee.status)){
                                                  }else{
                                                    Navigator.pop(context);
                                                    showErrorMessage('Update failed');
                                                  }
                                                }catch(e){
                                                  //
                                                }
                                              }),
                                          Text(
                                            employee.status == 'enabled'
                                                ? 'Active'
                                                : 'Inactive',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color:
                                                  employee.status == "enabled"
                                                      ? Colors.blue
                                                      : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 125,
                                width: double.infinity,
                                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Reset password',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 5)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: StreamBuilder(
                                          stream: newPasswordControl,
                                          builder: (context, snapshot) =>
                                              TextField(
                                                controller: _newPasswordController,
                                                decoration: InputDecoration(
                                                  labelText: "Password",
                                                  hintText: 'Insert password',
                                                  errorText: snapshot.hasError? snapshot.error.toString() : null,
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      borderSide: const BorderSide(
                                                        color: Colors.blueAccent,
                                                        width: 1,
                                                      )),
                                                ),
                                              ),
                                        ),),
                                        const Padding(padding: EdgeInsets.only(left: 10)),
                                        InkWell(
                                          onTap: (){
                                            try{
                                              if(_onChangePasswordClicked(employee)){
                                                setState(() {
                                                  _newPasswordController.text = '';
                                                });
                                              }else{
                                                setState(() {
                                                  _newPasswordController.text = '';
                                                });
                                                Navigator.pop(context);
                                                showErrorMessage('Change password failed');
                                              }
                                            }catch(e){
                                              //
                                            }
                                          },
                                          child: const Icon(Icons.check_circle_outline,
                                          size: 30,
                                          color: Colors.blue,),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
                              const Divider(
                                color: Colors.black,
                                height: 5.0,
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

  bool isValidChangePass(String password) {
    if (password.isEmpty) {
      _newPasswordControl.sink.addError("Insert password");
      return false;
    }
    _newPasswordControl.sink.add('');

    if (password.length < 6) {
      _newPasswordControl.sink.addError("Password must be 6 or more characters");
      return false;
    }
    _newPasswordControl.sink.add('');

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
        showSuccessMessage('Change password success');
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
                    'Add new partner',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,),
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
                                margin:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.blueAccent, width: 3),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    value: valueCategory,
                                    hint: const Text(
                                        "Please choose category"),
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
                                      const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                  width: double.infinity,
                                  child: StreamBuilder(
                                    stream: emailControl,
                                    builder: (context, snapshot) => TextField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                          labelText: "Email",
                                          hintText: 'Insert Email',
                                          errorText: snapshot.hasError? snapshot.error.toString() : null,
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
                                                  width: 3))),
                                    ),
                                  )),
                              Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                  width: double.infinity,
                                  child: StreamBuilder(
                                    stream: nameControl,
                                    builder: (context, snapshot) => TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                          labelText: "Name",
                                          hintText: 'Insert name',
                                          errorText: snapshot.hasError? snapshot.error.toString() : null,
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
                                                  width: 3))),
                                    ),
                                  )),
                              Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                  width: double.infinity,
                                  child: StreamBuilder(
                                    stream: phoneControl,
                                    builder: (context, snapshot) => TextField(
                                      controller: _phoneController,
                                      decoration: InputDecoration(
                                          labelText: "Phone number",
                                          hintText: 'Insert phone number',
                                          errorText: snapshot.hasError? snapshot.error.toString() : null,
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
                                                  width: 3))),
                                    ),
                                  )),
                              Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                  width: double.infinity,
                                  child: StreamBuilder(
                                    stream: passwordControl,
                                    builder: (context, snapshot) => TextField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                          labelText: "Password",
                                          hintText: 'Insert password',
                                          errorText: snapshot.hasError? snapshot.error.toString() : null,
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
                                                  width: 3))),
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
                                                  Colors.blueAccent),
                                        ),
                                        onPressed: () {
                                          try{
                                            if(_onAddEmployeeClicked()){
                                              setState(() {
                                                _emailController.text = '';
                                                _phoneController.text = '';
                                                _nameController.text = '';
                                                _passwordController.text = '';
                                              });
                                            }else{
                                              setState(() {
                                                _emailController.text = '';
                                                _phoneController.text = '';
                                                _nameController.text = '';
                                                _passwordController.text = '';
                                              });
                                              Navigator.pop(context);
                                              showErrorMessage('Create failed');
                                            }
                                          }catch(e){
                                            //
                                          }
                                        },
                                        label: const Text(
                                          'Save',
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
                                                  Colors.blueAccent),
                                        ),
                                        onPressed: () =>
                                            {Navigator.pop(context)},
                                        label: const Text(
                                          'Cancel',
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
      showSuccessMessage('Update success');
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
      showSuccessMessage('Update success');
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
        showSuccessMessage('Create success');
      }, (msg) {
        LoadingDialog.hideLoadingDialog(context);
        MsgDialog.showMsgDialog(context, "Sign-In", msg);
      });
    }
  }

  bool isValid(String email, String name, String phone, String password) {
    if (email.isEmpty) {
      _emailControl.sink.addError("Insert email");
      return false;
    }
    _emailControl.sink.add('');

    if (name.isEmpty) {
      _nameControl.sink.addError("Nhập tên");
      return false;
    }
    _nameControl.sink.add('');

    if (phone.isEmpty) {
      _phoneControl.sink.addError("Nhập số điện thoại");
      return false;
    }
    _phoneControl.sink.add('');

    if (password.isEmpty) {
      _passwordControl.sink.addError("Nhập mật khẩu");
      return false;
    }
    _passwordControl.sink.add('');
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
                      builder: (BuildContext context) =>
                          const HomePageLeader()));
            }),
        title: const Text("Manage employee"),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _modalBottomSheetAddEmployee();
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
        minimum: const EdgeInsets.only(left: 20, right: 10, top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
              child: Text(
                'Your team partner',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic),
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
  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message,
      style: const TextStyle(color: Colors.white),
    ), backgroundColor: Colors.blueAccent,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(content: Text(message,
      style: const TextStyle(color: Colors.white),
    ),backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
