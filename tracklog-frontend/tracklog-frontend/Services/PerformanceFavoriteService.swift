import Foundation

class PerformanceFavoriteService {
    
    static let shared = PerformanceFavoriteService()
    
    private init() {}
    
    // 관심 공연 토글 (추가/취소)
    func toggleFavorite(performanceId: Int) async throws -> Bool {
        let endpoint = "/performance-favorites/\(performanceId)"
        
        print("관심 공연 토글 요청 ID: \(performanceId)")
        
        let response: PerformanceFavoriteToggleResponse = try await NetworkManager.shared.post(
            endpoint: endpoint,
            body: nil as String?,
            needsAuth: true
        )
        
        print(response.data.isFavorited ? "관심 공연 추가 완료" : "관심 공연 취소 완료")
        
        return response.data.isFavorited
    }
    
    // 관심 등록 상태 확인
    func checkFavoriteStatus(performanceId: Int) async throws -> Bool {
        let endpoint = "/performance-favorites/\(performanceId)/status"
        
        let response: PerformanceFavoriteStatusResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: true
        )
        
        return response.data.isFavorited
    }
    
    // 관심 공연 목록 조회
    func getFavorites(page: Int = 0, size: Int = 20) async throws -> [PerformanceFavorite] {
        let endpoint = "/performance-favorites?page=\(page)&size=\(size)"
        
        print("관심 공연 목록 조회")
        
        let response: PerformanceFavoriteListResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: true
        )
        
        print("관심 공연 목록 개수: \(response.data.content.count)개")
        
        return response.data.content
    }
}
