import 'package:flutter/material.dart';
import 'package:flutter_chat/shared/constants.dart';
import '../screens/chat_page.dart';

class GroupTile extends StatelessWidget {
  GroupTile(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  String groupId;
  String groupName;
  String userName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.pushNamed(context, ChatPage.routName, arguments: {
        //   'userName': userName,
        //   'groupName': groupName,
        //   'groupId': groupId
        // });
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatPage(
              groupId: groupId, groupName: groupName, userName: userName);
        }));
      },
      child: Card(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Constants.primaryColor,
            child: Text(
              groupName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          title: Text(
            groupName,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'add this to your conversation $userName',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
