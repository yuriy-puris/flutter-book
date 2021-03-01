import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

import 'appointments/Appointments.dart';
import 'contacts/Contacts.dart';
import 'notes/Notes.dart';
import 'tasks/Tasks.dart';
import 'utils.dart' as utils;


void main() {
  startMeUp() async {
    await WidgetsFlutterBinding.ensureInitialized();
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(FlutterBook());
  }
  startMeUp();
}

class FlutterBook extends StatelessWidget {

  Widget build(BuildContext inContext) {
    return MaterialApp(
      home: DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            title: Text('FlutterBook'),
            bottom: TabBar(
              tabs: [
                // Tab(icon: Icon(Icons.date_range), text: "Appoinments"),
                // Tab(icon: Icon(Icons.contacts), text: "Contacts"),
                Tab(icon: Icon(Icons.note), text: "Notes"),
                // Tab(icon: Icon(Icons.assignment_turned_in), text: "Tasks")
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Appoinments(), Contacts(), Notes(), Tasks()
              Notes()
            ],
          ),
        ),
      )
    );
  }

}


