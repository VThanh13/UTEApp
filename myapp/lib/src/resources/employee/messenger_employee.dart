// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/resources/employee/home_page_employee.dart';
import 'package:myapp/src/resources/manager/home_page_manager.dart';

import '../../../icons/app_icons_icons.dart';
import '../../models/ChatRoomModel.dart';
import '../../models/EmployeeModel.dart';
import '../leader/home_page_leader.dart';
import 'detail_question_employee.dart';

class MessengerPageEmployee extends StatefulWidget {
  const MessengerPageEmployee({super.key});

  @override
  State<MessengerPageEmployee> createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPageEmployee> with SingleTickerProviderStateMixin {
  FirebaseAuth auth = FirebaseAuth.instance;
  var userAuth = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel = EmployeeModel();
  EmployeeModel currentEmployee = EmployeeModel();
  late TabController _tabController;
  List listTabItems = [
    'All questions',
    'Answered questions',
    'Unanswered questions',
    'Your messages',
  ];
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _tabController = TabController(length: listTabItems.length, vsync: this);
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
    await getAllPublicChatRoom();
    await getAllPrivateChatRoom();
    await getUnanwseredChatRoom();
    await getAnwseredChatRoom();
    await getYourMessage();
    await getYourChatRoom();
  }
  List<ChatRoomModel> listPublicChatRoom = [];
  getAllPublicChatRoom() async {
    await FirebaseFirestore.instance
      .collection('chat_room')
      .where('mode', isEqualTo: 'public')
      .get()
      .then((value) => {
      setState(() {
        for (var element in value.docs) {
          ChatRoomModel chatRoom = ChatRoomModel();
          chatRoom.id = element['room_id'];
          chatRoom.userId = element['user_id'];
          chatRoom.time = element['time'];
          chatRoom.title = element['title'];
          chatRoom.department = element['department'];
          chatRoom.category = element['category'];
          chatRoom.information = element['information'];
          chatRoom.group = element['group'];
          chatRoom.mode = element['mode'];
          chatRoom.status = element['status'];

          listPublicChatRoom.add(chatRoom);
        }
      })
    });
  }

  List<ChatRoomModel> listPrivateChatRoom = [];
  getAllPrivateChatRoom() async {
    await FirebaseFirestore.instance
      .collection('chat_room')
      .where('mode', isEqualTo: 'private')
      .get()
      .then((value) => {
      setState(() {
        for (var element in value.docs) {
          ChatRoomModel chatRoom = ChatRoomModel();
          chatRoom.id = element['room_id'];
          chatRoom.userId = element['user_id'];
          chatRoom.time = element['time'];
          chatRoom.title = element['title'];
          chatRoom.department = element['department'];
          chatRoom.category = element['category'];
          chatRoom.information = element['information'];
          chatRoom.group = element['group'];
          chatRoom.mode = element['mode'];
          chatRoom.status = element['status'];

          listPrivateChatRoom.add(chatRoom);
        }
      })
    });
  }

  List<ChatRoomModel> listUnAnswered = [];
  getUnanwseredChatRoom() async {
    String key = "category";
    List<String> values = currentEmployee.category!;
    if(currentEmployee.roles == "Trưởng nhóm"){
      key = "department";
      values.add(currentEmployee.department!);
    }
    await FirebaseFirestore.instance
      .collection('chat_room')
      .where(key, whereIn: values)
      .where('status', isEqualTo: 'Chưa trả lời')
      .get()
      .then((value) => {
        setState(() {
          for (var element in value.docs) {
            ChatRoomModel chatRoom = ChatRoomModel();
            chatRoom.id = element['room_id'];
            chatRoom.userId = element['user_id'];
            chatRoom.time = element['time'];
            chatRoom.title = element['title'];
            chatRoom.department = element['department'];
            chatRoom.category = element['category'];
            chatRoom.information = element['information'];
            chatRoom.group = element['group'];
            chatRoom.mode = element['mode'];
            chatRoom.status = element['status'];

            listUnAnswered.add(chatRoom);
          }
        })
      });
  }

  List<ChatRoomModel> listAnwsered = [];
  getAnwseredChatRoom() async {
    String key = "category";
    List<String> values = currentEmployee.category!;
    if(currentEmployee.roles == "Trưởng nhóm"){
      key = "department";
      values.add(currentEmployee.department!);
    }
    await FirebaseFirestore.instance
      .collection('chat_room')
      .where(key, whereIn: values)
      .where('status', isEqualTo: 'Đã trả lời')
      .get()
      .then((value) => {
        setState(() {
          for (var element in value.docs) {
            ChatRoomModel chatRoom = ChatRoomModel();
            chatRoom.id = element['room_id'];
            chatRoom.userId = element['user_id'];
            chatRoom.time = element['time'];
            chatRoom.title = element['title'];
            chatRoom.department = element['department'];
            chatRoom.category = element['category'];
            chatRoom.information = element['information'];
            chatRoom.group = element['group'];
            chatRoom.mode = element['mode'];
            chatRoom.status = element['status'];

            listAnwsered.add(chatRoom);
          }
        })
      });
  }

  List<ChatRoomModel> listYourChatRoom = [];
  getYourChatRoom() async {
    await FirebaseFirestore.instance
        .collection('chat_room')
        .where("department", isEqualTo: currentEmployee.department!)
        .get()
        .then((value) => {
      setState(() {
        for (var element in value.docs) {
          ChatRoomModel chatRoom = ChatRoomModel();
          chatRoom.id = element['room_id'];
          chatRoom.userId = element['user_id'];
          chatRoom.time = element['time'];
          chatRoom.title = element['title'];
          chatRoom.department = element['department'];
          chatRoom.category = element['category'];
          chatRoom.information = element['information'];
          chatRoom.group = element['group'];
          chatRoom.mode = element['mode'];
          chatRoom.status = element['status'];

          listYourChatRoom.add(chatRoom);
        }
      })
    });
  }

  List<ChatRoomModel> listYourMessage = [];
  getYourMessage() async {
    await FirebaseFirestore.instance
        .collection('chat_room')
        .where("category", isEqualTo: currentEmployee.id!)
        .get()
        .then((value) => {
      setState(() {
        for (var element in value.docs) {
          ChatRoomModel chatRoom = ChatRoomModel();
          chatRoom.id = element['room_id'];
          chatRoom.userId = element['user_id'];
          chatRoom.time = element['time'];
          chatRoom.title = element['title'];
          chatRoom.department = element['department'];
          chatRoom.category = element['category'];
          chatRoom.information = element['information'];
          chatRoom.group = element['group'];
          chatRoom.mode = element['mode'];
          chatRoom.status = element['status'];

          listYourMessage.add(chatRoom);
        }
      })
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("departments").get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator()),
            );
          }
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if(currentEmployee.roles=="Tư vấn viên"){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                              const HomePageEmployee()));
                    }
                    else if(currentEmployee.roles=="Trưởng nhóm"){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                              const HomePageLeader()));
                    }
                    else if(currentEmployee.roles=="Manager"){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                              const HomePageManager()));
                    }
                  }
              ),
              title: const Text("Message"),
              backgroundColor: Colors.blueAccent,
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.mark_email_unread_sharp),
                  label: 'Your questions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.mark_email_read_sharp),
                  label: 'Private',
                ),
                BottomNavigationBarItem(
                  icon: Icon(AppIcons.chat),
                  label: 'Public',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              // gapLocation: GapLocation.center,
              onTap:  _onItemTapped,
            ),
            body: [
              Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                ),
                SizedBox(
                  height: 48,
                  width: double.maxFinite,
                  child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.blue,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 3,
                      ),
                    ),
                    tabs: [
                      ...List.generate(
                        listTabItems.length,
                            (index) {
                          return Tab(
                            text: listTabItems[index],

                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      child: _buildChatRoom(listYourChatRoom),
                    ),
                    SingleChildScrollView(
                      child: _buildChatRoom(listAnwsered),
                    ),
                    SingleChildScrollView(
                      child: _buildChatRoom(listUnAnswered),
                    ),
                    SingleChildScrollView(
                      child: _buildChatRoom(listYourMessage),
                    ),
                  ],
                ),),

              ],
            ),
              SingleChildScrollView(
                child: _buildChatRoom(listPrivateChatRoom),
              ),
              SingleChildScrollView(
                child: _buildChatRoom(listPublicChatRoom),
              )].elementAt(_selectedIndex),
          );
        });
  }

  Widget getQuestion() {
    if (pageIndex == 0 && currentEmployee.roles!="Manager") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 40,
            child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Your questions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent,
                            letterSpacing: 1.0),
                      ),
                  ),
                ]
            ),
          ),
          _popUpMenu(),
          if(selectedMenu == "All questions")
            _buildChatRoom(listYourChatRoom)
          else if(selectedMenu == "Answered questions")
            _buildChatRoom(listAnwsered)
          else if(selectedMenu == "Unanswered questions")
              _buildChatRoom(listUnAnswered)
          else
              _buildChatRoom(listYourMessage)
        ],
      );
    }
    else if (pageIndex == 1 && currentEmployee.roles!="Manager") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 40,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Private questions',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                    letterSpacing: 1.0),
              ),
            ),
          ),
          _buildChatRoom(listPrivateChatRoom)
        ],
      );
    }
    else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 40,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Public questions',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                    letterSpacing: 1.0),
              ),
            ),
          ),
          _buildChatRoom(listPublicChatRoom)
        ],
      );
    }
  }

  String selectedMenu = "All questions";
  _popUpMenu(){
    return PopupMenuButton<String>(
      initialValue: selectedMenu,
      // Callback that sets the selected popup menu item.
      onSelected: (String item) {
        setState(() {
          selectedMenu = item;
        });
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: "All questions",
          child: Text('All questions'),
        ),
        const PopupMenuItem<String>(
          value: "Answered questions",
          child: Text('Answered questions'),
        ),
        const PopupMenuItem<String>(
          value: "Unanswered questions",
          child: Text('Unanswered questions'),
        ),
        const PopupMenuItem<String>(
          value: "Your messages",
          child: Text('Your messages'),
        ),
      ],
    );
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
        child: Column(
          children: [
            SizedBox(
              key: UniqueKey(),

              child: Container(
                //margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                height: 75,

                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                          margin: const  EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                chatRoom.title!,
                                style: const TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 4.0,
                              ),
                              Text('From: ${chatRoom.group}',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),),
                              Text(
                                chatRoom.time!,
                                style: const TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(chatRoom.status!,
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
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5),
              child: Divider(
                height: 0,
                color: Colors.blue,
                indent: 0,
                thickness: 1,
              ),
            ),
          ],
        ),
      ));
    });
    return Column(children: chatList);
  }

  int pageIndex = 0;
  getFooter() {
    if(currentEmployee.roles!="Manager") {
      return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_email_unread_sharp),
            label: 'Your questions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_email_read_sharp),
            label: 'Private',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.chat),
            label: 'Public',
          ),
        ],
        currentIndex: pageIndex,
        selectedItemColor: Colors.blue,
        // gapLocation: GapLocation.center,
        onTap: (index) {
          selectedTab(index);
        },
      );
    }
  }
  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }
}


