import Foundation

class MusicService {
    
    static let shared = MusicService()
    
    private init() {}
    
    //음악 검색
    // 음악 검색
    func searchTracks(query: String, limit: Int = 10) async throws -> [Track] {
        //limit 값 검증
        var validLimit = limit
        if validLimit < 1 {
            validLimit = 10
        }
        if validLimit > 50 {
            validLimit = 50
        }
        
        //URL 인코딩 개선
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NetworkError.invalidURL
        }
        
        let endpoint = "\(Constants.Endpoints.musicSearch)?query=\(encodedQuery)&limit=\(validLimit)"
        
        //let endpoint = "/music/search?query=its&limit=10"
        
        //let endpoint = "/music/search?query=adele&limit=20"

        
        print("검색 요청 - Query: \(query), Limit: \(validLimit)")
        print("요청 URL: \(endpoint)")
        
        let response: TrackSearchResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: false
        )
        
        print("검색 성공: \(response.data.count)개")
        
        return response.data
    }
    
    //트랙 상세 조회
    func getTrack(trackId: String) async throws -> Track {
        let endpoint = "\(Constants.Endpoints.trackDetail)/\(trackId)"
        
        let response: SingleTrackResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: true
        )
        
        return response.data
    }
    // 인기 음악 조회
    func getPopularTracks(limit: Int = 20) async throws -> [Track] {
        let endpoint = "\(Constants.Endpoints.popularMusic)?limit=\(limit)"
        
        print("인기 음악 요청")
        
        let response: TrackSearchResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: false
        )
        
        print("인기 음악 조회 성공: \(response.data.count)개")
        
        return response.data
    }
}
