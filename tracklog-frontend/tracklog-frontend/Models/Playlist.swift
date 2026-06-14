import Foundation

//  PlaylistResponseDto 대응 (목록/단건 공통)
struct PlaylistResponse: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String?
    let isPublic: Bool
    let trackCount: Int
    
    enum CodingKeys: String, CodingKey {
            case id
            case name
            case description
            case isPublic = "public"
            case trackCount
        }
}

// Playlist 상세 (tracks 포함 DTO는 서버에 따로 있을 것으로 가정)
struct PlaylistDetail: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String?
    let isPublic: Bool
    let tracks: [Track]   // 이미 쓰고 있는 Track 모델 재사용
    
    enum CodingKeys: String, CodingKey {
            case id
            case name
            case description
            case isPublic = "public" 
            case tracks
        }
}

// 공통 API 응답 래퍼

struct PlaylistListResponse: Codable {
    let success: Bool
    let data: [PlaylistResponse]
}

struct PlaylistDetailResponse: Codable {
    let success: Bool
    let data: PlaylistDetail
}

struct PlaylistCreateResponse: Codable {
    let success: Bool
    let data: PlaylistResponse
}

struct PlaylistSimpleMessageResponse: Codable {
    let success: Bool
    let data: String
}
