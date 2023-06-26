import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
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
  var user_auth = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel = EmployeeModel();
  EmployeeModel current_employee = EmployeeModel();
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
        current_employee.category = value.docs.first['category'].cast<String>();
        current_employee.roles = value.docs.first['roles'];
        current_employee.status = value.docs.first['status'];
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
        value.docs.forEach((element) {
          ChatRoomModel chatRoom = ChatRoomModel();
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

  List<ChatRoomModel> listPrivateChatRoom = [];
  getAllPrivateChatRoom() async {
    await FirebaseFirestore.instance
      .collection('chat_room')
      .where('mode', isEqualTo: 'private')
      .get()
      .then((value) => {
      setState(() {
        value.docs.forEach((element) {
          ChatRoomModel chatRoom = ChatRoomModel();
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

          listPrivateChatRoom.add(chatRoom);
        });
      })
    });
  }

  List<ChatRoomModel> listUnanwsered = [];
  getUnanwseredChatRoom() async {
    String key = "category";
    List<String> values = current_employee.category!;
    if(current_employee.roles == "Trưởng nhóm"){
      key = "department";
      values.add(current_employee.department!);
    }
    await FirebaseFirestore.instance
      .collection('chat_room')
      .where(key, whereIn: values)
      .where('status', isEqualTo: 'Chưa trả lời')
      .get()
      .then((value) => {
        setState(() {
          value.docs.forEach((element) {
            ChatRoomModel chatRoom = ChatRoomModel();
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
    List<String> values = current_employee.category!;
    if(current_employee.roles == "Trưởng nhóm"){
      key = "department";
      values.add(current_employee.department!);
    }
    await FirebaseFirestore.instance
      .collection('chat_room')
      .where(key, whereIn: values)
      .where('status', isEqualTo: 'Đã trả lời')
      .get()
      .then((value) => {
        setState(() {
          value.docs.forEach((element) {
            ChatRoomModel chatRoom = ChatRoomModel();
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

  List<ChatRoomModel> listYourChatRoom = [];
  getYourChatRoom() async {
    listYourChatRoom = listYourMessage + listAnwsered + listUnanwsered;
  }

  List<ChatRoomModel> listYourMessage = [];
  getYourMessage() async {
    await FirebaseFirestore.instance
        .collection('chat_room')
        .where("category", isEqualTo: current_employee.id!)
        .get()
        .then((value) => {
      setState(() {
        value.docs.forEach((element) {
          ChatRoomModel chatRoom = ChatRoomModel();
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

          listYourMessage.add(chatRoom);
        });
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
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if(current_employee.roles=="Tư vấn viên"){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                              const HomePageEmployee()));
                    }
                    else if(current_employee.roles=="Trưởng nhóm"){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                              const HomePageLeader()));
                    }
                    else if(current_employee.roles=="Manager"){
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
                    labelColor: const Color(0xffDD4A30),
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: Color(0xffDD4A30),
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
                      child: _buildChatRoom(listUnanwsered),
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
    if (pageIndex == 0 && current_employee.roles!="Manager") {
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
              _buildChatRoom(listUnanwsered)
          else
              _buildChatRoom(listYourMessage)
        ],
      );
    }
    else if (pageIndex == 1 && current_employee.roles!="Manager") {
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
        child: Card(
          color: Colors.grey[200],
          child: Container(
            //margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            height: 90,

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
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
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
                              fontSize: 14.0,
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
        AppIcons.chat,
      ];
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


