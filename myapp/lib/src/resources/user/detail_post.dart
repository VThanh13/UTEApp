import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/models/DepartmentModel.dart';
import 'package:myapp/src/models/EmployeeModel.dart';

import '../../models/NewfeedModel.dart';

class DetailPostScreen extends StatefulWidget {
  const DetailPostScreen({required this.newFeedModel, Key? key})
      : super(key: key);
  final NewfeedModel newFeedModel;

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {

  EmployeeModel employeeModel = EmployeeModel();
  DepartmentModel departmentModel = DepartmentModel();
  
  Future<void> getPostInformation() async{
    await FirebaseFirestore.instance.collection('employee').where(
      'id', isEqualTo: widget.newFeedModel.employeeId
    ).get().then((value) => {
      setState((){
        employeeModel.id = value.docs.first['id'];
        employeeModel.name = value.docs.first['name'];
        employeeModel.category = value.docs.first['category'];
        employeeModel.password = value.docs.first['password'];
        employeeModel.phone = value.docs.first['phone']!;
        employeeModel.image = value.docs.first['image'];
        employeeModel.department = value.docs.first['department'];
        employeeModel.roles = value.docs.first['roles'];
        employeeModel.status = value.docs.first['status'];
        employeeModel.email = value.docs.first['email'];
      }),
    });
  }
  @override
  void initState() {
    getPostInformation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: (){
                        Navigator.pop(context);

                      }, icon: const Icon(Icons.arrow_back_sharp),),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blueAccent,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(employeeModel.image!),
                              radius: 22,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                          ),),
                          Text(widget.newFeedModel.time!,
                          style:
                          const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 11
                          ),),
                        ],
                      )
                    ],
                  ),
                  IconButton(onPressed: (){
                    print(employeeModel);
                  }, icon: const Icon(Icons.more_vert_outlined))

                ],
              ),
              const SizedBox(height: 10,),
              const Divider(
                height: 0,
                color: Color(0xffAAAAAA),
                indent: 0,
                thickness: 1,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                child: Text(
                  widget.newFeedModel.content!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (widget.newFeedModel.file != 'file.pdf')
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                  child: Image.network(
                    widget.newFeedModel.file!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
