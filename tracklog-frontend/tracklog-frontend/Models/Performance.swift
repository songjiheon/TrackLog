import Foundation

// Performance Model
struct Performance: Identifiable, Codable {
    let id: Int
    let kopisId: String
    let title: String
    let genre: String?
    let state: String?
    let place: String?
    let area: String?
    let startDate: String?
    let endDate: String?
    let posterUrl: String?
    let cast: String?
    let runtime: String?
    let age: String?
    let synopsis: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case kopisId
        case title
        case genre
        case state
        case place
        case area
        case startDate
        case endDate
        case posterUrl
        case cast
        case runtime
        case age
        case synopsis
    }
    
    // 날짜 포맷팅
    var formattedDateRange: String {
        guard let start = startDate, let end = endDate else {
            return "날짜 미정"
        }
        
        if start == end {
            return formatDate(start)
        }
        return "\(formatDate(start)) ~ \(formatDate(end))"
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MM.dd"
            return formatter.string(from: date)
        }
        return dateString
    }
    
    // 공연 상태 표시
    var displayState: String {
        state ?? "알 수 없음"
    }
    
    // 상태별 색상
    var stateColor: String {
        switch state {
        case "공연중":
            return "green"
        case "공연예정":
            return "blue"
        case "공연완료":
            return "gray"
        default:
            return "gray"
        }
    }
}

// Performance Response (페이지네이션)
struct PerformancePageResponse: Codable {
    let success: Bool
    let data: PerformancePageData
}

struct PerformancePageData: Codable {
    let content: [Performance]
    let pageable: Pageable
    let totalElements: Int
    let totalPages: Int
    let size: Int
    let number: Int
    let first: Bool
    let last: Bool
    let empty: Bool
}

struct Pageable: Codable {
    let pageNumber: Int
    let pageSize: Int
    let offset: Int
    let paged: Bool
    let unpaged: Bool
}

// Single Performance Response
struct SinglePerformanceResponse: Codable {
    let success: Bool
    let data: Performance
}
