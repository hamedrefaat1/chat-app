// ignore_for_file: prefer_const_constructors

import 'package:chat_app/pages/chatpage.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  String? myNmae = "", myUsername = "", myProfilepic = "", myEmail = "";
  Stream? chatRoomsStram;
  getTheSherfedPref() async {
    myNmae = await SharedPrefHelper().getDisplayName();
    myUsername = await SharedPrefHelper().getUserName();
    myProfilepic = await SharedPrefHelper().getUserPic();
    myEmail = await SharedPrefHelper().getUserEmai();
    setState(() {});
  }

  ontTheLoad() async {
    await getTheSherfedPref();
    chatRoomsStram = await DataBaseMethods().getChatRoomList();
    setState(() {});
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStram,
      builder: (context, AsyncSnapshot snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapShot.hasError) {
          return Center(child: Text("Error: ${snapShot.error}"));
        } else if (!snapShot.hasData || snapShot.data.docs.isEmpty) {
          return Center(child: Text("No chat rooms found"));
        } else {
          return ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: snapShot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapShot.data.docs[index];
              return ChatRoomTile(
                lastMassege: ds["lastmassge"],
                chatRoomId: ds.id,
                myUsername: myUsername!,
                time: ds["lastMassgeSendTs"],
              );
            },
          );
        }
      },
    );
  }

  @override
  initState() {
    super.initState();

    ontTheLoad();
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  var queryResultSet = [];
  var tempSearchStore = [];

  goSearch(value) {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      search = true;
    });
    var captilaizedValue;
    if (!value.isEmpty) {
      captilaizedValue =
          value.substring(0, 1).toUpperCase() + value.substring(1);
    }
    if (queryResultSet.isEmpty && value.length == 1) {
      DataBaseMethods().search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; i++) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element["username"].startsWith(captilaizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF553370),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 50, right: 20, left: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      search
                          ? Expanded(
                              child: TextField(
                              onChanged: (value) {
                                goSearch(value.toUpperCase());
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search User",
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500)),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ))
                          : Text(
                              "ChatUp",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffc199cd)),
                            ),
                      GestureDetector(
                        onTap: () {
                          search = !search;
                          tempSearchStore = [];
                          setState(() {});
                        },
                        child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: Color(0xFF3a2144),
                                borderRadius: BorderRadius.circular(20)),
                            child: search
                                ? Icon(
                                    Icons.close,
                                    color: Color(0xffc199cd),
                                  )
                                : Icon(
                                    Icons.search,
                                    color: Color(0xffc199cd),
                                  )),
                      )
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    height: search
                        ? MediaQuery.of(context).size.height / 1.17
                        : MediaQuery.of(context).size.height / 1.15,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 241, 241, 241),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: search
                        ? Column(
                            children: [
                              ListView(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                primary: false,
                                shrinkWrap: true,
                                children: tempSearchStore.map((element) {
                                  return bulidResultCart(element);
                                }).toList(),
                              )
                            ],
                          )
                        : chatRoomsList())
              ],
            ),
          ),
        ));
  }

  Widget bulidResultCart(data) {
    return GestureDetector(
      onTap: () async {
        search = !search;
        setState(() {});
        var charRoomId = getChatRoomIdByUsername(
            myUsername!.toUpperCase(), data["username"].toUpperCase());
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUsername, data["username"]],
        };
        await DataBaseMethods().createChatRoom(charRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chatpage(
                    name: data["name"],
                    profileUrl: data["photo"],
                    username: data["username"])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 243, 241, 241),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      data["photo"],
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    )),
                SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      data["name"],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      data["username"],
                      style: TextStyle(
                          color: Colors.black38,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomTile extends StatefulWidget {
  final String lastMassege, chatRoomId, myUsername, time;
  ChatRoomTile(
      {required this.lastMassege,
      required this.chatRoomId,
      required this.myUsername,
      required this.time});
  @override
  State<ChatRoomTile> createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {
  String profilePicUrl = "", name = "", username = "", id = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUsername, "");
    try {
      QuerySnapshot querySnapshot =
          await DataBaseMethods().getUserInfoByUsername(username.toUpperCase());

      if (querySnapshot.docs.isNotEmpty) {
        name = "${querySnapshot.docs[0]["name"]}";
        profilePicUrl = "${querySnapshot.docs[0]["photo"]}";
        id = "${querySnapshot.docs[0]["id"]}";

        if (mounted) {
          setState(() {});
        }
      } else {
        print("No user found with username: $username");
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chatpage(
                    name: name,
                    profileUrl: profilePicUrl,
                    username: username)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicUrl == ""
                ? CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      profilePicUrl,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    )),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  username,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    widget.lastMassege,
                    style: TextStyle(
                        color: Colors.black45,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(
              widget.time,
              style: TextStyle(
                  color: Colors.black45,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
