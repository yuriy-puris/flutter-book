import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'ContactsModel.dart';

class ContactsDBWorker {
  ContactsDBWorker._();
  static final ContactsDBWorker db = ContactsDBWorker._();
  Database _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    String path = join(utils.docsDir.path, 'contacts.db');
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
      await inDB.execute("CREATE TABLE IF NOT EXISTS contacts ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "phone TEXT,"
          "email TEXT,"
          "birthday TEXT"
          ")");
    });
    return db;
  }

  Contact contactFromMap(Map inMap) {
    Contact contact = Contact();
    contact.id = inMap['id'];
    contact.name = inMap['name'];
    contact.phone = inMap['phone'];
    contact.email = inMap['email'];
    contact.birthday = inMap['birthday'];
    return contact;
  }

  Map<String, dynamic> contactToMap(Contact inContact) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = inContact.id;
    map['name'] = inContact.name;
    map['phone'] = inContact.phone;
    map['email'] = inContact.email;
    map['birthday'] = inContact.birthday;
    return map;
  }

  Future create(Contact inContact) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 FROM contacts");
    int id = val.first['id'];
    if (id == null) {
      id = 1;
    }
    return await db.rawInsert(
        "INSERT INTO contacts (id, name, phone, email, birthday) "
        "VALUES (?, ?, ?, ?, ?)",
        [
          id,
          inContact.name,
          inContact.phone,
          inContact.email,
          inContact.birthday
        ]);
  }

  Future<Contact> get(inID) async {
    Database db = await database;
    var rec = await db.query("contacts", where: "id = ?", whereArgs: [inID]);
    return contactFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query('contacts');
    var list = recs.isNotEmpty
        ? recs.map((note) => contactFromMap(note)).toList()
        : [];
    return list;
  }

  Future update(Contact inContact) async {
    Database db = await database;
    return await db.update('contacts', contactToMap(inContact),
        where: "id = ?", whereArgs: [inContact.id]);
  }

  Future delete(inID) async {
    Database db = await database;
    return await db.delete('contacts', where: "id = ?", whereArgs: [inID]);
  }
}
