import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jupgging/models/image.dart';
import 'package:jupgging/models/user.dart';
import 'dart:convert';
import 'package:jupgging/auth/url.dart';

class PublicBoard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PublicBoard();
}

class _PublicBoard extends State<PublicBoard> {
  List<ImageURL> imglist = List();
  List<String> idArr = List();
  String id;
  User user;
  FirebaseDatabase _database;
  DatabaseReference reference;
  DatabaseReference referenceImg;
  URL url=URL();
  String _databaseURL;

  //Map<String, ImageURL> map = Map();

  @override
  void initState()  {
    super.initState();
    _databaseURL=url.databaseURL;
    _database = FirebaseDatabase(databaseURL: _databaseURL);
    reference = _database.reference().child('user');
    referenceImg = _database.reference().child('image');

    referenceImg.orderByChild("createTime").onChildAdded.listen((event) {

      setState(() {
        id=event.snapshot.key;
            //idArr.add(event.snapshot.key);
      });

      referenceImg.child(id).onChildAdded.listen((event) {
        print('333333333333333${id}');
        setState(() {
          print('222222222222222${id}');
          imglist.add(ImageURL.fromSnapshot(event.snapshot));
        });
      });

    });
  }


  Widget build(BuildContext context) {

    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      child: Column(children: [
        if (imglist.length == 0) CircularProgressIndicator() else Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      //child: GridTile(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Container(
                                color: const Color(0xFF88C26F),
                                height: 50,
                                child: Row(children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(w*0.03, 0, 0, 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(55.0),
                                      child: Image.asset(
                                        'image/tree.jpg',
                                        width: 35,
                                        height: 35,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(w*0.03, h*0.001, 0, 0),
                                    child: Text(imglist[index].id,
                                        style: TextStyle(
                                          color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        )),
                                  ),
                                ])),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/detail', arguments: imglist[index]);
                            },
                              child: Column(
                                children : [
                                  Image.network(imglist[index].mapUrl,height:h*0.45, width:w, fit: BoxFit.cover),
                                 Padding(
                                   padding: EdgeInsets.fromLTRB(w*0.03, h*0.02, 0, 0),
                                   child: Row(
                                    children:[
                                      Text( id, style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text("    코멘트 자리"),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(0, h*0.001, w*0.03,0 ),

                                      ),
                                    ]
                                   ),
                                 ),
                                ]
                              ),
                          )
                        ],
                      ),
                    );
                  },
                  itemCount: imglist.length,
                ),
              ),
      ]),
    ));
  }
}
