import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jupgging/models/user.dart';
<<<<<<< Updated upstream
=======
import 'package:jupgging/auth/url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
>>>>>>> Stashed changes

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> with SingleTickerProviderStateMixin {
  FirebaseDatabase _database;
  DatabaseReference reference;
  String _databaseURL =
      'https://flutterproject-86abc-default-rtdb.asia-southeast1.firebasedatabase.app/';

  static final storage = new FlutterSecureStorage();

  double opacity = 0; //?
  AnimationController _animationController;
  Animation _animation;
  TextEditingController _idTextController;
  TextEditingController _pwTextController;

  @override
  void initState() {
    super.initState();

    _idTextController = TextEditingController();
    _pwTextController = TextEditingController();

    //여기 뭐하는거지?
    _animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);
    _animation =
        Tween<double>(begin: 0, end: pi * 2).animate(_animationController);
    _animationController.repeat();
    Timer(Duration(seconds: 2), () {
      setState(() {
        opacity = 1;
      });
    });

    _database = FirebaseDatabase(databaseURL: _databaseURL);
    reference = _database.reference().child('user');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Center(
                child: Column(
              children: <Widget>[
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, widget) {
                    return Transform.rotate(
                      angle: _animation.value,
                      child: widget,
                    );
                  },
                  child: Icon(
                    Icons.account_circle_rounded,
                    color: Colors.deepOrangeAccent,
                    size: 80,
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'Jubgging',
                      style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 30,
                          color: Colors.deepOrange),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration(seconds: 1),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _idTextController,
                          maxLines: 1,
                          decoration: InputDecoration(
                              labelText: 'ID', border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _pwTextController,
                          maxLines: 1,
                          decoration: InputDecoration(
                              labelText: 'PW', border: OutlineInputBorder()),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/sign');
                              },
                              child: Text('회원가입')),
                          FlatButton(
                              onPressed: () {
                                if (_idTextController.value.text.length == 0 ||
                                    _pwTextController.value.text.length == 0) {
                                  makeDialog('빈칸이 있습니다');
                                } else {
                                  reference
                                      .child(_idTextController.value.text)
                                      .onValue
                                      .listen((event) {
                                    if (event.snapshot.value == null) {
                                      makeDialog('아이디가 없습니다');
                                    } else {
                                      reference
                                          .child(_idTextController.value.text)
                                          .onChildAdded
                                          .listen((event) {
<<<<<<< Updated upstream
                                        User user = User.fromSnapshot(event.snapshot);
                                        var bytes = utf8
                                            .encode(_pwTextController.value.text);
                                        var digest = sha1.convert(bytes);
                                        if (user.pw == digest.toString()) {
                                          Navigator.of(context)
                                              .pushReplacementNamed('/main',
                                                  arguments:
                                                      _idTextController.value.text);
                                        } else {
                                          makeDialog('비밀번호가 틀립니다');
=======
                                        if (event.snapshot.value == null) {
                                          makeDialog('아이디가 없습니다');
                                        } else {
                                          reference
                                              .child(_idTextController.value.text)
                                              .onChildAdded
                                              .listen((event) {
                                            User user = User.fromSnapshot(event.snapshot);
                                            var bytes = utf8
                                                .encode(_pwTextController.value.text);
                                            var digest = sha1.convert(bytes);
                                            if (user.pw == digest.toString()) {
                                              nextMethod();
                                            } else {
                                              makeDialog('비밀번호가 틀립니다');
                                            }
                                          });
>>>>>>> Stashed changes
                                        }
                                      });
                                    }
                                  });
                                }
                              },
                              child: Text('로그인'))
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      )
                    ],
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            )),
          ),
        ),
      ),
    );
  }

  nextMethod() async {
    await storage.write(
        key: "login",
        value: _idTextController.value.text
    );

    Navigator.of(context)
        .pushReplacementNamed('/main',
        arguments:
        _idTextController.value.text);
  }

  void makeDialog(String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(text),
          );
        });
  }
}
