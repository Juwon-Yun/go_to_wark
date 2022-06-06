import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // latitude - 위도, longitude - 경도

  static final LatLng currentLatlng =
      LatLng(36.325256195490816, 127.4197022192119);
  static final CameraPosition inittialCameraPosition =
      CameraPosition(target: currentLatlng, zoom: 15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:renderAppBar(),
      body: Column(children: [
        _CustomGoogleMap(inittialCameraPosition: inittialCameraPosition),
        _ChollCheck()
      ]),
    );
  }

  Future<String> checkPermission() async {
    final isLocationEnable = await Geolocator.isLocationServiceEnabled();

    if(!isLocationEnable){
      return '위치 서비스를 활성화 해주세요';
    }

    LocationPermission checkPermission = await Geolocator.checkPermission();

    // denied면 요청
    if(checkPermission == LocationPermission.denied){
      checkPermission = await Geolocator.requestPermission();

      if(checkPermission == LocationPermission.denied){
        return '위치 권한을 허가해주세요.';
      }
    }

    if(checkPermission == LocationPermission.deniedForever){
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }

    // always, whileInUse
    return '위치 권한이 허가되었습니다.';
  }
}

class _ChollCheck extends StatelessWidget {
  const _ChollCheck({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: 1,child: Text('출근'));
  }
}

class _CustomGoogleMap extends StatelessWidget {
  const _CustomGoogleMap({
    Key? key,
    required this.inittialCameraPosition,
  }) : super(key: key);

  final CameraPosition inittialCameraPosition;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: inittialCameraPosition),
    );
  }
}

AppBar renderAppBar(){
  return AppBar(
    centerTitle: true,
    title: Text(
      '오늘도 출근',
      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
    ),
    backgroundColor: Colors.white,
  );
}
