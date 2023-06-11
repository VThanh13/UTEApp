class ChatRoomModel{
  String? id;
  String? user_id;
  String? title;
  String? time;
  String? department;
  String? category;
  String? information;
  String? group;
  String? status;
  String? mode;

  ChatRoomModel({this.id, this.user_id, this.title, this.time, this.department,
      this.category, this.information, this.group, this.status, this.mode});

  ChatRoomModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user_id = json['user_id'];
    title = json['title'];
    time = json['time'];
    department = json['department'];
    category = json['category'];
    information = json['information'];
    group = json['group'];
    status = json['status'];
    mode = json['mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.user_id;
    data['title'] = this.title;
    data['time'] = this.time;
    data['department'] = this.department;
    data['category'] = this.category;
    data['information'] = this.information;
    data['group'] = this.group;
    data['status'] = this.status;
    data['mode'] = this.mode;
    return data;
  }

  // factory ChatRoomModel.fromMap(Map<String, dynamic> json){
  //   return ChatRoomModel(
  //     json['id'],
  //     json['user_id'],
  //     json['title'],
  //     json['time'],
  //     json['department'],
  //     json['category'],
  //     json['information'],
  //     json['group'],
  //     json['status'],
  //     json['mode'],
  //   );
  // }
}