import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseServices {
  String? uId;
  String? name;
  String? imageUrl;
  String? email;
  DatabaseServices({this.uId});
//references for our collection
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users'); //this will take the collection of the user
  final CollectionReference groupCollection = FirebaseFirestore.instance
      .collection('groups'); //this will take the collection of the groups

  get getEmail => email;
  get getName => name;
  get getImageUrl => imageUrl;

  Future updateUserData(String fullName, String email) async {
    return await userCollection.doc(uId).set({
      'fullName': fullName,
      'email': email,
      'groups': [],
      'profilePic': '',
      'uId': uId
    });
  }

  uploadProfile(String imageUrl) async {
    await userCollection.doc(uId).update({"profilePic": imageUrl});
  }

  Future<dynamic> getProfilePic() async {
    DocumentSnapshot data = await userCollection.doc(uId).get();
    return data;
  }

  Future<String> uploadImage(Uint8List image) async {
    if (kDebugMode) {
      print('uploading image in flutter');
    }
    // create a firebasestorage reference
    try {
      final storageReference =
          FirebaseStorage.instance.ref().child('image/$uId.png');
// upload the file to firebase storage
      final uploadTask = storageReference.putData(image);
      // wait for the uplaod to complete
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
      rethrow;
    }
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

  deleteMessages(groupId, List<String> messageId) async {
    CollectionReference messageCollection =
        groupCollection.doc(groupId).collection('messages');
    messageId.forEach((element) async {
      QuerySnapshot snapshot =
          await messageCollection.where('messageId', isEqualTo: element).get();

      if (snapshot.docs.isNotEmpty) {
        String documentId = snapshot.docs.first.id;
        await messageCollection.doc(documentId).delete();
      }

      //  groupCollection.doc(groupId).collection('messages').doc(element).delete();
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

  getPickedImageUrl(
      {required Uint8List? image,
      required String groupId,
      required String messageId}) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('messages/$groupId/$messageId.png');
    UploadTask data = ref.putData(image!);
    TaskSnapshot done = await data.whenComplete(() {});
    final imageUrl = done.ref.getDownloadURL();
    return imageUrl;
  }

  sendMessage(
      {required String groupId,
      required String messageId,
      required String message,
      required String senderName,
      required String senderId,
      required int time,
      Uint8List? image}) async {
    String? imageUrl;
    if (image != null) {
      imageUrl = await getPickedImageUrl(
        image: image,
        groupId: groupId,
        messageId: messageId,
      );
    }

    if (imageUrl != null) {
      await groupCollection.doc(groupId).collection('messages').add({
        'groudId': groupId,
        'messageId': messageId,
        'message': message,
        'sendername': senderName,
        'senderId': senderId,
        'time': time,
        'imageUrl': imageUrl
      });
      await groupCollection.doc(groupId).update({
        "recentMessage": message,
        "recentMessageSender": senderName,
        "recentMessageTime": time
      });
    } else {
      await groupCollection.doc(groupId).collection('messages').add({
        'groudId': groupId,
        'messageId': messageId,
        'message': message,
        'sendername': senderName,
        'senderId': senderId,
        'imageUrl': '',
        'time': time,
      });
      await groupCollection.doc(groupId).update({
        "recentMessage": message,
        "recentMessageSender": senderName,
        "recentMessageTime": time
      });
    }
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
