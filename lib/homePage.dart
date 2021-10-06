// ignore_for_file: file_names, unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/scheduler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference dbRef;
  late DatabaseReference counterRef;
  late UserCredential userCred;
  List msgArr = [];
  TextEditingController msgCntrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    setUp();
  }

  setUp() async {
    userCred = await _auth.signInAnonymously();
    dbRef = FirebaseDatabase.instance.reference();
    counterRef = FirebaseDatabase.instance.reference().child("user");
    counterRef.keepSynced(true);
    dbRef.child("messages").onValue.listen(
      (event) {
        Map<dynamic, dynamic> l = event.snapshot.value;
        setState(
          () {
            msgArr = l.values.toList();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Align(
                        alignment: (userCred.user!.uid == userCred.user!.uid)
                            ? Alignment.centerRight
                            : Alignment.bottomLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                (userCred.user!.uid == userCred.user!.uid)
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(20))
                                    : BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20)),
                            color: (userCred.user!.uid == userCred.user!.uid)
                                ? Colors.green
                                : Colors.blue,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                              msgArr[index],
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: msgArr.length,
                ),
              ),
              TextFormField(
                controller: msgCntrl,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(width: 1, color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(width: 1, color: Colors.blue),
                  ),
                  suffixIcon: IconButton(
                      onPressed: () {
                        dbRef.child("messages").push().set(msgCntrl.text);
                        msgCntrl.text = '';
                      },
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.send,
                          size: 30,
                          color: Colors.blue,
                        ),
                      )),
                  hintText: "Enter your message",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
