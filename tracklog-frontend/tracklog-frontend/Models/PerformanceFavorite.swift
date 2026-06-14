import Foundation

struct PerformanceFavorite: Identifiable, Codable {
    let id: Int
    let performanceId: Int       // 공연 고유 ID
    let kopisId: String          // KOPIS 공연 ID
    let title: String            // 공연명
    let genre: String?           // 장르
    let place: String?           // 공연장명
    let startDate: String?       // 시작일 ("2026-06-13" 형태)
    let posterUrl: String?       // 포스터 URL
    let createdAt: String?       // 관심 등록 일시
}

// API Response Wrapper
struct PerformanceFavoriteToggleResponse: Codable {
    let success: Bool
    let data: PerformanceFavoriteStatus
}

struct PerformanceFavoriteStatusResponse: Codable {
    let success: Bool
    let data: PerformanceFavoriteStatus
}

struct PerformanceFavoriteStatus: Codable {
    let isFavorited: Bool
}

struct PerformanceFavoriteListResponse: Codable {
    let success: Bool
    let data: PerformanceFavoriteListData
}

struct PerformanceFavoriteListData: Codable {
    let content: [PerformanceFavorite]
    let totalElements: Int
    let totalPages: Int
}
