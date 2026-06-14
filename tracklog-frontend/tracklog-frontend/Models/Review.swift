import Foundation

//  Review Model
struct Review: Identifiable, Codable {
    let id: Int
    let trackId: String
    let userId: Int
    let nickname: String?
    let rating: Double
    let content: String?
    let createdAt: String?
    let updatedAt: String?
    let trackName: String?
    let artist: String?
    let albumImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case trackId
        case userId
        case nickname
        case rating
        case content
        case createdAt
        case updatedAt
        case trackName       
        case artist
        case albumImageUrl
    }
    
    // 날짜 포맷팅
    /*
    var formattedDate: String {
        guard let dateString = createdAt else {
            return ""
        }
        
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy.MM.dd"
        displayFormatter.locale = Locale(identifier: "ko_KR")
        return displayFormatter.string(from: date)
    }
     */
    var simpleFormattedDate: String {
            guard let dateString = createdAt else {
                return ""
            }
            
            if let dateOnly = dateString.components(separatedBy: "T").first {
                    // 2. 대시(-)를 점(.)으로 바꾸어 "2026.06.13" 포맷으로 변경합니다.
                    return dateOnly.replacingOccurrences(of: "-", with: ".")
           }
           return dateString
            /*
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy.MM.dd"
            displayFormatter.locale = Locale(identifier: "ko_KR")
            return displayFormatter.string(from: date)
             */
        }
    
    // 평점 별표시
    var ratingStars: String {
        let fullStars = Int(rating)
        let hasHalfStar = (rating - Double(fullStars)) >= 0.5
        
        var stars = String(repeating: "★", count: fullStars)
        if hasHalfStar {
            stars += "☆"
        }
        let emptyStars = 5 - stars.count
        stars += String(repeating: "☆", count: emptyStars)
        
        return stars
    }
}

// Review Request (작성/수정)
struct ReviewRequest: Codable {
    let trackId: String
    let rating: Double
    let content: String?
}

// Review Response (단일)
struct ReviewResponse: Codable {
    let success: Bool
    let data: Review
}

// Review List Response (페이지네이션)
struct ReviewListResponse: Codable {
    let success: Bool
    let data: ReviewListData
}

struct ReviewListData: Codable {
    let content: [Review]
    let totalElements: Int
    let totalPages: Int
    let size: Int
    let number: Int
    let first: Bool
    let last: Bool
    let empty: Bool
}

//  Review Statistics
struct ReviewStatistics: Codable {
    let averageRating: Double
    let reviewCount: Int
    let ratingDistribution: [Int: Int]
    
    enum CodingKeys: String, CodingKey {
        case averageRating
        case reviewCount
        case ratingDistribution
    }
    
    // 평균 평점 포맷팅
    var formattedAverageRating: String {
        return String(format: "%.1f", averageRating)
    }
}

struct ReviewStatisticsResponse: Codable {
    let success: Bool
    let data: ReviewStatistics
}
