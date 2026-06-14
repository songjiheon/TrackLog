import Foundation

class PlaylistService {

    static let shared = PlaylistService()
    private init() {}

    // MARK: - 플레이리스트 생성
    struct PlaylistCreateRequest: Codable {
        let name: String
        let description: String?
        let isPublic: Bool?
    }

    func createPlaylist(
        name: String,
        description: String? = nil,
        isPublic: Bool? = nil
    ) async throws -> PlaylistResponse {
        let endpoint = "/playlists"
        let body = PlaylistCreateRequest(name: name, description: description, isPublic: isPublic)

        print("플레이리스트 생성 요청: \(name)")

        let response: PlaylistCreateResponse = try await NetworkManager.shared.post(
            endpoint: endpoint,
            body: body,
            needsAuth: true
        )

        return response.data
    }

    // MARK: - 내 플레이리스트 목록
    func getMyPlaylists() async throws -> [PlaylistResponse] {
        let endpoint = "/playlists"

        print("내 플레이리스트 목록 조회")

        let response: PlaylistListResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: true
        )

        return response.data
    }

    // MARK: - 내 + 공개 플레이리스트 목록 (있다면)
    func getMyAndPublicPlaylists() async throws -> [PlaylistResponse] {
        let endpoint = "/playlists/explore"

        print("내 + 공개 플레이리스트 목록 조회")

        let response: PlaylistListResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: true
        )

        return response.data
    }

    // MARK: - 플레이리스트 상세
    func getPlaylistDetail(playlistId: Int) async throws -> PlaylistDetail {
        let endpoint = "/playlists/\(playlistId)"

        print("플레이리스트 상세 조회: \(playlistId)")

        let response: PlaylistDetailResponse = try await NetworkManager.shared.get(
            endpoint: endpoint,
            needsAuth: true
        )

        return response.data
    }

    // 플레이리스트 수정
    func updatePlaylist(
        playlistId: Int,
        name: String? = nil,
        description: String? = nil,
        isPublic: Bool? = nil
    ) async throws {
        let endpoint = "/playlists/\(playlistId)"

        struct PlaylistUpdateRequest: Codable {
            let name: String?
            let description: String?
            let isPublic: Bool?
        }

        let body = PlaylistUpdateRequest(name: name, description: description, isPublic: isPublic)

        print("플레이리스트 수정 요청: \(playlistId)")

        let _: PlaylistSimpleMessageResponse = try await NetworkManager.shared.put(
            endpoint: endpoint,
            body: body,
            needsAuth: true
        )
    }

    //  플레이리스트 삭제
    func deletePlaylist(playlistId: Int) async throws {
        let endpoint = "/playlists/\(playlistId)"

        print("플레이리스트 삭제 요청: \(playlistId)")

        let _: PlaylistSimpleMessageResponse = try await NetworkManager.shared.delete(
            endpoint: endpoint,
            needsAuth: true
        )
    }

    // 트랙 추가 (spotifyId 기준)
    func addTrackToPlaylist(playlistId: Int, spotifyId: String) async throws {
        let endpoint = "/playlists/\(playlistId)/tracks"

        struct AddTrackRequest: Codable {
            let spotifyId: String
        }

        let body = AddTrackRequest(spotifyId: spotifyId)

        print("플레이리스트 트랙 추가 요청: playlistId=\(playlistId), spotifyId=\(spotifyId)")

        let _: PlaylistSimpleMessageResponse = try await NetworkManager.shared.post(
            endpoint: endpoint,
            body: body,
            needsAuth: true
        )
    }

    // 트랙 제거 (trackId = Track.id)
    func removeTrackFromPlaylist(playlistId: Int, trackId: Int) async throws {
        let endpoint = "/playlists/\(playlistId)/tracks/\(trackId)"

        print("플레이리스트 트랙 제거 요청: playlistId=\(playlistId), trackId=\(trackId)")

        let _: PlaylistSimpleMessageResponse = try await NetworkManager.shared.delete(
            endpoint: endpoint,
            needsAuth: true
        )
    }

    //  트랙 순서 재정렬
    func reorderTracks(playlistId: Int, trackIds: [Int]) async throws {
        let endpoint = "/playlists/\(playlistId)/tracks/reorder"

        struct ReorderRequest: Codable {
            let trackIds: [Int]
        }

        let body = ReorderRequest(trackIds: trackIds)

        print("플레이리스트 트랙 재정렬 요청: playlistId=\(playlistId), trackIds=\(trackIds)")

        let _: PlaylistSimpleMessageResponse = try await NetworkManager.shared.post(
            endpoint: endpoint,
            body: body,
            needsAuth: true
        )
    }
}
