import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_test/utils.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ContactsDBWorker.dart';
import 'ContactsModel.dart' show ContactsModel, contactsModel;
import '../utils.dart' as utils;

class ContactsEntry extends StatelessWidget {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _birthdayEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntry() {
    _nameEditingController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameEditingController.text;
    });
    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    });
    _emailEditingController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailEditingController.text;
    });
    _birthdayEditingController.addListener(() {
      contactsModel.entityBeingEdited.birthday =
          _birthdayEditingController.text;
    });
  }

  Widget build(BuildContext inContext) {
    _nameEditingController.text = contactsModel.entityBeingEdited?.name;
    _phoneEditingController.text = contactsModel.entityBeingEdited?.phone;
    _emailEditingController.text = contactsModel.entityBeingEdited?.email;
    _birthdayEditingController.text = contactsModel.entityBeingEdited?.birthday;
    return ScopedModel(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(builder:
            (BuildContext inContext, Widget inChild, ContactsModel inModel) {
          File avatarFile = File(join(utils.docsDir.path, 'avatar'));
          if (avatarFile.existsSync() == false) {
            if (inModel.entityBeingEdited != null &&
                inModel.entityBeingEdited.id != null) {
              avatarFile = File(join(
                  utils.docsDir.path, inModel.entityBeingEdited.id.toString()));
            }
          }
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      File avatarFile =
                          File(join(utils.docsDir.path, 'avatar'));
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(1);
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    child: Text('save'),
                    onPressed: () {
                      _save(inContext, inModel);
                    },
                  )
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    title: avatarFile.existsSync()
                        ? Image.file(avatarFile)
                        : Text('No avatar image for this contact'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _selectAvatar(inContext),
                    ),
                  ),
                  ListTile(
                      leading: Icon(Icons.person),
                      title: TextFormField(
                        decoration: InputDecoration(hintText: 'Name'),
                        controller: _nameEditingController,
                        validator: (String inValue) {
                          if (inValue.length == 0) {
                            return 'Please enter the name';
                          }
                          return null;
                        },
                      )),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(hintText: 'Phone'),
                      controller: _phoneEditingController,
                    ),
                  ),
                  ListTile(
                      leading: Icon(Icons.email),
                      title: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(hintText: "Email"),
                          controller: _emailEditingController)),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text('Birthday'),
                    subtitle: Text(contactsModel.chosenDate == null
                        ? ""
                        : contactsModel.chosenDate),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String chosenDate = await utils.selectDate(
                            inContext,
                            contactsModel,
                            contactsModel.entityBeingEdited.birthday);
                        if (chosenDate != null) {
                          contactsModel.entityBeingEdited.birthday = chosenDate;
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        }));
  }

  Future _selectAvatar(BuildContext inContext) {
    return showDialog(
        context: inContext,
        builder: (BuildContext inDialogContext) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  GestureDetector(
                    child: Text('Take a picture'),
                    onTap: () async {
                      var cameraImage = await ImagePicker.pickImage(
                          source: ImageSource.camera);
                      if (cameraImage != null) {
                        cameraImage
                            .copySync(join(utils.docsDir.path, 'avatar'));
                        contactsModel.triggerRebuild();
                      }
                      Navigator.of(inDialogContext).pop();
                    },
                  ),
                  GestureDetector(
                    child: Text('Select from library'),
                    onTap: () async {
                      var galleryImage = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (galleryImage != null) {
                        galleryImage
                            .copySync(join(utils.docsDir.path, 'avatar'));
                        contactsModel.triggerRebuild();
                      }
                      Navigator.of(inDialogContext).pop();
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  void _save(BuildContext inContext, ContactsModel inModel) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    var id;
    if (inModel.entityBeingEdited.id == null) {
      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);
    } else {
      id = await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
    }
    File avatarFile = File(join(utils.docsDir.path, 'avatar'));
    if (avatarFile.existsSync()) {
      avatarFile.renameSync(join(utils.docsDir.path, id.toString()));
    }
    contactsModel.loadData('contacts', ContactsDBWorker.db);
    inModel.setStackIndex(0);
    Scaffold.of(inContext).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      content: Text('Task saved'),
    ));
  }
}
