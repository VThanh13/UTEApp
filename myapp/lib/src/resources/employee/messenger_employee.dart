import 'dart:async';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';
import 'package:myapp/src/models/QuestionModel.dart';
import 'package:myapp/src/resources/employee/home_page_employee.dart';
import 'package:myapp/src/resources/manager/home_page_manager.dart';
import '../user/detail_question.dart';

import '../../models/ChatRoomModel.dart';
import '../../models/EmployeeModel.dart';
import '../../models/UserModel.dart';
import '../dialog/loading_dialog.dart';
import '../leader/home_page_leader.dart';
import 'detail_question_employee.dart';

class MessengerPageEmployee extends StatefulWidget {
  @override
  _MessengerPageState createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPageEmployee> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var user_auth = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel =
      new EmployeeModel("", " ", "", "", "", "", "", "", "", "");
  EmployeeModel current_employee =
      EmployeeModel("", "", "", "", "", "", "", "", "", "");
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
      setState(() {
        current_employee.id = value.docs.first['id'];
        current_employee.name = value.docs.first['name'];
        current_employee.email = value.docs.first['email'];
        current_employee.image = value.docs.first['image'];
        current_employee.password = value.docs.first['password'];
        current_employee.phone = value.docs.first['phone'];
        current_employee.department = value.docs.first['department'];
        current_employee.category = value.docs.first['category'];
        current_employee.roles = value.docs.first['roles'];
        current_employee.status = value.docs.first['status'];
      })
    });
    await getAllPublicChatRoom();
    await getUnanwseredChatRoom();
    await getAnwseredChatRoom();
  }
  List<ChatRoomModel> listPublicChatRoom = [];
  getAllPublicChatRoom() async {
    await FirebaseFirestore.instance
      .collection('chat_room')
      .where('mode', isEqualTo: 'public')
      .get()
      .then((value) => {
      setState(() {
        value.docs.forEach((element) {
          ChatRoomModel chatRoom =
          ChatRoomModel("", "", "", "", "", "", "", "", "", "");
          chatRoom.id = element['room_id'];
          chatRoom.user_id = element['user_id'];
          chatRoom.time = element['time'];
          chatRoom.title = element['title'];
          chatRoom.department = element['department'];
          chatRoom.category = element['category'];
          chatRoom.information = element['information'];
          chatRoom.group = element['group'];
          chatRoom.mode = element['mode'];
          chatRoom.status = element['status'];

          listPublicChatRoom.add(chatRoom);
        });
      })
    });
  }

  List<ChatRoomModel> listUnanwsered = [];
  getUnanwseredChatRoom() async {
    String key = "category";
    String value = current_employee.category;
    if(current_employee.roles == "Trưởng nhóm"){
      String key = "department";
      String value = current_employee.department;
    }
    await FirebaseFirestore.instance
      .collection('chat_room')
      .where(key, isEqualTo: value)
      .where('status', isEqualTo: 'Chưa trả lời')
      .get()
      .then((value) => {
        setState(() {
          value.docs.forEach((element) {
            ChatRoomModel chatRoom =
            ChatRoomModel("", "", "", "", "", "", "", "", "", "");
            chatRoom.id = element['room_id'];
            chatRoom.user_id = element['user_id'];
            chatRoom.time = element['time'];
            chatRoom.title = element['title'];
            chatRoom.department = element['department'];
            chatRoom.category = element['category'];
            chatRoom.information = element['information'];
            chatRoom.group = element['group'];
            chatRoom.mode = element['mode'];
            chatRoom.status = element['status'];

            listUnanwsered.add(chatRoom);
          });
        })
      });
  }

  List<ChatRoomModel> listAnwsered = [];
  getAnwseredChatRoom() async {
    String key = "category";
    String value = current_employee.category;
    if(current_employee.roles == "Trưởng nhóm"){
      String key = "department";
      String value = current_employee.department;
    }
    await FirebaseFirestore.instance
      .collection('chat_room')
      .where(key, isEqualTo: value)
      .where('status', isEqualTo: 'Đã trả lời')
      .get()
      .then((value) => {
        setState(() {
          value.docs.forEach((element) {
            ChatRoomModel chatRoom =
            ChatRoomModel("", "", "", "", "", "", "", "", "", "");
            chatRoom.id = element['room_id'];
            chatRoom.user_id = element['user_id'];
            chatRoom.time = element['time'];
            chatRoom.title = element['title'];
            chatRoom.department = element['department'];
            chatRoom.category = element['category'];
            chatRoom.information = element['information'];
            chatRoom.group = element['group'];
            chatRoom.mode = element['mode'];
            chatRoom.status = element['status'];

            listAnwsered.add(chatRoom);
          });
        })
      });
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("departments").get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Container(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }
          // TODO: implement build
          return Scaffold(
            appBar: new AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if(current_employee.roles=="Tư vấn viên"){
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                              new HomePageEmployee()));
                    }
                    else if(current_employee.roles=="Trưởng nhóm"){
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                              new HomePageLeader()));
                    }
                    else if(current_employee.roles=="Manager"){
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                              new HomePageManager()));
                    }
                  }
              ),
              title: const Text("Tin nhắn"),
              backgroundColor: Colors.blueAccent,
            ),
            bottomNavigationBar: getFooter(),
            body: SafeArea(
              minimum: const EdgeInsets.only(left: 20, right: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    ),
                    getQuestion(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget getQuestion() {
    if (pageIndex == 0 && current_employee.roles!="Manager") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Câu hỏi của bạn | Chưa trả lời',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0),
            ),
          ),
          _buildChatRoom(listUnanwsered)
        ],
      );
    }
    else if (pageIndex == 1 && current_employee.roles!="Manager") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Câu hỏi của bạn | Đã trả lời',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0),
            ),
          ),
          _buildChatRoom(listAnwsered)
        ],
      );
    }
    else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Tất cả câu hỏi',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0),
            ),
          ),
          _buildChatRoom(listPublicChatRoom)
        ],
      );
    }
  }

  _buildChatRoom(listChatRoom) {
    listChatRoom.sort((a, b) => DateFormat("dd-MM-yyyy HH:mm:ss")
        .parse(b.time)
        .compareTo(DateFormat("dd-MM-yyyy HH:mm:ss").parse(a.time)));

    List<Widget> chatList = [];
    listChatRoom.forEach((ChatRoomModel chatRoom) {
      chatList.add(GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      DetailQuestionEmployee(chatRoom: chatRoom)));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                width: 1.0,
                color: Colors.grey,
              )),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                    margin: const  EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          chatRoom.title,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          chatRoom.time,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(chatRoom.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: chatRoom.status == "Chưa trả lời"
                                  ? Colors.redAccent
                                  : Colors.green,
                              overflow: TextOverflow.ellipsis,
                            ))
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ));
    });
    return Column(children: chatList);
  }

  int pageIndex = 0;
  getFooter() {
    if(current_employee.roles!="Manager") {
      List<IconData> iconItems = [
        Icons.mark_email_unread_sharp,
        Icons.mark_email_read_sharp,
        Icons.question_answer_outlined,
      ];
      return AnimatedBottomNavigationBar(
        activeColor: Colors.blue,
        splashColor: Colors.grey,
        inactiveColor: Colors.black.withOpacity(0.5),
        icons: iconItems,
        activeIndex: pageIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 10,
        iconSize: 25,
        rightCornerRadius: 10,
        onTap: (index) {
          selectedTab(index);
        },
        //other params
      );
    }
  }
  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }

}
