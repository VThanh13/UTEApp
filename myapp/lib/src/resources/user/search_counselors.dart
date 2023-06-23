import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/models/EmployeeModel.dart';
import 'package:myapp/src/resources/user/view_employee_byuser.dart';

import '../../models/UserModel.dart';

class SearchCounselorsScreen extends StatefulWidget {
  const SearchCounselorsScreen({Key? key}) : super(key: key);

  @override
  State<SearchCounselorsScreen> createState() => _SearchCounselorsScreenState();
}

class _SearchCounselorsScreenState extends State<SearchCounselorsScreen> {
  List searchResult = [];
  String name = '';
  EmployeeModel employee = EmployeeModel();

  void searchFromFirebase(String query) async{
    final result = await FirebaseFirestore.instance.collection('employee').where(
      'name', isEqualTo: query
    ).get();

    setState(() {
      searchResult = result.docs.map((e) => e.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(15),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Search Here',
            ),
            onChanged: (val){
              setState(() {
                name = val;
              });
            },
          ),),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('employee').snapshots(),
                builder: (context, snapshot){
                  return (snapshot.connectionState == ConnectionState.waiting)
                      ?const Center(
                    child: CircularProgressIndicator(),
                  ):
                      ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index){
                            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                            if(name.isEmpty){
                              return ListTile(
                                title: Text(data['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600
                                ),),
                                subtitle: Text(data['roles'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600
                                  ),),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(data['image']),
                                ),
                              );
                            }
                            if(data['name'].toString().toLowerCase().startsWith(name.toLowerCase())){

                              return InkWell(
                                onTap: (){
                                  //Navigator.push(context, MaterialPageRoute(builder: (context) => ViewEmployeeByUser(employee: employee, users: current_user)));
                                },
                                child: ListTile(
                                  title: Text(data['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600
                                    ),),
                                  subtitle: Text(data['roles'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600
                                    ),),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(data['image']),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();

                      });
                },
              )),
        ],
      ),
    );
  }
  var currentUser = FirebaseAuth.instance.currentUser!;
  EmployeeModel employeeModel = EmployeeModel();
  UserModel current_user = UserModel();
  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: currentUser.uid)
        .get()
        .then((value) => {
      setState(() {
        current_user.id = value.docs.first['userId'];
        current_user.name = value.docs.first['name'];
        current_user.email = value.docs.first['email'];
        current_user.image = value.docs.first['image'];
        current_user.password = value.docs.first['password'];
        current_user.phone = value.docs.first['phone'];
        current_user.group = value.docs.first['group'];
        current_user.status = value.docs.first['status'];
      })
    });
  }
}