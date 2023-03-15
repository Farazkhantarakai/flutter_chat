import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat/services/database_services.dart';

class Change extends ChangeNotifier {
  bool change = false;
  bool isItemSelected = false;
  List<String> messageIds = [];

  List<String> get getMessageIds => messageIds;
  get getChange => change;
  get getIsItemSelected => isItemSelected;
  doTrue() {
    change = true;
    notifyListeners();
  }

  doFalseValue() {
    change = false;
    notifyListeners();
  }

  addMessageToList(String messageId) {
    messageIds.add(messageId);
    notifyListeners();
  }

  removeMessageFromList(String messageId) {
    messageIds.remove(messageId);
    notifyListeners();
  }

  removeMessageItem() {
    messageIds = [];
    notifyListeners();
  }

  deleteItems(String groupId) async {
    await DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .deleteMessages(groupId, messageIds);
    isItemSelected = false;
    notifyListeners();
  }

  changFalseItemSelected() {
    isItemSelected = false;
    notifyListeners();
  }

  changeIsItemSelected() {
    isItemSelected = true;
    notifyListeners();
  }
}
