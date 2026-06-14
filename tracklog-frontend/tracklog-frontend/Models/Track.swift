import Foundation

// Track Model
struct Track: Codable, Hashable {
    let id: Int?
    let spotifyId: String
    let name: String
    let artist: String
    let album: String
    let albumImageUrl: String?
    let durationMs: Int?
    let previewUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case spotifyId
        case name
        case artist
        case album
        case albumImageUrl
        case durationMs
        case previewUrl
    }
    
    // 재생 시간 포맷 (3:45)
    var formattedDuration: String {
        guard let ms = durationMs else { return "0:00" }
        let minutes = ms / 60000
        let seconds = (ms % 60000) / 1000
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Identifiable 지원 (SwiftUI List용)
extension Track: Identifiable {
    var identifier: String {
        spotifyId
    }
}

// Track Search Response
struct TrackSearchResponse: Codable {
    let success: Bool
    let data: [Track]
}

// Single Track Response
struct SingleTrackResponse: Codable {
    let success: Bool
    let data: Track
}
