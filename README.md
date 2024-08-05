# taximate_frontend
대학생을 위한 택시 쉐어 플랫폼 "택시메이트"의 프론트엔드 리포지토리입니다.

## 프로젝트 소개
등하교시 버스나 지하철의 높은 인구 밀도로 
불편을 겪는 대학생들이 택시를 공유하여 </br>1/n 가격으로 저렴하게 이용할 수 있도록 도와주는 모바일 앱 서비스입니다.

## 프로젝트 개발 기간
* 2024.01 ~ 2024.07

## 개발 인원
* Jia Kwon (개인 프로젝트)

## 프론트엔드 개발 환경
- Dart 3.1.0
- Flutter 3.13.0

## dart packages
- flutter_localizations
- dio: ^5.4.0
- flutter_secure_storage: ^9.0.0
- json_annotation: ^4.8.1
- retrofit: '>=4.0.0 <5.0.0'
- logger: any  #for logging purpose
- flutter_riverpod: ^2.4.10
- font_awesome_flutter: ^10.6.0
- go_router: ^7.0.1
- flutter_email_sender: ^6.0.2
- package_info_plus: ^4.2.0

## 인증 로직 시퀀스 다이어그램
* 로그인
<img src="https://github.com/jia5232/KIRI_Backend/assets/83686088/3114dbc9-2cbb-440b-9440-683d96ab1a4a" width="400">
</br>
</br>
* 토큰 재발급
</br>
<img src="https://github.com/jia5232/KIRI_Backend/assets/83686088/f36a8236-b5ac-48f2-9a77-f881817e4fcb" width="400">

## 주요 기능 소개
<img width="252" alt="로그인" src="https://github.com/user-attachments/assets/d913a2a6-3d46-41ed-9b40-7646c4339276">
<img width="252" alt="대학교검색" src="https://github.com/user-attachments/assets/d7c95200-ee8f-4a29-a07c-9b0a4e7e3345">
</br>
* 대학교 이메일을 통해 인증 후 회원가입 및 로그인을 진행하여 서비스를 이용할 수 있습니다.
</br>
* Flutter의 secure storage와 riverpod을 활용해 인증 상태 관리를 구현했습니다.
</br>
</br>
</br>

<img width="252" alt="메인페이지" src="https://github.com/user-attachments/assets/bd812c42-d98d-4d32-935e-9c2123bd0f32">
<img width="252" alt="글 작성, 수정 폼" src="https://github.com/user-attachments/assets/c1cbcc5f-2b43-4d7a-8966-d92dc466b75d">
<img width="256" alt="글 상세" src="https://github.com/user-attachments/assets/34f62b9b-8608-405a-9119-e08cc6496e2d">
</br>
* 출발지 혹은 도착지를 설정하고 출발 시간, 소요 금액, 탑승 인원 등을 기재해 새로운 모임을 개설하거나, 기존에 이미 개설된 모임에 참여할 수 있습니다.
</br>
</br>
* 회원의 대학교에 따라 메인 페이지에 보이는 서비스명이 달라집니다. 
</br>(ex, 국민끼리, 성신끼리, 고려끼리)
</br>
</br>
</br>

<img width="252" alt="글 상세페이지" src="https://github.com/user-attachments/assets/06bf929a-f816-49f4-becd-e417548144f4">
</br>
* 모임에 참여하면 오픈채팅을 통해 약속장소를 정하고, 정산을 진행하여 택시를 저렴하게 이용할 수 있습니다.
</br>
</br>
</br>

<img width="252" alt="마이페이지" src="https://github.com/user-attachments/assets/99eaf1b9-afa0-4d07-a708-b8a43bb28522">
<br/>
* 마이페이지에서 회원 정보, 내가 작성한 글, 앱 정보, 문의하기, 로그아웃 등의 기능을 이용하고, 택시메이트로 절약한 금액을 확인할 수 있습니다.
</br>
* 또한 서비스 로직상 발생 가능한 예외 상황들을 처리하고 사용자에게 적절한 알림을 보내도록 구현했습니다.
</br>
* dio package가 제공하는 dio exception을 활용하여 예외 처리를 구현하였습니다.
