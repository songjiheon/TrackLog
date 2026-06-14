import Foundation

class FavoriteService {
    
    static let shared = FavoriteService()
    
    private init() {}
    
    // 좋아요 토글
    func toggleFavorite(spotifyId: String) async throws -> Bool {
        let endpoint = "/favorites/\(spotifyId)"
        
        print("좋아요 토글 요청: \(spotifyId)")
        
        let response: FavoriteToggleResponse = try await NetworkManager.shared.post(
            endpoint: endpoint,
            body: nil as String?,
            needsAuth: true
        )
        
        print(response.data.isFavorited ? "좋아요 추가" : "좋아요 취소")
        
        return response.data.isFavorited
    }
    
    // 좋아요 상태 확인
    func checkFavoriteStatus(spotifyId: String) async throws -> Bool {
        let endpoint = "/favorites/\(spotifyId)/status"
        
        let response: FavoriteStatusResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: true
        )
        
        return response.data.isFavorited
    }
    
    // 좋아요 목록 조회
    func getFavorites(page: Int = 0, size: Int = 20) async throws -> [Favorite] {
        let endpoint = "/favorites?page=\(page)&size=\(size)"
        
        print("좋아요 목록 조회")
        
        let response: FavoriteListResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: true
        )
        
        print("좋아요 목록: \(response.data.content.count)개")
        
        return response.data.content
    }
}
