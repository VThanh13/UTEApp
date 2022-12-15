import 'dart:async';

import 'package:intl/intl.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/resources/about_page/my_file.dart';
import 'package:myapp/src/resources/about_page/about_university.dart';
import 'package:myapp/src/resources/about_page/admission_history.dart';
import 'package:myapp/src/resources/login_page.dart';
import 'package:myapp/src/resources/messenger/test.dart';
import 'package:myapp/src/models/EmployeeModel.dart';
import 'package:myapp/src/screens/signin_screen.dart';

import '../../models/NewfeedModel.dart';
import '../employee/employee_info.dart';
import '../dialog/loading_dialog.dart';
import 'manage_category.dart';
import 'manage_employee.dart';
import 'messenger_leader.dart';

class HomePageLeader extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageLeader> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userr = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel = new EmployeeModel("", " ", "", "", "", "", "", "", "", "");

  @override
  void dispose() {
    _infoPostControll.close();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    getNewfeedData();
  }

  TextEditingController _infoPostController = new TextEditingController();

  StreamController _infoPostControll = new StreamController.broadcast();

  Stream get infoPostControll => _infoPostControll.stream;

  bool isvalidContent(String content){
    if(content == null || content.length ==0){
      _infoPostControll.sink.addError("Nhập nội dung");
      return false;
    }
    return true;
  }

  void createNewPost(
       String employeeId, String content, String time, String file, Function onSuccess
      ){
    var ref = FirebaseFirestore.instance.collection('newfeed');
    String id = ref.doc().id;
    ref.doc(id).set({
      'id': id,
      'employeeId': employeeId,
      'content': content,
      'time': time,
      'file': file,
    }).then((value) {
      onSuccess();
      print('add post nice');
    }).catchError((err){
      print(err);
    });
  }

  _onCreateNewPost(){
    var isvalidcontent = isvalidContent(_infoPostController.text);
    var time = DateTime.now();
    String timestring = DateFormat('dd-MM-yyyy HH:mm:ss').format(time);
    print(timestring);

    if(isvalidcontent){
      LoadingDialog.showLoadingDialog(context, "loading...");
      createNewPost( employeeModel.id, _infoPostController.text , timestring, "file.pdf", (){
        LoadingDialog.hideLoadingDialog(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePageLeader()));
      });

    }
    return 0;
  }
  
  List<NewfeedModel> listNewfeed = [];
  getNewfeedData() async{
    await FirebaseFirestore.instance.collection('newfeed').get().then((value){
      value.docs.forEach((element) {
        NewfeedModel nModel = new NewfeedModel("", "", "", "", "");
        nModel.id = element['id'];
        nModel.employeeId= element['employeeId'];
        nModel.content= element['content'];
        nModel.time = element['time'];
        nModel.file = element['file'];

        listNewfeed.add(nModel);
      });
    });
  }


  _buildNewfeed(BuildContext context, NewfeedModel newfeedModel){
    return Container(
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(width: 1.0, color: Colors.pinkAccent)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.tealAccent,
              child: CircleAvatar(
                backgroundImage: new NetworkImage(employeeModel.image!),
                radius: 28,
              ),

            )  ,
            
          ),
          Text(newfeedModel.time)
        ],
      ),
    );

  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("employee")
            .where("id", isEqualTo: userr.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Container(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator()),
            );
          }
          snapshot.data!.docs.map((e) {
            employeeModel.id = (e.data() as Map)['id'];
            employeeModel.name = (e.data() as Map)['name'];
            employeeModel.email = (e.data() as Map)['email'];
            employeeModel.image = (e.data() as Map)['image'];
            employeeModel.password = (e.data() as Map)['password'];
            employeeModel.phone = (e.data() as Map)['phone'];
            employeeModel.department = (e.data() as Map)['department'];
            employeeModel.category = (e.data() as Map)['category'];
            employeeModel.roles = (e.data() as Map)['roles'];
            employeeModel.status = (e.data() as Map)['status'];

            return employeeModel;

          }).toString();
          
          


          // TODO: implement build
          return Scaffold(
            appBar: new AppBar(
              title: new Text("UTE APP"),
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  MessengerPageLeader()));
                    },
                    icon: Icon(
                      AppIcons.chat,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => TestPage()));
                    },
                    icon: Icon(
                      AppIcons.bell_alt,
                      color: Colors.white,
                    ))
              ],
            ),
            drawer: new Drawer(
              child: ListView(
                children: <Widget>[
                  new UserAccountsDrawerHeader(
                    accountName: new Text(employeeModel.name!),
                    accountEmail: new Text(employeeModel.email!),
                    currentAccountPicture: new CircleAvatar(
                      backgroundImage:
                          new NetworkImage(employeeModel.image!),
                    ),
                  ),
                  new ListTile(
                    title: new Text('Thông tin cá nhân trưởng nhóm'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => new EmployeeInfo()));
                    },
                  ),
                  new Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  new ListTile(
                    title: new Text('Giới thiệu về trường'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new AboutUniversity()));
                    },
                  ),
                  new Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  new ListTile(
                    title: new Text('Lịch sử tuyển sinh'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new AdmissionHistory()));
                    },
                  ),
                  new Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  new ListTile(
                    title: new Text('Hồ sơ của bạn'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => new MyFile()));
                    },
                  ),
                  new Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  new ListTile(
                    title: new Text('Quản lý Tư vấn viên'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => new ManageEmployee()));
                    },
                  ),
                  new Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  new ListTile(
                    title: new Text('Quản lý Lĩnh vực'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => new ManageCategory()));
                    },
                  ),
                  new Divider(
                    color: Colors.black,
                    height: 5.0,
                  ),
                  new ListTile(
                    title: new Text('Đăng xuất'),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new LoginPage()));
                    },
                  ),
                ],
              ),
            ),
            body: SafeArea(
              minimum: const EdgeInsets.only(left: 10, right: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.black54)

                      ),
                      child:  SizedBox(
                        width: double.infinity,
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                              child: Container(
                                height: 80,
                                child: Center(
                                  child: Stack(
                                    children: [
                                      new CircleAvatar(
                                        radius: 32,
                                        backgroundColor: Colors.tealAccent,
                                        child: CircleAvatar(
                                          backgroundImage:
                                          new NetworkImage(employeeModel.image),
                                          radius: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 70,
                              width: 240,
                              child: ElevatedButton.icon(
                                onPressed: (){
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                    ),
                                    context: context,
                                    builder: (BuildContext context){
                                      return Container(
                                        height: 450,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 20)),
                                              Text("Thêm bài đăng mới",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 20,
                                                  fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),),

                                              Container(
                                                width: 340,
                                                margin:
                                                EdgeInsets.fromLTRB(0, 10, 0, 15),
                                                child: StreamBuilder(
                                                  stream: infoPostControll,
                                                  builder: (context, snapshot) =>
                                                      TextField(
                                                        controller: _infoPostController,
                                                        maxLines: 10,
                                                        maxLength: 500,
                                                        decoration: InputDecoration(
                                                            hintMaxLines: 5,
                                                            helperMaxLines: 5,
                                                            labelText: "Nội dung bài đăng",
                                                            hintText:
                                                            'Nhập nội dung bài đăng của bạn',
                                                            enabledBorder:
                                                            OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(10),
                                                                borderSide: BorderSide(
                                                                  color:
                                                                  Colors.orangeAccent,
                                                                  width: 1,
                                                                )),
                                                            focusedBorder:
                                                            OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(10),
                                                                borderSide: BorderSide(
                                                                    color: Colors.orange,
                                                                    width: 4))),
                                                      ),
                                                ),
                                              ),

                                              Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton.icon(

                                                        onPressed: () {
                                                          _onCreateNewPost();
                                                          print('press save');
                                                        },
                                                        label: Text(
                                                          'Đăng',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.white),
                                                        ),
                                                        icon: Icon(Icons.task_alt),
                                                        style: ElevatedButton.styleFrom(
                                                            primary: Colors.orangeAccent
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.all(10)),
                                                    Expanded(
                                                        child: ElevatedButton.icon(
                                                          onPressed: () => {
                                                            Navigator.pop(context)
                                                          },
                                                          label: Text(
                                                            'Hủy',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors.white),
                                                          ),
                                                          icon: Icon(Icons.cancel_presentation),
                                                          style: ElevatedButton.styleFrom(
                                                              primary: Colors.orangeAccent
                                                          ),
                                                        )),
                                                    Padding(
                                                        padding: EdgeInsets.fromLTRB(
                                                            0, 10, 0, 30)),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  );

                                },
                                icon: Icon(Icons.add_card, color: Colors.black87,),
                                label: Text("Thêm bài đăng mới", style: TextStyle(fontSize: 17, color: Colors.black87, fontStyle: FontStyle.italic), textAlign: TextAlign.start,),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.white70
                                ),
                              ),
                            ),




                          ],
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          //height: MediaQuery.of(context).size.height * 0.65,
                    height: 300,
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                              itemCount: listNewfeed.length,
                              itemBuilder: (BuildContext context, int index){
                            return _buildNewfeed(context, listNewfeed[index]);

                          }),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
