## 👨🏻‍🔧 출근관리 앱

### 🤷🏻 What
GoogleMaps를 곁들인 위치를 이용한 출근관리 앱입니다.

### 🚀 HOW
지정된 장소 범위에 사용자가 있는 경우 출근할 수 있습니다.

### iOS 15.2
![cc_permissionAndanimate](https://user-images.githubusercontent.com/85836879/172394483-37235d90-805c-4719-8d3a-d6231243dcf2.gif)
![redtoblue](https://user-images.githubusercontent.com/85836879/172394479-20600ebb-b4a6-4ece-9e01-bea5990fd635.gif)
![redtogreen](https://user-images.githubusercontent.com/85836879/172394456-5d0255d3-5570-450b-9fc0-b006826dcc89.gif)

### 📖 Review
FutureBuilder와 StreamBuilder의 적절한 사용법을 알 수 있었다.

FutureBuilder는 Future 함수의 반환값이 에러 혹은 다른 값으로 할당될 때 AsyncSnapShot 객체로 재랜더링 할 수 있다.

StreamBuilder 또한 Stream을 반환받는 함수의 반환값이 바뀔때 마다 재랜더링 할 수 있다.

GoogleMaps를 보조해주는 Geolocator 플러그인 기능이 정말 좋았다.
1. 현재 사용자의 위치를 Stream을 이용한 위도 경도 값이 바뀌는 것에 따른 실시간 재랜더링
2. 현재 사용자가 위치를 Future 반환을 통해 한번만 가져올 수 있는 기능
3. 지정된 혹은 설정된 값들의 실제 거리를 반환해주는 기능 

등등 더 알아보면 좋은기능이 많을거란 기대감👍

Mokito를 통해 Geolocator의 Stream, Future값을 테스트 코드 작성으로 알고 싶었는데 아직 배움이 부족하다!