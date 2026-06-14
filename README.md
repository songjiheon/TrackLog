# TrackLog 🎵

Spotify 및 KOPIS API 연동을 통한 취향 맞춤형 음악 아카이빙 및 공연 정보 통합 플랫폼

## 📌 프로젝트 소개

TrackLog는 사용자의 음악 취향 데이터를 기반으로 개인화된 음악 아카이빙 경험을 제공하고, 선호 아티스트 및 사용자 위치에 맞춘 공연 정보를 통합 제공하는 iOS 애플리케이션입니다.

## 🎯 프로젝트 목표

- 사용자 취향 데이터 연동 및 개인화
- 음악 별점 및 리뷰 시스템 구축
- 공연 정보 제공

## 프로젝트 화면

## 로그인 화면 & 메인 화면

<p>
  <img src="https://github.com/user-attachments/assets/ae0720a9-6e6a-4938-844f-a2f7a6ebb446" width="220">
  <img src="https://github.com/user-attachments/assets/b3e7e41d-7746-4ad9-853e-fd9c3086c8e9" width="220">
</p>

---
## 음악 탐색 화면 & 공연 화면
<p>
  <img src="https://github.com/user-attachments/assets/67d1eee9-4785-4d0c-b57d-3fb578eb719b"width="220">
  <img src="https://github.com/user-attachments/assets/2351fe28-dbd8-4f70-ba30-f5b2b044846c" width="220">
  <img src="https://github.com/user-attachments/assets/f1561884-32b4-4d21-8009-d877066ee9c5" width="220">
</p>

---



## 리뷰 작성 & 플레이리스트 생성 화면
<p>
<img src="https://github.com/user-attachments/assets/bc35ea38-054d-4720-84af-005c16fd2787"width="220">
<img src="https://github.com/user-attachments/assets/76c66599-18e7-4a40-b970-ae9fb5d9472e" width="220">
<img src="https://github.com/user-attachments/assets/218e9307-81da-47a6-90cf-73381a4c4d70" width="220">
</p>

---
## 프로필 화면
<p>
<img src="https://github.com/user-attachments/assets/65b34f94-c6b1-4b58-9b6a-e8886237b42c" width="220">
</p>

## ✨ 주요 기능

### 1. 사용자 인증 및 프로필 관리
- 회원가입 / 로그인
- 사용자 프로필 관리

### 2. 음악 검색 및 평점 & 리뷰 시스템
- Spotify Web API를 통한 음악 정보 검색 및 제공
- 음악별 별점 및 리뷰 작성 기능
- 다른 사용자들의 별점 및 리뷰 확인
- 리뷰(평점/평가) 데이터베이스 구축

### 3. 아티스트 공연 정보 제공
- KOPIS API를 활용한 국내 공연 정보 수집
- 관심 공연 설정 
- 공연 중&공연 예정 확인 가능

## 🚀 기대 효과

- 음악 데이터 통합으로 사용성 향상
- 맞춤형 문화생활 추천 및 티켓팅 성공률 향상
- 위치 기반의 직관적인 문화 정보 탐색
- 커뮤니티 기능을 통한 사용자 간 소통 및 서비스 지속 성장

## 🛠 기술 스택

### Frontend (iOS)
- Swift, SwiftUI
- Xcode

### Backend
- Java, Spring Boot
- Spring Security, Spring Data JPA
- MySQL
- Docker

### External API
- Spotify Web API
- KOPIS API (공연예술통합전산망)

### 📂 프로젝트 구조 (Project Structure)

```text
tracklog-backend/
├── controller/   # API 엔드포인트 (Music, Performance, Auth)
├── service/      # 비즈니스 로직 (Spotify/KOPIS 연동, 리뷰 처리)
├── repository/   # JPA Repository
├── domain/       # Entity (User, Review, Performance 등)
├── dto/          # 요청/응답 DTO
└── config/       # Security, OAuth2 설정

tracklog-frontend/
├── Views/        # SwiftUI 화면
├── ViewModels/   # 비즈니스 로직 및 상태 관리
├── Models/       # 데이터 구조 및 객체 모델
├── Services      # API 통신 및 외부 서비스 연동
├── Common        # 앱 전반에서 재사용되는 공통 UI/디자인 시스템
└── Utils/        # Extension 클래스
```

## 유튜브
[📺 ppt 발표 영상 ](https://www.youtube.com/watch?v=IndBNQJSLB4)




