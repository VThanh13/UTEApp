

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';

import '../../models/UserModel.dart';

class MessengerPage extends StatefulWidget {
  @override
  _MessengerPageState createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  CollectionReference derpart = FirebaseFirestore.instance.collection('departments');
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? value;
  String? value_khoa;
  String? value4;
  var selectedDerpartments;
  String? value2;
  String? value_doituong;
  String? value_vande;
  var departmentsItems =[];
  var items = ['Khoa Công nghệ thông tin',
                'Khoa Kinh tế',
                'Khoa Xây dựng',
                'Khoa đào tạo CLC',
                'Phòng tuyển sinh',
                'Trung tâm dịch vụ sinh viên'
  ];
  var items2 = ['Học tập của sinh viên', 'Đăng kí môn học', 'Điểm rèn luyện', 'Điểm công tác xã hội', 'Học bổng','Tuyển sinh',
    'Thực tập tốt nghiệp','Đăng kí môn học', 'Xét tốt nghiệp', 'Khác', ];
  var items3 =['Học sinh THPT', 'Sinh viên', 'Phụ huynh', 'Cựu sinh viên', 'Khác'];


  FirebaseAuth auth = FirebaseAuth.instance;
  var userr = FirebaseAuth.instance.currentUser!;
  String name = "1234";
  UserModel userModel = new UserModel("", " ", "", "", "", "");

  Future<String> getUserNameFromUID() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: userr.uid)
        .get();
    return snapshot.docs.first['name'];
  }

  // Check if the user is signed in
  getCurrentUser() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: userr.uid)
        .get();
    userModel = snapshot.docs.first as UserModel;
    print(userModel.name);
  }

  List<UserModel> listQuestion = [];


  void getQuestionData() async {

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('user').get();
    snapshot.docs.map((e) {
      userModel.id = (e.data() as Map)['userId'];
      userModel.name = (e.data() as Map)['name'];
      userModel.email = (e.data() as Map)['email'];
      userModel.image = (e.data() as Map)['image'];
      userModel.password = (e.data() as Map)['pass'];
      userModel.phone = (e.data() as Map)['phone'];

      listQuestion.add(userModel);




    });
    print(listQuestion);
  }

  _buildQuestions(){
    List<Widget> questionsList = [];
    listQuestion.forEach((UserModel listQuestion){
      questionsList.add(
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.symmetric(horizontal:  20.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                width: 1.0,
                color: Colors.grey,
              )
            ),
            child: Row(
              children: <Widget> [
                Expanded(child: Container(
                  margin: EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Text(listQuestion.name,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.0,),

                      Text(listQuestion.email,
                      style: TextStyle(
                        fontSize:16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      ),

                    ],
                  ),
                ))
              ],
            ),
          ),

        )
      );


    } );
    return Column(children: questionsList);



    
  }
  





  @override
  Widget build(BuildContext context) {



    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("departments")
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
          List<String> list = [];
          snapshot.data!.docs.map(
                  (e) {

                // List list = (e.data() as Map)["category"];
                // print(list);
                String name = (e.data() as Map)["name"];
                list.add(name);
                return list; }
          ).toList();


          return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("departments").where("name", isEqualTo: value_khoa)
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
                List<dynamic> listt = [];
                print(value_khoa);
                print(snapshot.data!.docs);
                snapshot.data!.docs.map(
                        (e) {

                      // List list = (e.data() as Map)["category"];
                      // print(list);
                      late final name = (e.data() as Map)["category"];
                      //name.map(e => list.add(e, second));
                      if((e.data() as Map)["name"]==value_khoa) {
                        listt = name;
                      }
                      print(listt);

                      return listt; }
                ).toList();


                return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("user")
                        .where("userId", isEqualTo: userr.uid)
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
                        userModel.id = (e.data() as Map)['userId'];
                        userModel.name = (e.data() as Map)['name'];
                        userModel.email = (e.data() as Map)['email'];
                        userModel.image = (e.data() as Map)['image'];
                        userModel.password = (e.data() as Map)['pass'];
                        userModel.phone = (e.data() as Map)['phone'];
                        print("hello: "+userModel.name);
                        return userModel;

                      }).toString();

    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        title: const Text("Tin nhắn"),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Container(
              //   margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
              //   width: 400,
              //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(color: Colors.blueAccent, width: 4),
              //   ),
              //   child: DropdownButtonHideUnderline(
              //     child: DropdownButton<String>(
              //       value: value,
              //       hint: new Text("Vui lòng chọn đơn vị để hỏi"),
              //       iconSize: 36,
              //       items: items.map(buildMenuItem).toList(),
              //       onChanged: (value) => setState(() => this.value = value),
              //     ),
              //   )
              // ),
              // Container(
              //     margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
              //     width: 400,
              //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Colors.blueAccent, width: 4),
              //     ),
              //     child: DropdownButtonHideUnderline(
              //       child: DropdownButton<String>(
              //         value: value2,
              //         hint: new Text("Vui lòng chọn vấn đề để hỏi"),
              //         iconSize: 36,
              //         items: items2.map(buildMenuItem).toList(),
              //         onChanged: (value2) => setState(() => this.value2 = value2),
              //       ),
              //     )
              // ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(

                    onPressed: (){
                      showModalBottomSheet(
                          //isScrollControlled: true,
                          //backgroundColor: Colors.white30,

                          context: context,

                          builder: (BuildContext context){
                        return SingleChildScrollView(
                          child: Container(
                            height: 740,
                            child: Column(

                              mainAxisAlignment: MainAxisAlignment.start,


                              children: <Widget>[
                                Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),

                                Text("Đặt câu hỏi cho tư vấn viên", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                    width: 400,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blueAccent, width: 4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        value: value_khoa,
                                        hint: new Text("Vui lòng chọn đơn vị để hỏi"),
                                        iconSize: 36,
                                        items: render(list),
                                        onChanged: (value) {

                                          setState(() => this.value_khoa = value);


                                        },
                                      ),
                                    )
                                ),
                                Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                    width: 400,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blueAccent, width: 4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        value: value_vande,
                                        hint: new Text("Vui lòng chọn vấn đề để hỏi"),
                                        iconSize: 36,
                                        items: renderr(listt),
                                        onChanged: (value) {

                                          setState(() => this.value_vande = value);
                                        },
                                      ),
                                    )
                                ),
                                Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                    width: 400,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blueAccent, width: 4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: value_doituong,
                                        hint: new Text("Vui lòng chọn đối tượng"),
                                        iconSize: 36,
                                        items: items3.map(buildMenuItem).toList(),
                                        onChanged: (value) => setState(() => this.value_doituong = value),
                                      ),
                                    )
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                  width: 400,

                                  child:  TextField(
                                    decoration: InputDecoration(
                                        labelText: "Phương thức liên hệ",
                                        hintText: 'Nhập Email/SĐT của bạn',

                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Colors.blueAccent,
                                              width: 1,
                                            )
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Colors.blue,
                                                width: 4
                                            )
                                        )
                                    ),

                                  ),
                                ),
                                TextField(
                                  maxLines: 7,
                                  maxLength: 500,

                                  decoration: InputDecoration(
                                      hintMaxLines: 5,
                                      helperMaxLines: 5,
                                      labelText: "Đặt câu hỏi",
                                      hintText: 'Nhập câu hỏi của bạn',

                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.blueAccent,
                                            width: 1,
                                          )
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Colors.blue,
                                              width: 4
                                          )
                                      )
                                  ),

                                ),
                                IconButton(
                                    onPressed: (){

                                    },
                                    icon: Icon(AppIcons.file_pdf)),

                                Container(
                                  padding: EdgeInsets.all(10),
                                  child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: (){
                                            print('press save');
                                          },

                                          child: Text('Gửi',style: TextStyle(fontSize: 16, color: Colors.white),
                                          ),

                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.all(10)),
                                      Expanded(child: ElevatedButton(

                                          onPressed: () =>{
                                            Navigator.pop(context)

                                          },
                                          child: Text('Thoát', style: TextStyle(fontSize: 16, color: Colors.white),))

                                      ),
                                      Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 30)),



                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        );
                      });


                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )

                    ),

                    child: Text(
                      userModel.name! +
                      " ơi, bạn có muốn đặt câu hỏi?",
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),

                  ),
                ),
              ),









              Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff3277D8),
                    ),
                    child: Text(
                      "Gửi câu hỏi",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.0,),
              StreamBuilder<QuerySnapshot>(
                stream: derpart.snapshots(),
                  builder: (context, snapshot){
                  if(!snapshot.hasError){
                    Text("Loading");
                  }
                  else{
                    derpart.get()
                        .then((QuerySnapshot querySnapshot) {
                      querySnapshot.docs.forEach((doc) {
                        print(doc["departments"]);
                      }
                      );
                    });
                    //db.collection("collectionPath").get().whenComplete()
                    // for(int i=0; i<snapshot.data.documents.length;i++){
                    //   DocumentSnapshot snap = snapshot.data.documents[i];
                    //   departmentsItems.add(DropdownMenuItem(child: Text(
                    //     snap.documentID,
                    //     style: TextStyle(color:  Colors.blueAccent),
                    //   ),
                    //     value: "${snap.documentID}",
                    //   ));
                    // }
                  }
                  return Text("");
                  // return Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     Icon(AppIcons.ok, size: 25.5, color: Colors.blueAccent,),
                  //     SizedBox(width: 50.0,),
                  //     DropdownButton(
                  //       value: value4,
                  //         items: departmentsItems.map(buildMenuItem).toList(),
                  //         onChanged: (value4) => setState(() => this.value4 = value4))
                  //   ],
                  // );

                  }
                  ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Cau hoi cua ban',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  ),
                  _buildQuestions()
                ],
              )




            ],

          ),
        ),
      ),
    );
        });
              });

        });


 }

  List<DropdownMenuItem<String>> render(List<String> list) {
    return list.map(buildMenuItem).toList();
  }


  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
  DropdownMenuItem<dynamic> buildMenuItemm(dynamic item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ));
  List<DropdownMenuItem<dynamic>> renderr(List<dynamic> list) {
    return list.map(buildMenuItemm).toList();
  }
}