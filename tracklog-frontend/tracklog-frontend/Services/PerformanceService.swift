import Foundation

class PerformanceService {
    
    static let shared = PerformanceService()
    
    private init() {}
    
    // 공연 목록 조회
    func getAllPerformances(page: Int = 0, size: Int = 20, sort: String = "startDate", direction: String = "desc") async throws -> PerformancePageData {
        let endpoint = "\(Constants.Endpoints.performances)?page=\(page)&size=\(size)&sort=\(sort)&direction=\(direction)"
        
        let response: PerformancePageResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: false
        )
        
        return response.data
    }
    
    // 공연 상세 조회
    func getPerformance(id: Int) async throws -> Performance {
        let endpoint = "\(Constants.Endpoints.performances)/\(id)"
        
        let response: SinglePerformanceResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: false
        )
        
        return response.data
    }
    
    // 공연 중인 목록
    func getOngoingPerformances(page: Int = 0, size: Int = 20) async throws -> PerformancePageData {
        let endpoint = "\(Constants.Endpoints.ongoingPerformances)?page=\(page)&size=\(size)"
        
        let response: PerformancePageResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: false
        )
        
        return response.data
    }
    
    // 공연 예정 목록
    func getUpcomingPerformances(page: Int = 0, size: Int = 20) async throws -> PerformancePageData {
        let endpoint = "\(Constants.Endpoints.upcomingPerformances)?page=\(page)&size=\(size)"
        
        let response: PerformancePageResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: false
        )
        
        return response.data
    }
    
    // 공연 검색
    func searchPerformances(keyword: String, page: Int = 0, size: Int = 20) async throws -> PerformancePageData {
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        let endpoint = "\(Constants.Endpoints.searchPerformances)?keyword=\(encodedKeyword)&page=\(page)&size=\(size)"
        
        let response: PerformancePageResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: false
        )
        
        return response.data
    }
    
    // 장르별 조회
    func getPerformancesByGenre(genre: String, page: Int = 0, size: Int = 20) async throws -> PerformancePageData {
        let encodedGenre = genre.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? genre
        let endpoint = "/performances/genre/\(encodedGenre)?page=\(page)&size=\(size)"
        
        let response: PerformancePageResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: false
        )
        
        return response.data
    }
    
    // 지역별 조회
    func getPerformancesByArea(area: String, page: Int = 0, size: Int = 20) async throws -> PerformancePageData {
        let encodedArea = area.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? area
        let endpoint = "/performances/area/\(encodedArea)?page=\(page)&size=\(size)"
        
        let response: PerformancePageResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: false
        )
        
        return response.data
    }
}
