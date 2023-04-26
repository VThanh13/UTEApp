class ChatRoomModel{
  String id;
  String user_id;
  String title;
  String time;
  String department;
  String category;
  String information;
  String group;
  String status;
  String mode;

  ChatRoomModel(this.id, this.user_id, this.title, this.time, this.department,
      this.category, this.information, this.group, this.status, this.mode);

  factory ChatRoomModel.fromMap(Map<String, dynamic> json){
    return ChatRoomModel(
      json['id'],
      json['user_id'],
      json['title'],
      json['time'],
      json['department'],
      json['category'],
      json['information'],
      json['group'],
      json['status'],
      json['mode'],
    );
  }
}