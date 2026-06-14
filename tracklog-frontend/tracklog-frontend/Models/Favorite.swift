import Foundation

struct Favorite: Identifiable, Codable {
    let id: Int
    let userId: Int
    let spotifyId: String
    let trackName: String
    let artist: String
    let album: String
    let albumImageUrl: String?
    let createdAt: String
    
    // Track으로 변환
    func toTrack() -> Track {
        return Track(
            id: nil,
            spotifyId: spotifyId,
            name: trackName,
            artist: artist,
            album: album,
            albumImageUrl: albumImageUrl,
            durationMs: 0,
            previewUrl: nil
        )
    }
}

// Favorite Response
struct FavoriteResponse: Codable {
    let success: Bool
    let data: Favorite
}

// Favorite List Response
struct FavoriteListResponse: Codable {
    let success: Bool
    let data: FavoriteListData
}

struct FavoriteListData: Codable {
    let content: [Favorite]
    let totalElements: Int
    let totalPages: Int
    let size: Int
    let number: Int
}

// Toggle Response
struct FavoriteToggleResponse: Codable {
    let success: Bool
    let data: FavoriteToggleData
}

struct FavoriteToggleData: Codable {
    let isFavorited: Bool
}

// Status Response
struct FavoriteStatusResponse: Codable {
    let success: Bool
    let data: FavoriteStatusData
}

struct FavoriteStatusData: Codable {
    let isFavorited: Bool
}
