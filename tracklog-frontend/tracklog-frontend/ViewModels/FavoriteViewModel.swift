import Foundation
import SwiftUI
import Combine

@MainActor
class FavoriteViewModel: ObservableObject {
    
    @Published var favorites: [Favorite] = []
    @Published var favoriteStatus: [String: Bool] = [:] // spotifyId: isFavorited
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 좋아요 토글
    func toggleFavorite(spotifyId: String) async {
        do {
            let isFavorited = try await FavoriteService.shared.toggleFavorite(spotifyId: spotifyId)
            
            // 상태 업데이트
            favoriteStatus[spotifyId] = isFavorited
            
            // 목록에서 제거/추가
            if !isFavorited {
                favorites.removeAll { $0.spotifyId == spotifyId }
            }
            
            print(isFavorited ? "좋아요 추가됨" : "좋아요 취소됨")
            
        } catch {
            errorMessage = "좋아요 처리 실패: \(error.localizedDescription)"
            print("좋아요 토글 실패: \(error)")
        }
    }
    
    //  좋아요 상태 확인
    func checkFavoriteStatus(spotifyId: String) async {
        do {
            let isFavorited = try await FavoriteService.shared.checkFavoriteStatus(spotifyId: spotifyId)
            favoriteStatus[spotifyId] = isFavorited
        } catch {
            print("좋아요 상태 확인 실패: \(error)")
        }
    }
    
    // 좋아요 목록 조회
    func fetchFavorites() async {
        isLoading = true
        errorMessage = nil
        
        do {
            favorites = try await FavoriteService.shared.getFavorites()
            
            // 상태 맵 업데이트
            for favorite in favorites {
                favoriteStatus[favorite.spotifyId] = true
            }
            
            print("좋아요 목록 로드 완료: \(favorites.count)개")
            
        } catch {
            errorMessage = "좋아요 목록 조회 실패: \(error.localizedDescription)"
            print("좋아요 목록 로드 실패: \(error)")
        }
        
        isLoading = false
    }
    
    //  좋아요 여부 확인 (로컬)
    func isFavorited(spotifyId: String) -> Bool {
        return favoriteStatus[spotifyId] ?? false
    }
}
