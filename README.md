# TrackLog 🎵

Spotify 및 KOPIS API 연동을 통한 취향 맞춤형 음악 아카이빙 및 위치 기반 공연 정보 통합 플랫폼

## 📌 프로젝트 소개

TrackLog는 사용자의 음악 취향 데이터를 기반으로 개인화된 음악 아카이빙 경험을 제공하고, 선호 아티스트 및 사용자 위치에 맞춘 공연 정보를 통합 제공하는 iOS 애플리케이션입니다.

## 🎯 프로젝트 목표

- 사용자 취향 데이터 연동 및 개인화
- 음악 별점 및 리뷰 시스템 구축
- 사용자 위치 기반 혹은 선호 아티스트의 공연 정보 제공

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

## 📂 프로젝트 구조

\```
tracklog-backend/
├── controller/   # API 엔드포인트 (Music, Performance, Auth)
├── service/      # 비즈니스 로직 (Spotify/KOPIS 연동, 리뷰 처리)
├── repository/   # JPA Repository
├── domain/       # Entity (User, Review, Performance 등)
├── dto/          # 요청/응답 DTO
└── config/       # Security, OAuth2 설정

tracklog-frontend/
├── Views/        # SwiftUI 화면
├── ViewModels/ #비즈니스 로직 및 상태 관리
├── Models/ # 데이터 구조 및 객체 모델
├── Services # API 통신 및 외부 서비스 연동
├──  Common # 앱 전반에서 재사용되는 공통 UI/디자인 시스템
└── Utils/      # Extension 클래스
\```
