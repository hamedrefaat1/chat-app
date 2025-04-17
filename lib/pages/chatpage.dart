import 'package:chat_app/pages/home.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class Chatpage extends StatefulWidget {
  String name, profileUrl, username;
  Chatpage(
      {super.key,
      required this.name,
      required this.profileUrl,
      required this.username});

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  TextEditingController massegeContoller = new TextEditingController();
  String? myNmae = "",
      myUsername = "",
      myProfilepic = "",
      myEmail = "",
      massgeId,
      chatRoomId;
  Stream? massegeStream;
  getTheSherfedPref() async {
    myNmae = await SharedPrefHelper().getDisplayName();
    myUsername = await SharedPrefHelper().getUserName();
    myProfilepic = await SharedPrefHelper().getUserPic();
    myEmail = await SharedPrefHelper().getUserEmai();
    chatRoomId = getChatRoomIdByUsername(myUsername!.toUpperCase(), widget.username.toUpperCase());
    setState(() {});
  }

  ontTheLoad() async {
    await getTheSherfedPref();
    await getAndSetMassge();
    setState(() {});
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

  Widget chatMeassgeTile(String massege, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            decoration: BoxDecoration(
                color: sendByMe
                    ? Color.fromARGB(255, 234, 236, 240)
                    : Color.fromARGB(255, 207, 224, 239),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft:
                        sendByMe ? Radius.circular(20) : Radius.circular(0),
                    bottomRight:
                        sendByMe ? Radius.circular(0) : Radius.circular(20))),
            child: Text(
              massege,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ),
        )
      ],
    );
  }

  Widget chatMassege() {
    return StreamBuilder(
        stream: massegeStream,
        builder: (context, AsyncSnapshot snapShot) {
          return snapShot.hasData? ListView.builder(
                  padding: EdgeInsets.only(bottom: 90, top: 130),
                  itemCount: snapShot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapShot.data.docs[index];
                    return chatMeassgeTile(ds["massge"], myUsername==ds["sendBy"]);
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  addMassege(bool sendClick) {
    if (massegeContoller != "") {
      String massege = massegeContoller.text;
      massegeContoller.text = "";

      DateTime now = DateTime.now();
      String formmateDate = DateFormat('h:mma').format(now);

      Map<String, dynamic> massegeInfoMap = {
        "massge": massege,
        "sendBy": myUsername,
        "ts": formmateDate,
        "time": FieldValue.serverTimestamp(),
        "imgurl": myProfilepic,
      };

      massgeId ??= randomAlphaNumeric(10);

      DataBaseMethods()
          .addMassge(chatRoomId!, massgeId!, massegeInfoMap)
          .then((value) {
        Map<String, dynamic> lastMassgeInfoMap = {
          "lastmassge": massege,
          "lastMassgeSendTs": formmateDate,
          "time": FieldValue.serverTimestamp(),
          "lastMassgeSendBy": myUsername,
        };
        DataBaseMethods().updateLastMassgeSend(chatRoomId!, lastMassgeInfoMap);
        if (sendClick) {
          massgeId = null;
        }
      });
    }
  }

  getAndSetMassge() async {
    massegeStream = await DataBaseMethods().getChatRoomMasseges(chatRoomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF553370),
      body: Container(
          padding: EdgeInsets.only(top: 60),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top:50),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/1.12,
                decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),color: Colors.white),
                child: chatMassege()
                ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Home()));
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Color(0xffc199cd),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                    ),
                    Text(
                      widget.name,
                      style: TextStyle(
                          color: Color(0xffc199cd),
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                 margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),  
                alignment: Alignment.bottomCenter,
                child: Material(
                  borderRadius: BorderRadius.circular(30),
                  elevation: 5,
                  child: Container(
                   
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      controller: massegeContoller,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message",
                          suffixIcon: GestureDetector(
                            onTap: (){
                              addMassege(true);
                            },
                            child: Icon(Icons.send_rounded))),
                    ),
                  ),
                ),
              )
            ],
          )
          ),
    );
  }
}
