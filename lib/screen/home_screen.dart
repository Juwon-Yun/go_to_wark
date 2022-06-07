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
  static final LatLng destinationLatlng =
      LatLng(36.31795619547721, 127.4197022191111);
  static final CameraPosition initialCameraPosition =
      CameraPosition(target: currentLatlng, zoom: 15);
  static final double correctDistance = 100;

  static final Circle withDistance = Circle(
    // 서클의 고유번호
    circleId: CircleId('withDistance'),
    // 서클의 위치
    center: destinationLatlng,
    // 서클 색
    fillColor: Colors.blueAccent.withOpacity(0.5),
    radius: correctDistance,
    // 서클의 경게 색
    strokeColor: Colors.blue,
    // 경계 두께
    strokeWidth: 1,
  );

  static final Circle notWithDistanceCircle = Circle(
    circleId: CircleId('notWithDistanceCircle'),
    center: destinationLatlng,
    fillColor: Colors.redAccent.withOpacity(0.5),
    radius: correctDistance,
    strokeColor: Colors.red,
    strokeWidth: 1,
  );

  static final Circle checkDoneCircle = Circle(
    circleId: CircleId('checkDoneCircle'),
    center: destinationLatlng,
    fillColor: Colors.greenAccent.withOpacity(0.5),
    radius: correctDistance,
    strokeColor: Colors.green,
    strokeWidth: 1,
  );

  static final Marker marker =
      Marker(markerId: MarkerId('markerId'), position: destinationLatlng);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      // Future Builder는 context, snapshot 두개를 받아야한다.
      body: FutureBuilder(
        // future를 리턴하는 함수를 쓴다.
        // 에러 혹은 무언가 받았을때 화면을 다시 빌드해준다.
        future: checkPermission(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // print(snapshot);
          // print(snapshot.data);
          // none(future를 리턴하지않음), waiting(async 기다림), done(완료)
          // print(snapshot.connectionState);
          if (snapshot.data == '위치 권한이 허가되었습니다.') {
            return StreamBuilder<Position>(
                // 권한을 받았기 때문에 위치를 가져옴
                stream: Geolocator.getPositionStream(),
                builder: (context, snapshot) {
                  // 위치가 바뀔때 마다 화면을 재렌더링한다
                  print('streamBuilder =>  ${snapshot.data}');

                  bool isWithinRange = false;

                  if (snapshot.hasData) {
                    // 내위치를 position으로 표현한게 start
                    final start = snapshot.data;
                    final end = destinationLatlng;

                    final distance = Geolocator.distanceBetween(
                        start!.latitude,
                        start.longitude,
                        end.latitude,
                        end.longitude);

                    print('current and destination distance => $distance ');

                    // 100m 안에있다면 true
                    if (distance < correctDistance) {
                      isWithinRange = true;
                    }
                  }

                  return Column(
                    children: [
                      _CustomGoogleMap(
                          inittialCameraPosition: initialCameraPosition,
                          // 출근할 거리에 따라서 다른원 출력
                          circle: isWithinRange
                              ? withDistance
                              : notWithDistanceCircle,
                          marker: marker),
                      _ChoolCheckButton(
                        isWithinRange: isWithinRange,
                      )
                    ],
                  );
                });
          } else {
            return Center(
              child: Text(snapshot.data.toString()),
            );
          }
        },
      ),
    );
  }

  Future<String> checkPermission() async {
    final isLocationEnable = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnable) {
      return '위치 서비스를 활성화 해주세요';
    }

    LocationPermission checkPermission = await Geolocator.checkPermission();

    // denied면 요청
    if (checkPermission == LocationPermission.denied) {
      checkPermission = await Geolocator.requestPermission();

      if (checkPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요.';
      }
    }

    if (checkPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }

    // enum이 always, whileInUse일 때
    return '위치 권한이 허가되었습니다.';
  }
}

class _ChoolCheckButton extends StatelessWidget {
  final bool isWithinRange;

  const _ChoolCheckButton({
    Key? key,
    required this.isWithinRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timelapse_outlined,
            size: 50.0, color: isWithinRange ? Colors.blue : Colors.red),
        SizedBox(height: 20),
        if(isWithinRange)
        TextButton(
            onPressed: () {
              print('출근 완료');
            },
            child: Text('출근하기'))
      ],
    ));
  }
}

class _CustomGoogleMap extends StatelessWidget {
  final Circle circle;
  final Marker marker;

  const _CustomGoogleMap({
    Key? key,
    required this.inittialCameraPosition,
    required this.circle,
    required this.marker,
  }) : super(key: key);

  final CameraPosition inittialCameraPosition;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: inittialCameraPosition,
        // 내위치 아이콘
        myLocationEnabled: true,
        // 내위치로 돌아가는 floating button
        myLocationButtonEnabled: false,
        // 여기서 원의 고유번호
        circles: Set.from([circle]),
        markers: Set.from([marker]),
      ),
    );
  }
}

AppBar renderAppBar() {
  return AppBar(
    centerTitle: true,
    title: Text(
      '출첵',
      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
    ),
    backgroundColor: Colors.white,
  );
}
