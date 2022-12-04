import 'package:flutter/material.dart';

class MyInfo extends StatefulWidget{
  @override
  _MyInfoState createState() => new _MyInfoState();
}

class _MyInfoState extends State<MyInfo>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new  AppBar(
        title: new Text('Thông tin cá nhân'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                width: 400,

                child:  TextField(
                  decoration: InputDecoration(
                      labelText: "Tên của bạn",


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
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                width: 400,

                child:  TextField(
                  decoration: InputDecoration(
                      labelText: "SĐT của bạn",


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
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                width: 400,

                child:  TextField(
                  decoration: InputDecoration(
                      labelText: "Email của bạn",


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
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                width: 400,

                child:  TextField(
                  decoration: InputDecoration(
                      labelText: "Mật khẩu của bạn",


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

                        child: Text('Lưu',style: TextStyle(fontSize: 16, color: Colors.white),
                        ),

                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    Expanded(child:  ElevatedButton(
                        onPressed: (){
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context){
                                return Column(
                                  children: <Widget>[
                                    Text("Đổi mật khẩu", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                      width: 400,

                                      child:  TextField(
                                        decoration: InputDecoration(
                                            labelText: "Mật khẩu",
                                            hintText: 'Nhập mật khẩu của bạn',

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
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                      width: 400,

                                      child:  TextField(
                                        decoration: InputDecoration(
                                            labelText: "Mật khẩu mới",
                                            hintText: 'Nhập mật khẩu mới của bạn',

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
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                      width: 400,

                                      child:  TextField(
                                        decoration: InputDecoration(
                                            labelText: "Xác nhận mật khẩu",
                                            hintText: 'Nhập lại mật khẩu của bạn',

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

                                              child: Text('Lưu',style: TextStyle(fontSize: 16, color: Colors.white),
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


                                        ],
                                      ),
                                    )

                                  ],
                                );
                              });
                        },
                        child: const Text('Đổi mật khẩu'))

                    ),


                  ],
                ),
              ),

            ],
          ),

        ),
      ),
    );
  }
}