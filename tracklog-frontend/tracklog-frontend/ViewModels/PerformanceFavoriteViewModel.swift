import Foundation
import SwiftUI
import Combine

@MainActor
class PerformanceFavoriteViewModel: ObservableObject {
    
    @Published var favorites: [PerformanceFavorite] = []
    @Published var favoriteStatus: [Int: Bool] = [:] // Key를 performanceId(Int)로 관리합니다.
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 관심 공연 토글
    func toggleFavorite(performanceId: Int) async {
        do {
            let isFavorited = try await PerformanceFavoriteService.shared.toggleFavorite(performanceId: performanceId)
            
            // 딕셔너리 상태 업데이트
            favoriteStatus[performanceId] = isFavorited
            
            // 관심 해제된 경우 목록 배열에서도 실시간으로 삭제 연동
            if !isFavorited {
                favorites.removeAll { $0.performanceId == performanceId }
            }
            
            print(isFavorited ? "공연 관심 추가됨" : "공연 관심 취소됨")
            
        } catch {
            errorMessage = "관심 공연 처리 실패: \(error.localizedDescription)"
            print("관심 공연 토글 실패 오류: \(error)")
        }
    }
    
    // 관심 등록 상태 확인
    func checkFavoriteStatus(performanceId: Int) async {
        do {
            let isFavorited = try await PerformanceFavoriteService.shared.checkFavoriteStatus(performanceId: performanceId)
            favoriteStatus[performanceId] = isFavorited
        } catch {
            print("공연 관심 상태 확인 실패: \(error)")
        }
    }
    
    // MARK: - 관심 공연 목록 조회
    func fetchFavorites() async {
        isLoading = true
        errorMessage = nil
        
        do {
            favorites = try await PerformanceFavoriteService.shared.getFavorites()
            
            // 조회된 목록을 기반으로 로컬 상태 맵 최신화
            for favorite in favorites {
                favoriteStatus[favorite.performanceId] = true
            }
            
            print("관심 공연 목록 로드 성공: \(favorites.count)개")
            
        } catch {
            errorMessage = "관심 공연 목록 조회 실패: \(error.localizedDescription)"
            print("관심 공연 목록 로드 실패 오류: \(error)")
        }
        
        isLoading = false
    }
    
    //  관심 여부 확인 (UI 바인딩용 헬퍼)
    func isFavorited(performanceId: Int) -> Bool {
        return favoriteStatus[performanceId] ?? false
    }
}
