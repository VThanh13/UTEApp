import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget{
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>{

  @override
  Widget build(BuildContext context) {
    String? value5;
    String? value6;
    CollectionReference depart = FirebaseFirestore.instance.collection('departments');


    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
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
          return ListView(
            children: [
              DropdownButtonHideUnderline(
              child: DropdownButton(
              value: value5,
                hint: new Text("Vui lòng chọn đơn vị để hỏi"),
                iconSize: 36,
                items: render(list),
                onChanged: (value5) {

                  setState(() => value5 = value5);
                },
              ),
              )
            ]


          );
        },
      ),
    );

  }

  List<DropdownMenuItem<String>> render(List<String> list) {
    return list.map(buildMenuItem).toList();
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  );


}