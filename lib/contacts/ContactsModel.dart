import '../BaseModel.dart';

class Contact {
  String id;
  String name;
  String phone;
  String email;
  String birthday;
}

class ContactsModel extends BaseModel {
  void triggerRebuild() {
    notifyListeners();
  }
}

ContactsModel contactsModel = ContactsModel();
