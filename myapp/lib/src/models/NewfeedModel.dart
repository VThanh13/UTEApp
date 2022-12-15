class NewfeedModel{
  String id;
  String employeeId;
  String content;
  String time;
  String file;


  NewfeedModel(this.id, this.employeeId, this.content, this.time, this.file);

  factory NewfeedModel.fromMap(Map<String, dynamic> json){
    return NewfeedModel(json['id'], json['employeeId'], json['content'], json['time'], json['file']);
  }

}