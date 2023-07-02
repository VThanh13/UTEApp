class ChatRoomModel{
  String? id;
  String? userId;
  String? title;
  String? time;
  String? department;
  String? category;
  String? information;
  String? group;
  String? status;
  String? mode;

  ChatRoomModel({this.id, this.userId, this.title, this.time, this.department,
      this.category, this.information, this.group, this.status, this.mode});

  ChatRoomModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['title'] = title;
    data['time'] = time;
    data['department'] = department;
    data['category'] = category;
    data['information'] = information;
    data['group'] = group;
    data['status'] = status;
    data['mode'] = mode;
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