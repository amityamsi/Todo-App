import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import 'drawer_button_data/terms_and_conditions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  TextEditingController _controller = TextEditingController();
  late SharedPreferences prefs;
  dynamic currentDateTime = DateFormat().format(DateTime.now());
  late String updateTask;

  List myList = [];
  late String messageText;

  File? profilePic;
  final _picker = ImagePicker();

  var appBarText = 'ToDo';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          OutlinedButton(
              onPressed: () {},
              child: Text(
                appBarText,
                style: TextStyle(color: Colors.white),
              ))
        ],
        backgroundColor: Colors.indigo[900],
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Container(
                child: Text("Amit bahadur"),
              ),
              onDetailsPressed: () {},
              accountEmail: const Text("amitbahadur1994@gmail.com"),
              currentAccountPicture: SizedBox(
                child: Stack(
                  children: [
                    //Show Profile Image
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: profilePic != null
                          ? Image.file(profilePic!, fit: BoxFit.cover).image
                          : const AssetImage('images/blue.jpg'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,

                      //Image add button to change profile image
                      child: IconButton(
                        hoverColor: Colors.green,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (alertDialogContext) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  insetPadding: EdgeInsets.all(50),
                                  title: Text(
                                    "Choose an action",
                                    textAlign: TextAlign.center,
                                  ),
                                  elevation: 30,
                                  actionsAlignment: MainAxisAlignment.center,
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          pickimage(ImageSource.camera);
                                          Navigator.pop(context);
                                        },
                                        child: Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 60,
                                        )),
                                    SizedBox(width: 50),
                                    TextButton(
                                        onPressed: () {
                                          pickimage(ImageSource.gallery);
                                          Navigator.pop(context);
                                        },
                                        child: Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 60,
                                        )),
                                  ],
                                );
                              });
                        },
                        icon: const Icon(
                          Icons.add_a_photo,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            //Home
            Card(
              elevation: 1,
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              shadowColor: Colors.black,
              child: ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Home"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),

            //Terms and Conditions
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              shadowColor: Colors.black,
              child: ListTile(
                leading: const Icon(CupertinoIcons.doc_append),
                title: const Text("Terms & Conditions"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TermsAndConditions()));
                },
              ),
            ),

            //Contact us
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              shadowColor: Colors.black,
              child: ListTile(
                leading: const Icon(Icons.add_ic_call_outlined),
                title: const Text("Contact us"),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),

      //Showing Tasks
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("tasks").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Card(
              child: ListView(
                children: snapshot.data!.docs.map((doc) {
                  return Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(5.0),
                      onLongPress: () async {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  scrollable: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  title: Text("Update your Task"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: TextEditingController()
                                          ..text =
                                              ((doc.data()) as dynamic)['data'],
                                        onChanged: (value) {
                                          updateTask = value;
                                        },
                                        maxLines: null,
                                        autofocus: true,
                                      ),
                                      ElevatedButton(
                                          onPressed: () async {
                                            await _firestore
                                                .collection('tasks')
                                                .doc(doc.id)
                                                .set(
                                              {
                                                "data": updateTask,
                                                "time": currentDateTime
                                              },
                                              SetOptions(
                                                merge: true,
                                              ),
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: Text("Update")),
                                    ],
                                  ),
                                ));
                      },
                      tileColor: Colors.blue[100],
                      trailing: IconButton(
                          icon: Icon(CupertinoIcons.trash),
                          onPressed: () async {
                            var collection =
                                FirebaseFirestore.instance.collection('tasks');
                            await collection.doc(doc.id).delete();
                          }),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      title: Text((doc.data() as dynamic)['data']),
                      subtitle: Text((doc.data() as dynamic)['time']),
                    ),
                  );
                }).toList(),
              ),
            );
          }
        },
      ),

      //Floating Button to add task
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showalertdialog();
          },
          child: const Icon(CupertinoIcons.add_circled)),
    );
  }

  //Take or Pick image from galary as profile avatar
  Future<void> pickimage(source) async {
    final XFile? pickedImage = await _picker.pickImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (pickedImage != null) {
      setState(() {
        profilePic = File(pickedImage.path);
      });
      final String fileName = path.basename(pickedImage.path);
      File imageFile = File(pickedImage.path);
      await storage.ref(fileName).putFile(
            imageFile,
          );
    }
  }

  //Show alert to write task and add while click on floating button
  void showalertdialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              title: Text("Add Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      messageText = value;
                    },
                    controller: _controller,
                    autofocus: true,
                    maxLines: null,
                  ),
                  Padding(padding: EdgeInsets.only(top: 10.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            addItemToList();
                            _firestore.collection("tasks").add(
                                {"data": messageText, "time": currentDateTime});
                            Navigator.pop(context);
                          },
                          child: Text("Add"))
                    ],
                  )
                ],
              ),
            ));
  }

//add items into list
  void addItemToList() {
    setState(() {
      myList.add(_controller.text);
      _controller.clear();
    });
  }
}
