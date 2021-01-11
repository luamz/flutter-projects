import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

// Setting up the table (database) and its column's
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper
      .internal(); // Declaring singleton
  factory ContactHelper () => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return db;
    }
    else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath(); // Get database's path
    final path = join(
        databasesPath, "mycontacts.db"); // Creates the contacts path

    return await openDatabase(
        path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
              "$phoneColumn TEXT, $imgColumn TEXT)" // Setting database's config
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db; // Get db
    contact.id =
    await dbContact.insert(contactTable, contact.toMap()); //Insert to db
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db; // Get db
    List<Map> maps = await dbContact.query(
        contactTable, // Query gets specific line from db
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        // get these
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) { // If we find the contact
      return Contact.fromMap(maps.first);
    }
    else {
      return null;
    }
  }

  Future<int> removeContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(contactTable,
        where: "$idColumn = ?",
        whereArgs: [id]
    );
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable,
        contact.toMap(),
        where: "$idColumn = ?",
        whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable"); // SELECT ALL
    List<Contact> listContact = [];
    for (Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getTotal() async{
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery(("SELECT COUNT(*) FROM $contactTable"))); // COUNT ALL
  }

  Future<void> close() async{
    Database dbContact = await db;
    dbContact.close();
  }

}

class Contact{
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map){ // Get contact from a map
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap(){ // Set map from contact
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };

    if (id!=null){ // If the contact is already on the database
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}