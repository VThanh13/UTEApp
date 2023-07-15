import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/ChatRoomModel.dart';
import '../employee/detail_question_employee.dart';

class SearchQuestionDialog {
  static void showChatRoomDialog(BuildContext context,List<ChatRoomModel> listChatRoom) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            height: 400, // Set the height of the dialog
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Related questions',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (listChatRoom.isEmpty)
                  Text(
                    'No related questions found',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildChatRoom(context, listChatRoom),
                    ),
                  ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () => {hideSearchQuestionDialog(context)},
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Exit',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static hideSearchQuestionDialog(BuildContext context) {
    Navigator.of(context).pop(SearchQuestionDialog);
  }

  static Widget _buildChatRoom(BuildContext context, listChatRoom) {
    // listChatRoom?.sort((a, b) => DateFormat("dd-MM-yyyy HH:mm:ss")
    //     .parse(b.time)
    //     .compareTo(DateFormat("dd-MM-yyyy HH:mm:ss").parse(a.time)));

    List<Widget> chatList = [];
    listChatRoom?.forEach((ChatRoomModel chatRoom) {
      chatList.add(GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      DetailQuestionEmployee(chatRoom: chatRoom)));
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          height: 75,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        chatRoom.title!,
                        style: const TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        'From: ${chatRoom.group}',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        chatRoom.time!,
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        chatRoom.status!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: chatRoom.status == "Chưa trả lời"
                              ? Colors.redAccent
                              : Colors.green,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
    });
    return Column(children: chatList);
  }
}