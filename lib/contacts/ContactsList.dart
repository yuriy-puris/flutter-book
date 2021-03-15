import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'ContactsDBWorker.dart';
import 'ContactsModel.dart' show Contact, ContactsModel, contactsModel;
import '../utils.dart' as utils;

class ContactsList extends StatelessWidget {
  Widget build(BuildContext inContext) {
    return ScopedModel(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(builder:
            (BuildContext inContext, Widget inChild, ContactsModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                File avatarFile = File(join(utils.docsDir.path, 'avatar'));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate(null);
                contactsModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
                itemCount: contactsModel.entityList.length,
                itemBuilder: (BuildContext inContext, int inIndex) {
                  Contact contact = contactsModel.entityList[inIndex];
                  File avatarFile =
                      File(join(utils.docsDir.path, contact.id.toString()));
                  bool avatarFileExists = avatarFile.existsSync();
                  return Column(
                    children: [
                      Slidable(
                        delegate: SlidableDrawerDelegate(),
                        actionExtentRatio: .25,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            backgroundImage:
                                avatarFileExists ? FileImage(avatarFile) : null,
                            child: avatarFileExists
                                ? Text(contact.name.substring(0, 1))
                                : null,
                          ),
                          title: Text('${contact.name}'),
                          subtitle: contact.phone == null
                              ? null
                              : Text('${contact.phone}'),
                          onTap: () async {
                            File avatarFile =
                                File(join(utils.docsDir.path, 'avatar'));
                            if (avatarFile.existsSync()) {
                              avatarFile.deleteSync();
                            }
                            contactsModel.entityBeingEdited =
                                await ContactsDBWorker.db.get(contact.id);
                            if (contactsModel.entityBeingEdited.birthday ==
                                null) {
                              contactsModel.setChosenDate(null);
                            } else {
                              List dateParts = contactsModel
                                  .entityBeingEdited.birthday
                                  .split(',');
                              DateTime birthday = DateTime(
                                  int.parse(dateParts[0]),
                                  int.parse(dateParts[1]),
                                  int.parse(dateParts[3]));
                              contactsModel.setChosenDate(
                                  DateFormat.yMMMMd('en_US')
                                      .format(birthday.toLocal()));
                            }
                            contactsModel.setStackIndex(1);
                          },
                        ),
                        secondaryActions: [
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () => _deleteContact(inContext, contact),
                          )
                        ],
                      ),
                      Divider()
                    ],
                  );
                }),
          );
        }));
  }

  Future _deleteContact(BuildContext inContext, Contact inContact) async {
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: Text('Delete Contact'),
            content:
                Text('Are you sure you want to delete ${inContact.name} ?'),
            actions: [
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(inAlertContext).pop();
                },
              ),
              FlatButton(
                child: Text('Delete'),
                onPressed: () async {
                  File avatartFile =
                      File(join(utils.docsDir.path, inContact.id.toString()));
                  if (avatartFile.existsSync()) {
                    avatartFile.deleteSync();
                  }
                  await ContactsDBWorker.db.delete(inContact.id);
                  Navigator.of(inAlertContext).pop();
                  Scaffold.of(inContext).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Contact deleted'),
                  ));
                  contactsModel.loadData('contacts', ContactsDBWorker.db);
                },
              )
            ],
          );
        });
  }
}
