import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/models/EmployeeModel.dart';
import 'package:myapp/src/resources/user/view_employee_by_user.dart';

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
    ).limit(10).get();

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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              hintText: 'Search Here...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                suffixIcon: Icon(Icons.search_rounded, color: Colors.grey,)
            ),
            onChanged: (val){
              setState(() {
                name = val;
              });
            },
          ),),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('employee').limit(10).snapshots(),
                builder: (context, snapshot){
                  return (snapshot.connectionState == ConnectionState.waiting)
                      ?const Center(
                    child: CircularProgressIndicator(),
                  ):
                      ListView.builder(
                        key: UniqueKey(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index){
                            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                            if(name.isEmpty){
                              return InkWell(
                                onTap: (){
                                  setState(() {
                                    employee.id = data['id'];
                                    employee.name = data['name'];
                                    employee.email = data['email'];
                                    employee.status = data['status'];
                                    employee.roles = data['roles'];
                                    employee.image = data['image'];
                                    employee.department = data['department'];
                                    employee.phone = data['phone'];
                                    employee.password = data['password'];
                                    employee.category = List<String>.from(data['category']);
                                  });
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewEmployeeByUser(employee: employee, users: userModel)));
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
                            if(data['name'].toString().toLowerCase().startsWith(name.toLowerCase())){

                              return InkWell(
                                onTap: (){
                                  setState(() {
                                    employee.id = data['id'];
                                    employee.name = data['name'];
                                    employee.email = data['email'];
                                    employee.status = data['status'];
                                    employee.roles = data['roles'];
                                    employee.image = data['image'];
                                    employee.department = data['department'];
                                    employee.phone = data['phone'];
                                    employee.password = data['password'];
                                    employee.category = List<String>.from(data['category']);
                                  });
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewEmployeeByUser(employee: employee, users: userModel)));
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
  UserModel userModel = UserModel();
  getCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .where('userId', isEqualTo: currentUser.uid)
        .get()
        .then((value) => {
      setState(() {
        userModel.id = value.docs.first['userId'];
        userModel.name = value.docs.first['name'];
        userModel.email = value.docs.first['email'];
        userModel.image = value.docs.first['image'];
        userModel.password = value.docs.first['password'];
        userModel.phone = value.docs.first['phone'];
        userModel.group = value.docs.first['group'];
        userModel.status = value.docs.first['status'];
      })
    });
  }
}