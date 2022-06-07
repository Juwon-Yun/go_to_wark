import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool choolCheckDone = false;
  GoogleMapController? mapController;

  // latitude - 위도, longitude - 경도

  static final LatLng currentLatlng =
      const LatLng(36.325256195490816, 127.4197022192119);
  static final LatLng destinationLatlng =
      const LatLng(36.31795619547721, 127.4197022191111);
  static final CameraPosition initialCameraPosition =
      CameraPosition(target: currentLatlng, zoom: 15);
  static final double correctDistance = 100;

  static final Circle withDistance = Circle(
    // 서클의 고유번호
    circleId: const CircleId('withDistance'),
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
    circleId: const CircleId('notWithDistanceCircle'),
    center: destinationLatlng,
    fillColor: Colors.redAccent.withOpacity(0.5),
    radius: correctDistance,
    strokeColor: Colors.red,
    strokeWidth: 1,
  );

  static final Circle checkDoneCircle = Circle(
    circleId: const CircleId('checkDoneCircle'),
    center: destinationLatlng,
    fillColor: Colors.greenAccent.withOpacity(0.5),
    radius: correctDistance,
    strokeColor: Colors.green,
    strokeWidth: 1,
  );

  static final Marker marker =
      Marker(markerId: const MarkerId('markerId'), position: destinationLatlng);

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
            return const Center(child: CircularProgressIndicator());
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

                    final distance = Geolocator.distanceBetween(start!.latitude,
                        start.longitude, end.latitude, end.longitude);

                    print('current and destination distance => $distance ');

                    // 100m 안에있다면 true
                    if (distance < correctDistance) {
                      isWithinRange = true;
                    }
                  }

                  return Column(
                    children: [
                      _CustomGoogleMap(
                          initialCameraPosition: initialCameraPosition,
                          // 출근할 거리에 따라서 다른원 출력
                          circle: choolCheckDone
                              ? checkDoneCircle
                              : isWithinRange
                                  ? withDistance
                                  : notWithDistanceCircle,
                          marker: marker,
                          onMapCreated: onMapCreated),
                      _ChoolCheckButton(
                        isWithinRange: isWithinRange,
                        onPressed: onChoolCheckPressed,
                        choolCheckDone: choolCheckDone,
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

  onMapCreated(GoogleMapController controller) {
    // UI변경이 없으니 setState 안한다.
    mapController = controller;
  }

  onChoolCheckPressed() async {
    final choolCheckResult = await showDialog(
        context: context,
        builder: (_) {
          // dialog를 만드는 최적화된 위젯
          return AlertDialog(
            title: const Text('출근하기'),
            content: const Text('출근하시겠습니까?'),
            // 선택할 수 있는 버튼들
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('취소')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('출근하기')),
            ],
          );
        });
    if (choolCheckResult != null) {
      setState(() {
        choolCheckDone = choolCheckResult;
      });
    }
  }

  AppBar renderAppBar() {
    return AppBar(
      centerTitle: true,
      title: const Text(
        '출첵',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            if (mapController == null) return;

            // 한번만 가져오면되기 때문에 Stream이 아닌 Future를 리턴하는걸 씀
            final location = await Geolocator.getCurrentPosition(
                timeLimit: Duration(seconds: 3),
                desiredAccuracy: LocationAccuracy.low,
            );

            mapController!.animateCamera(CameraUpdate.newLatLng(
                LatLng(location.latitude, location.longitude)));
          },
          icon: Icon(Icons.my_location),
          color: Colors.blue,
        )
      ],
      backgroundColor: Colors.white,
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
  final VoidCallback onPressed;
  final bool choolCheckDone;

  const _ChoolCheckButton({
    Key? key,
    required this.isWithinRange,
    required this.onPressed,
    required this.choolCheckDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timelapse_outlined,
            size: 50.0,
            color: choolCheckDone
                ? Colors.green
                : isWithinRange
                    ? Colors.blue
                    : Colors.red),
        const SizedBox(height: 20),
        if (isWithinRange && !choolCheckDone)
          TextButton(onPressed: onPressed, child: const Text('출근하기'))
      ],
    ));
  }
}

class _CustomGoogleMap extends StatelessWidget {
  final Circle circle;
  final Marker marker;
  final MapCreatedCallback onMapCreated;

  const _CustomGoogleMap({
    Key? key,
    required this.initialCameraPosition,
    required this.circle,
    required this.marker,
    required this.onMapCreated,
  }) : super(key: key);

  final CameraPosition initialCameraPosition;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialCameraPosition,
        // 내위치 아이콘
        myLocationEnabled: true,
        // 내위치로 돌아가는 floating button
        myLocationButtonEnabled: false,
        // 여기서 원의 고유번호
        circles: Set.from([circle]),
        markers: Set.from([marker]),
        onMapCreated: onMapCreated,
      ),
    );
  }
}
