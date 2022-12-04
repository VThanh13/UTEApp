

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/icons/app_icons_icons.dart';

class MessengerPage extends StatefulWidget {
  @override
  _MessengerPageState createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  CollectionReference derpart = FirebaseFirestore.instance.collection('departments');
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? value;
  String? value5;
  String? value4;
  var selectedDerpartments;
  String? value2;
  String? value3;
  String? value6;
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




  @override
  Widget build(BuildContext context) {



    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("departments")
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
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
                  .collection("departments").where("name", isEqualTo: value5)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                List<dynamic> listt = [];
                print(value5);
                print(snapshot.data!.docs);
                snapshot.data!.docs.map(
                        (e) {

                      // List list = (e.data() as Map)["category"];
                      // print(list);
                      late final name = (e.data() as Map)["category"];
                      //name.map(e => list.add(e, second));
                      if((e.data() as Map)["name"]==value5) {
                        listt = name;
                      }
                      print(listt);

                      return listt; }
                ).toList();

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
              Container(
                margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
                width: 400,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent, width: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    hint: new Text("Vui lòng chọn đơn vị để hỏi"),
                    iconSize: 36,
                    items: items.map(buildMenuItem).toList(),
                    onChanged: (value) => setState(() => this.value = value),
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
                      value: value2,
                      hint: new Text("Vui lòng chọn vấn đề để hỏi"),
                      iconSize: 36,
                      items: items2.map(buildMenuItem).toList(),
                      onChanged: (value2) => setState(() => this.value2 = value2),
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
                      value: value5,
                      hint: new Text("Vui lòng chọn đơn vị để hỏi 2"),
                      iconSize: 36,
                      items: render(list),
                      onChanged: (value5) {

                        setState(() => this.value5 = value5);
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
                      value: value6,
                      hint: new Text("Vui lòng chọn vấn đề để hỏi 2"),
                      iconSize: 36,
                      items: renderr(listt),
                      onChanged: (value6) {

                        setState(() => this.value6 = value6);
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
                      value: value3,
                      hint: new Text("Vui lòng chọn đối tượng"),
                      iconSize: 36,
                      items: items3.map(buildMenuItem).toList(),
                      onChanged: (value3) => setState(() => this.value3 = value3),
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
                  )




            ],

          ),
        ),
      ),
    );
        });});

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