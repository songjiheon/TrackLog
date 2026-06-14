//  API 엔드포인트와 상수 관리

import Foundation

struct Constants {
    // 백엔드 서버 URL
    static let baseURL = "http://127.0.0.1:8080/api/v1"
    
    // API Endpoints
    struct Endpoints {
        // 인증
        static let login = "/auth/login"
        static let changePassword = "/auth/password"
        
        // 음악 (Spotify)
        static let musicSearch = "/music/search"
        static let trackDetail = "/music/track"
        static let popularMusic = "/music/popular"
        static let favorites = "/music/favorites"
        
        // 사용자
        static let signUp = "/users"
        static let userProfile = "/users"  // GET /users/{id}
        
        // 공연
        static let performances = "/performances"
        static let performanceDetail = "/performances"  // GET /performances/{id}
        static let ongoingPerformances = "/performances/ongoing"
        static let upcomingPerformances = "/performances/upcoming"
        static let searchPerformances = "/performances/search"
        
        // 리뷰
        static let reviews = "/reviews"
        static let myReviews = "/reviews/my"
        static let trackReviews = "/reviews/track"  // GET /reviews/track/{trackId}
        static let reviewStatistics = "/reviews/track"  // GET /reviews/track/{trackId}/statistics
    }
    
    // Keychain Keys
    struct Keychain {
        static let accessToken = "tracklog.accessToken"
        static let refreshToken = "tracklog.refreshToken"
        static let userId = "tracklog.userId"
    }
    
    // UserDefaults Keys
    struct UserDefaultsKeys {
        static let isLoggedIn = "isLoggedIn"
        static let username = "username"
        static let email = "email"
    }
    
    // 페이지네이션 기본값
    struct Pagination {
        static let defaultPageSize = 20
        static let defaultPage = 0
    }
}
