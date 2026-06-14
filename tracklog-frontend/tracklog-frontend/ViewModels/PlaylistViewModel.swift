import Foundation
import SwiftUI
import Combine

@MainActor
class PlaylistViewModel: ObservableObject {
    
    @Published var myPlaylists: [PlaylistResponse] = []
    @Published var explorePlaylists: [PlaylistResponse] = []
    @Published var selectedPlaylist: PlaylistDetail? = nil
    @Published var hasLoadedExplore = false
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var myPlaylistsTask: Task<Void, Never>?
    private var explorePlaylistsTask: Task<Void, Never>?
    private var detailTask: Task<Void, Never>?
    private var trackActionTask: Task<Void, Never>?
    
    // 내 플레이리스트 목록 조회
    func fetchMyPlaylists() async {
        myPlaylistsTask?.cancel()
        
        myPlaylistsTask = Task {
            guard !Task.isCancelled else { return }
            
            isLoading = true
            errorMessage = nil
            
            do {
                let list = try await PlaylistService.shared.getMyPlaylists()
                
                try Task.checkCancellation()
                
                self.myPlaylists = list
                print("내 플레이리스트 로드 완료: \(list.count)개")
            } catch is CancellationError {
                print("내 플레이리스트 조회 작업이 취소되었습니다.")
            } catch {
                guard !Task.isCancelled else { return }
                self.errorMessage = "플레이리스트 조회 실패: \(error.localizedDescription)"
                print("플레이리스트 조회 실패:", error)
            }
            
            isLoading = false
        }
        
        // Task가 완료될 때까지 대기
        await myPlaylistsTask?.value
    }
    
    func fetchExplorePlaylistsOnce() async {
        if hasLoadedExplore { return }
        hasLoadedExplore = true
        await fetchExplorePlaylists()
    }
    
    // 내 공개 플레이리스트 목록
    func fetchExplorePlaylists() async {
        explorePlaylistsTask?.cancel()
        
        explorePlaylistsTask = Task {
            guard !Task.isCancelled else { return }
            
            isLoading = true
            errorMessage = nil
            
            do {
                let list = try await PlaylistService.shared.getMyAndPublicPlaylists()
                
                try Task.checkCancellation()
                
                self.explorePlaylists = list
                print("Explore 플레이리스트 로드 완료: \(list.count)개")
            } catch is CancellationError {
                print("탐색 플레이리스트 조회 작업이 취소되었습니다.")
            } catch {
                guard !Task.isCancelled else { return }
                self.errorMessage = "플레이리스트 조회 실패: \(error.localizedDescription)"
                print("플레이리스트 조회 실패:", error)
            }
            
            isLoading = false
        }
        
        await explorePlaylistsTask?.value
    }
    
    // 플레이리스트 생성
    func createPlaylist(name: String, description: String? = nil, isPublic: Bool? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let created = try await PlaylistService.shared.createPlaylist(
                name: name,
                description: description,
                isPublic: isPublic
            )
            myPlaylists.insert(created, at: 0)
            print("플레이리스트 생성 완료: \(created.name)")
        } catch {
            errorMessage = "플레이리스트 생성 실패: \(error.localizedDescription)"
            print("플레이리스트 생성 실패:", error)
        }
        
        isLoading = false
    }
    
    // 플레이리스트 상세 조회
    func fetchPlaylistDetail(playlistId: Int) async {
        detailTask?.cancel()
        
        detailTask = Task {
            guard !Task.isCancelled else { return }
            
            isLoading = true
            errorMessage = nil
            
            do {
                let detail = try await PlaylistService.shared.getPlaylistDetail(playlistId: playlistId)
                
                try Task.checkCancellation()
                
                self.selectedPlaylist = detail
                print("플레이리스트 상세 로드 완료: \(detail.name)")
            } catch is CancellationError {
                print("상세 조회 작업이 취소되었습니다.")
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = "플레이리스트 상세 조회 실패: \(error.localizedDescription)"
                print("플레이리스트 상세 조회 실패:", error)
            }
            
            isLoading = false
        }
        
        await detailTask?.value
    }
    
    // 트랙 추가
    func addTrackToSelectedPlaylist(spotifyId: String) async {
        guard let playlist = selectedPlaylist else { return }
        
        trackActionTask?.cancel()
        
        trackActionTask = Task {
            isLoading = true
            errorMessage = nil
            
            do {
                try await PlaylistService.shared.addTrackToPlaylist(
                    playlistId: Int(playlist.id),
                    spotifyId: spotifyId
                )
                try Task.checkCancellation()
                await fetchPlaylistDetail(playlistId: Int(playlist.id))
            } catch is CancellationError {
                print("트랙 추가 작업이 취소되었습니다.")
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = "트랙 추가 실패: \(error.localizedDescription)"
                print("트랙 추가 실패:", error)
            }
            
            isLoading = false
        }
        
        await trackActionTask?.value
    }
    
    // 트랙 제거
    func removeTrackFromSelectedPlaylist(trackId: Int) async {
        guard let playlist = selectedPlaylist else { return }
        
        trackActionTask?.cancel()
        
        trackActionTask = Task {
            isLoading = true
            errorMessage = nil
            
            do {
                try await PlaylistService.shared.removeTrackFromPlaylist(
                    playlistId: Int(playlist.id),
                    trackId: trackId
                )
                try Task.checkCancellation()
                await fetchPlaylistDetail(playlistId: Int(playlist.id))
            } catch is CancellationError {
                print("트랙 제거 작업이 취소되었습니다.")
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = "트랙 제거 실패: \(error.localizedDescription)"
                print("트랙 제거 실패:", error)
            }
            
            isLoading = false
        }
        
        await trackActionTask?.value
    }
    
    // 트랙 순서 재정렬
    func reorderTracksInSelectedPlaylist(newOrder: [Track]) async {
        guard let playlist = selectedPlaylist else { return }
        let trackIds = newOrder.compactMap { $0.id }
        
        trackActionTask?.cancel()
        
        trackActionTask = Task {
            isLoading = true
            errorMessage = nil
            
            do {
                try await PlaylistService.shared.reorderTracks(
                    playlistId: Int(playlist.id),
                    trackIds: trackIds
                )
                try Task.checkCancellation()
                await fetchPlaylistDetail(playlistId: Int(playlist.id))
            } catch is CancellationError {
                print("트랙 정렬 작업이 취소되었습니다.")
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = "트랙 순서 변경 실패: \(error.localizedDescription)"
                print("트랙 순서 변경 실패:", error)
            }
            
            isLoading = false
        }
        
        await trackActionTask?.value
    }
    
    // 화면 해제 시 취소 처리
    deinit {
        myPlaylistsTask?.cancel()
        explorePlaylistsTask?.cancel()
        detailTask?.cancel()
        trackActionTask?.cancel()
    }
}
