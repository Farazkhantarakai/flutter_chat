import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseServices {
  String? uId;
  DatabaseServices({this.uId});
//references for our collection
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users'); //this will take the collection of the user
  final CollectionReference groupCollection = FirebaseFirestore.instance
      .collection('groups'); //this will take the collection of the groups

  Future updateUserData(String fullName, String email) async {
    return await userCollection.doc(uId).set({
      'fullName': fullName,
      'email': email,
      'groups': [],
      'profilePic': '',
      'uId': uId
    });
  }

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    if (kDebugMode) {
      print('getting userData snapshot ${snapshot.docs[0]['fullName']}');
    }
    return snapshot;
  }

//this will create usergroups
  Future creatGroups(String userName, String id, String groupName) async {
    DocumentReference documentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": ""
    });

    await documentReference.update({
      "members": FieldValue.arrayUnion(["${id}_$userName"]),
      "groupId": documentReference.id
    });

    await userCollection.doc(uId).update({
      "groups": FieldValue.arrayUnion(["${documentReference.id}_$groupName"])
    });
  }

  Future getUsersGroups() async {
    return userCollection.doc(uId).snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot['admin'];
  }

  sendMessage(groupId, Map<String, dynamic> chatMessage) async {
    await groupCollection.doc(groupId).collection('messages').add(chatMessage);
    await groupCollection.doc(groupId).update({
      "recentMessage": chatMessage['message'],
      "recentMessageSender": chatMessage['sender'],
      "recentMessageTime": chatMessage['time'].toString()
    });
  }

  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  Future getMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  searchByName(String groupName) {
    return groupCollection.where('groupName', isEqualTo: groupName).get();
  }

  Future<bool> isJoinedOrNot(
      String groupId, String groupName, String admin) async {
    DocumentReference documentReference = userCollection.doc(uId);
    DocumentSnapshot snapshot = await documentReference.get();

    List<dynamic> groups = snapshot['groups'];
    if (groups.contains('${groupId}_$groupName')) {
      return true;
    } else {
      return false;
    }
  }

// togling the group
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentReference userDocReference = userCollection.doc(uId);
    DocumentReference groupDocReference = groupCollection.doc(uId);

    DocumentSnapshot userDocSnapshot = await userDocReference.get();
    List<dynamic> userGroups = userDocSnapshot['groups'];

    if (userGroups.contains("${groupId}_$userName")) {
      await userDocReference.update({
        "groups": FieldValue.arrayRemove(['${groupId}_$groupName'])
      });
      await groupDocReference.update({
        "members": FieldValue.arrayRemove(['${uId}_$userName'])
      });
    } else {
      await userDocReference.update({
        "groups": FieldValue.arrayUnion(['${groupId}_$groupName'])
      });
      await groupDocReference.update({
        "members": FieldValue.arrayUnion(['${uId}_$userName'])
      });
    }
  }
}
