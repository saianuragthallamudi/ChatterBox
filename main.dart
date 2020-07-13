import 'package:chatchatterbox/aboutme.dart';
import 'package:chatchatterbox/contacts.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'Chat.dart';
import 'ChatList.dart';
import 'Search1.dart';

void main() {
  runApp(Chatter_Box());
}

class Chatter_Box extends StatefulWidget {
  @override
  _Chatter_BoxState createState() => _Chatter_BoxState();
}

class _Chatter_BoxState extends State<Chatter_Box> {
  bool userIsLoggedIn;
   @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  getLoggedInState() async {
    await aboutme.getUserLoggedIn().then((value){
      setState(() {
        userIsLoggedIn  = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       title: 'Chatter_box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.orangeAccent,
         ),
      home: userIsLoggedIn != null ?  userIsLoggedIn ? Contacts(): HomePage() :HomePage(),
    );
  }
}
