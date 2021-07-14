import 'dart:convert';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jupgging/models/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jupgging/mapPage/runningInfo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jupgging/provider/location_provider.dart';
import 'dart:io';
import 'dart:math' show cos, sqrt, asin;
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';

class JupggingEnd extends StatefulWidget {
  final RunningInfo run;

  final List<LatLng> route;
  final LatLng departure;
  final double distance;

  @override
  State<StatefulWidget> createState() => _JupggingEnd();

  //run = ModalRoute.of(context)!.settings.arguments as RunningInfo;
  //run = ModalRoute.of(context).settings.arguments;
  JupggingEnd(
      {Key key, @required this.run, this.route, this.departure, this.distance})
      : super(key: key);
}

class _JupggingEnd extends State<JupggingEnd> {
  Set<Polyline> lines = Set();
  List<LatLng> points = List();
  Set<Marker> _markers = Set();

  double distance = 0.0; //거리
  LatLng start_point, end_point; //거리계산위한 시작점, 끝점받기

  FirebaseDatabase _database;
  DatabaseReference reference;
  String _databaseURL =
      'https://flutterproject-86abc-default-rtdb.asia-southeast1.firebasedatabase.app/';
  FirebaseStorage _firebaseStorage;

  String id;
  String time;

  Uint8List _image;//스토리지에 올릴 이미지
  Uint8List _imageBytes; //지도 캡쳐
  GoogleMapController _controller;
  ImageURL imageURL;
  //ScreenshotController screenshotController;

  @override
  void initState() {
    super.initState();

    id = 'happy123';
    _database = FirebaseDatabase(databaseURL: _databaseURL);
    reference = _database.reference().child('image');
    _firebaseStorage = FirebaseStorage.instance;
    //screenshotController = ScreenshotController();
  }

  @override
  Widget build(BuildContext context) {
    final info = ModalRoute.of(context).settings.arguments as JupggingEnd;
    points = info.route; //경로 polyline point
    start_point = info.departure; //시작점
    distance = info.distance; //거리
    var m = info.run.minutes;
    var s = info.run.seconds;

    if (m >= 60) {
      var h = m / 60;
      m %= m;
      time = h.toString().padLeft(2, '0') +
          ":" +
          m.toString().padLeft(2, '0') +
          ":" +
          s.toString().padLeft(2, '0');
    } else {
      time = "00:" +
          m.toString().padLeft(2, '0') +
          ":" +
          s.toString().padLeft(2, '0');
    }

    //시작위치 마커
    _markers.add(Marker(
        markerId: MarkerId("MyStartPosition"),
        position: LatLng(start_point.latitude, start_point.longitude),
        infoWindow:
            InfoWindow(title: 'Start Position', snippet: 'Start Running!!')));

    return Scaffold(
      body: Container(
        child: Column(children: [
          //mapInfo((MediaQuery.of(context).size.height-50)*0.75),
          Container(
              //지도 부분
              color: Colors.white,
              height: (MediaQuery.of(context).size.height - 50) * 0.85,
              child: Center(
                child: googleMapUI(),
              )),
          Container(
            //달린 거리, 시간 나오는 부분
            height: (MediaQuery.of(context).size.height - 50) * 0.15 + 50,
            color: Colors.white,
            child: Text('$distance km $m 분 $s 초',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20)), //시간 계산
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final imageBytes = await _controller.takeSnapshot();
          setState(() {
            _imageBytes = imageBytes;
          });
          //지도캡처, 거리, 시간 올리기
          _uploadImageToStorage(_imageBytes);
<<<<<<< Updated upstream
          //_selectPhotoButton(context);
          //다음페이지로 넘어가기
=======
>>>>>>> Stashed changes
        },
        child: Icon(Icons.arrow_forward_rounded),
        backgroundColor: Colors.lightBlueAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget googleMapUI() {
    return Consumer<LocationProvider>(builder: ( //changeNotifer가 변경될때마다 호촐
        consumerContext,
        model,
        child) {
      lines.add(
        Polyline(
          points: points,
          color: Colors.amber,
          polylineId: PolylineId("running route"),
        ),
      );

      if (model.locationPosition != null) {
        end_point = model.locationPosition; //마지막 목적지 위치
        _markers.add(Marker(
            //도착위치 마커
            markerId: MarkerId("MyEndPosition"),
            position: LatLng(end_point.latitude, end_point.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
                title: 'End Position', snippet: 'Finish Running!!')));

        return Column(
          children: [
            Expanded(
                child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition:
                  CameraPosition(target: model.locationPosition, zoom: 16),
              markers: _markers,
              polylines: lines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) async {
                _controller = controller;
              },
            ))
          ],
        );
      }

      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
  }

  void _uploadImageToStorage(Uint8List image) async {
    setState(() {
      _image = image;
    });

    // 프로필 사진을 업로드할 경로와 파일명을 정의.
    StorageReference storageReference = _firebaseStorage
        .ref()
        .child("map/${DateTime.now().millisecondsSinceEpoch}.png");

    // 파일 업로드
    StorageUploadTask storageUploadTask = storageReference.putData(_image);

    // 파일 업로드 완료까지 대기
    await storageUploadTask.onComplete;

    // 업로드한 사진의 URL 획득
    String downloadURL = await storageReference.getDownloadURL();

    //url을 db에 저장----------------------------
    reference
        .child(id)
        .push()
        .set(ImageURL(downloadURL, "", distance.toString(), time, "",
                DateTime.now().toIso8601String())
            .toJson())
        .then((_) {
      print('url 저장완료');

      reference
        .child(id)
        .child("key")
        .orderByChild("mapUrl")
        .equalTo(downloadURL)
        .onChildAdded.listen((event) {
          imageURL = ImageURL.fromSnapshot(event.snapshot);
          print(imageURL);
      });
      //print(imageURL);
      //print(imageURL.key);
      print(imageURL);
      Navigator.of(context).pushReplacementNamed('/add', arguments: imageURL);
    });
  }
}
