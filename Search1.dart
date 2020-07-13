import 'Chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ChatList.dart';

TextEditingController searchEditingController = new TextEditingController();
FirebaseUser loggedInUser;
final _auth = FirebaseAuth.instance;
final user = Firestore.instance;
int users;
bool isfound = false;
List<String> usernames = [];
String email;
String photourl = '';
//String userme=_auth;

class search extends StatefulWidget {
  @override
  _searchState createState() => _searchState();
}

class _searchState extends State<search> {
  @override
  void initState() {
    getUser();
    // TODO: implement initState
    super.initState();
  }

  void getUser() async {
    await auth.currentUser().then((user) async {
      final url = await list
          .collection('users')
          .where('mail', isEqualTo: user.email)
          .getDocuments();
      setState(() {
        photourl = url.documents[0].data['photoURL'];
        email = user.email;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatter Box'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      print(value);
                      if (value == '') {
                        setState(() {
                          isfound = false;
                          usernames = [];
                        });
                      }
                    },
                    controller: searchEditingController,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                    decoration: InputDecoration(
                        hintText: "search usermail ...",
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                        border: InputBorder.none),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final person = await user
                        .collection('chatlists')
                        .document(email)
                        .collection('mail')
                        .getDocuments();
                    for (var p in person.documents) {
                      print(p.data['mail']);
                      if (searchEditingController.text == p.data['mail']) {
                        setState(() {
                          isfound = true;
                        });
                      }
                    }
                    if (searchEditingController.text.isNotEmpty) {
                      var i;
                      final searchResultSnapshot = await user
                          .collection('users')
                          .where('mail',
                          isEqualTo: searchEditingController.text)
                          .getDocuments();
                      for (var j = 0; j < usernames.length; j++) {
                        usernames.removeAt(j);
                      }
                      for (i in searchResultSnapshot.documents) {
                        setState(() {
                          usernames.add(i.data['user']);
                          usernames.remove('user dont exist');
                        });
                      }
                      if (i == null) {
                        setState(() {
                          for (var j = 0; j < usernames.length; j++) {
                            usernames.removeAt(j);
                          }
                          usernames.add('user dont exist');
                        });
                      }
                    }
                    //  else {
                    //   usernames = [];
                    //   isfound = false;
                    // }
                  },
                  child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white10, Colors.white54],
                          ),
                          borderRadius: BorderRadius.circular(40)),
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.search)),
                )
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: usernames.length,
                itemBuilder: (context, index) {
                  // print('entered builder');
                  // print(loggedInUser.email);
                  return usersearched(
                    username: usernames[index],
                  );
                }),
          )
        ]),
      ),
    );
  }
}

class usersearched extends StatefulWidget {
  @override
  usersearched({this.username});
  final String username;

  @override
  _usersearchedState createState() => _usersearchedState();
}

class _usersearchedState extends State<usersearched> {
  String profilepic="  ";
  bool ispresent = true;
  @override
  void initState()  {
    super.initState();
    geturl();
  }
 geturl()async {
   final url = await list
       .collection('users')
       .where('user', isEqualTo: widget.username)
       .getDocuments();
   setState(() {
     profilepic = url.documents[0].data['photoURL'];
   });
 }
  @override

  Widget build(BuildContext context) {
    if (widget.username == 'user dont exist') {
      ispresent = false;
    }
    return ispresent
        ? Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.white10, Colors.grey],
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
            topRight: Radius.circular(5.0),
            topLeft: Radius.circular(5.0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.0,
            backgroundImage: NetworkImage(profilepic),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.username,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              searchEditingController.clear();
              if (!isfound) {
                await user
                    .collection('chatlists')
                    .document(email)
                    .collection('names')
                    .add({
                  'name': widget.username,
                  'time': DateTime.now().toString(),
                });
                await user
                    .collection('chatlists')
                    .document(widget.username)
                    .collection('names')
                    .add({
                  'name': email,
                  'time': DateTime.now().toString(),
                });
                Navigator.pop(
                  context,
                );
                for (var j = 0; j < usernames.length; j++) {
                  usernames.removeAt(j);
                }
                print('added');
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: !isfound
                        ? [Colors.orange, Colors.orangeAccent]
                        : [Colors.white, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(12),
              child: isfound ? Text('added') : Text('add'),
            ),
          ),
        ],
      ),
    )
        : Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            Icons.warning,
          ),
        ),
        SizedBox(
          width: 15.0,
        ),
        Text(
          'User Dosen\'t Exist',
          style: TextStyle(
            color: Colors.red,
            fontSize: 20.0,
            fontWeight: FontWeight.w300,
          ),
        )
      ],
    );
  }
}

//import 'package:chatchatterbox/aboutme.dart';
//import 'package:chatchatterbox/contacts.dart';
//
//import 'Chat.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/material.dart';
//import 'ChatList.dart';
//
//TextEditingController searchEditingController = new TextEditingController();
//FirebaseUser loggedInUser;
//final _auth = FirebaseAuth.instance;
//final user = Firestore.instance;
//int users;
//bool isfound = false;
//List<String> usernames = [];
//String email;
//
//
//class search extends StatefulWidget {
//  @override
//  _searchState createState() => _searchState();
//}
//
//class _searchState extends State<search> {
//  @override
//  void initState() {
//    getCurrentUser();
//    // TODO: implement initState
//    super.initState();
//  }
//
//  void getCurrentUser() async {
//    try {
//      final user = await _auth.currentUser();
//      if (user != null) {
//        loggedInUser = user;
//        setState(() {
//          email = loggedinuser.email;
//        });
//      }
//    } catch (e) {
//      print(e);
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//   return Scaffold(
//      body: SafeArea(
//        child: Column(children: [
//          Container(
//            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//            decoration: BoxDecoration(
//              color: Colors.orange,
//            ),
//            child: Row(
//              children: [
//                Expanded(
//                  child: TextField(
//                    onChanged: (value){
//                      if(value==" "){
//                        setState(() {
//                          isfound=false;
//                          usernames=[];
//                        });
//                      }
//                    },
//                    controller: searchEditingController,
//                    style: TextStyle(
//                      color: Colors.white,
//                      fontSize: 20.0,
//                    ),
//                    decoration: InputDecoration(
//                        hintText: "search username ...",
//                        hintStyle: TextStyle(
//                          color: Colors.white54,
//                          fontSize: 16,
//                        ),
//                        border: InputBorder.none),
//                  ),
//                ),
//                GestureDetector(
//                  onTap: () async {
//                    final person = await user.collection('chatlists').document(email)
//                        .collection('mail')
//                        .getDocuments();
//                    for (var p in person.documents) {
//                      final snaps=await user.collection('users').where('mail', isEqualTo:p.data['mail'] ).getDocuments();
//                      var name=await snaps.documents[0].data['user'];
//                      if (searchEditingController.text == name) {
//                        print(p.data['mail']);
//                        setState(() {
//                          isfound = true;
//                        });
//                      }
//                    }
//                    if (searchEditingController.text.isNotEmpty) {
//                      var i;
//                      final searchResultSnapshot = await user
//                          .collection('users').where('user', isEqualTo: searchEditingController.text)
//                          .getDocuments();
//                      for (var j = 0; j < usernames.length; j++) {
//                        usernames.removeAt(j);
//                      }
//                      for (i in searchResultSnapshot.documents) {
//                        setState(() {
//                          usernames.add(i.data['user']);
//                          usernames.remove('user dont exist');
//                        });
//                      }
//                      if (i == null) {
//                        print(i);
//                        setState(() {
//                          for (var j = 0; j < usernames.length; j++) {
//                            usernames.removeAt(j);
//                          }
//                          usernames.add('user dont exist');
//                        });
//                      }
//                    }
//                  },
//                  child: Container(
//                      height: 40,
//                      width: 40,
//                      decoration: BoxDecoration(
//                          gradient: LinearGradient(
//                            colors: [Colors.white10, Colors.white54],
//                          ),
//                          borderRadius: BorderRadius.circular(40)),
//                      padding: EdgeInsets.all(12),
//                      child: Icon(Icons.search)),
//                )
//              ],
//            ),
//          ),
//          Flexible(
//            child: ListView.builder(
//                shrinkWrap: true,
//                itemCount: usernames.length,
//                itemBuilder: (context, index) {
//                  return usersearched(
//                    username: usernames[index],
//                  );
//                }),
//          )
//        ]),
//      ),
//    );
//  }
//}
//
//class usersearched extends StatefulWidget {
//  @override
//  usersearched({this.username});
//  final String username;
//
//
//  @override
//  _usersearchedState createState() => _usersearchedState();
//}
//
//class _usersearchedState extends State<usersearched> {
//
//String  usermail=" ";
//String profileurl=" ";
//  bool ispresent = true;
//  @override
//  void initState() {
//    getusermail();
//    super.initState();
//  }
//  getusermail() async{
//    final snapshot=await user.collection('users').where('user', isEqualTo: widget.username).getDocuments();
//    setState(()  {
//      usermail= snapshot.documents[0].data['mail'];
//      profileurl=snapshot.documents[0].data['profileURL'];
//    });
//
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    if (widget.username == 'user dont exist') {
//      ispresent = false;
//
//    }
//    return ispresent
//        ? Container(
//            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//            decoration: BoxDecoration(
//              gradient: LinearGradient(
//                  colors: [Colors.white10, Colors.grey],
//                  begin: FractionalOffset.topCenter,
//                  end: FractionalOffset.bottomCenter),
//              borderRadius: BorderRadius.only(
//                  bottomLeft: Radius.circular(20.0),
//                  bottomRight: Radius.circular(20.0),
//                  topRight: Radius.circular(5.0),
//                  topLeft: Radius.circular(5.0)),
//            ),
//            child: Row(
//              children: [
//                Container(
//                  child:profileurl!=null? CircleAvatar(
//                    radius: 20.0,
//                    // backgroundColor:Colors.grey,
//                    backgroundImage: NetworkImage(profileurl),
//                  ):Container()
//                ),
//                SizedBox(width: 10),
//                Expanded(
//                  child: Column(children: <Widget>[
//                     Text(
//                      widget.username,
//                      style: TextStyle(
//                        fontSize: 20,
//                        fontWeight: FontWeight.w300,
//                        fontStyle: FontStyle.italic,
//                      ),
//                    ),
//                   Text(usermail,
//                      style: TextStyle(
//                        fontSize: 20,
//                        fontWeight: FontWeight.w300,
//                        fontStyle: FontStyle.italic,
//                      ),
//                    ),
//                  ]
//                  ),
//                ),
//                GestureDetector(
//                  onTap: () async {
//                    searchEditingController.clear();
//                    if (!isfound && (email!=usermail)) {
//                      await user.collection('chatlists').document(email).collection('mail')
//                          .add({'mail': usermail,'time':DateTime.now().toString(), });
//                      await user.collection('chatlists').document(usermail).collection('mail')
//                          .add({'mail': email, 'time':DateTime.now().toString(),});
//                      Navigator.pushReplacement(
//                        context,
//                        MaterialPageRoute(
//                          builder: (context) => Contacts(),
//                        ),
//                      );
//                      print('added');
//                    }
//                  },
//                  child: Container(
//                    decoration: BoxDecoration(
//                        gradient: LinearGradient(
//                          colors: !isfound
//                              ? [Colors.orange, Colors.orangeAccent]
//                              : [Colors.white, Colors.white],
//                        ),
//                        borderRadius: BorderRadius.circular(10)),
//                    padding: EdgeInsets.all(12),
//                    child: isfound ? Text('added') : Text('add'),
//                  ),
//                ),
//              ],
//            ),
//          )
//        : Row(
//            children: <Widget>[
//              Padding(
//                padding: const EdgeInsets.all(10.0),
//                child: Icon(
//                  Icons.warning,
//                ),
//              ),
//              SizedBox(
//                width: 15.0,
//              ),
//              Text(
//                'User Dosen\'t Exist',
//                style: TextStyle(
//                  color: Colors.red,
//                  fontSize: 20.0,
//                  fontWeight: FontWeight.w300,
//                ),
//              )
//            ],
//          );
//  }
//}
