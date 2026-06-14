import Foundation
import SwiftUI
import Combine

@MainActor
class MusicViewModel: ObservableObject {
    
    @Published var searchResults: [Track] = []
    @Published var popularTracks: [Track] = []
    @Published var selectedTrack: Track?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @MainActor
    func fetchPopularTracks() async {
        isLoading = true
        errorMessage = nil
            
        do {
            popularTracks = try await MusicService.shared.getPopularTracks(limit: 20)
            isLoading = false
            print("인기 음악 로드 완료: \(popularTracks.count)개")
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("인기 음악 로드 실패: \(error)")
        }
    }
    
    // 음악 검색
    func searchTracks(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let tracks = try await MusicService.shared.searchTracks(query: query, limit: 20)
            self.searchResults = tracks
            print("검색 성공: \(tracks.count)개 결과")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("검색 실패: \(error.errorDescription ?? "알 수 없는 오류")")
        } catch {
            self.errorMessage = "검색 실패: \(error.localizedDescription)"
            print("검색 실패: \(error)")
        }
        
        isLoading = false
    }
    
    //  트랙 상세 조회
    func fetchTrackDetail(trackId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let track = try await MusicService.shared.getTrack(trackId: trackId)
            self.selectedTrack = track
            print("트랙 조회 성공: \(track.name)")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("트랙 조회 실패: \(error.errorDescription ?? "알 수 없는 오류")")
        } catch {
            self.errorMessage = "트랙 조회 실패: \(error.localizedDescription)"
            print("트랙 조회 실패: \(error)")
        }
        
        isLoading = false
    }
}
