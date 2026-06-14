import Foundation
import SwiftUI
import Combine  

@MainActor
class ReviewViewModel: ObservableObject {
    
    @Published var reviews: [Review] = []
    @Published var myReviews: [Review] = []
    @Published var recentReviews: [Review] = []
    @Published var selectedReview: Review?
    @Published var statistics: ReviewStatistics?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // 페이지네이션
    @Published var currentPage = 0
    @Published var totalPages = 0
    @Published var hasMore = true
    
    
    func fetchRecentReviews(page: Int = 0, size: Int = 10) async {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(Constants.Endpoints.reviews)?page=\(page)&size=\(size)"
        
        do {
            let response: ReviewListResponse = try await NetworkManager.shared.get(
                endpoint: endpoint,
                needsAuth: true // 비로그인 유저도 봐야 한다면 false로 변경
            )
            
            self.recentReviews = response.data.content
            print("전체 최신 리뷰 조회 성공: \(response.data.content.count)개")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("전체 최신 리뷰 조회 실패: \(error.errorDescription ?? "알 수 없는 오류")")
        } catch {
            self.errorMessage = "전체 최신 리뷰 조회 실패: \(error.localizedDescription)"
            print("전체 최신 리뷰 조회 실패: \(error)")
        }
        
        isLoading = false
    }
    
    
    // 리뷰 작성
    func createReview(trackId: String, rating: Double, content: String?) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        let request = ReviewRequest(trackId: trackId, rating: rating, content: content)
        
        do {
            let response: ReviewResponse = try await NetworkManager.shared.post(
                endpoint: Constants.Endpoints.reviews,
                body: request,
                needsAuth: true
            )
            
            self.successMessage = "리뷰가 작성되었습니다"
            print("리뷰 작성 성공: \(response.data.id)")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("리뷰 작성 실패: \(error.errorDescription ?? "알 수 없는 오류")")
        } catch {
            self.errorMessage = "리뷰 작성 실패: \(error.localizedDescription)"
            print("리뷰 작성 실패: \(error)")
        }
        
        isLoading = false
    }
    
    // 리뷰 수정
    func updateReview(reviewId: Int, trackId: String, rating: Double, content: String?) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        let request = ReviewRequest(trackId: trackId, rating: rating, content: content)
        
        do {
            let response: ReviewResponse = try await NetworkManager.shared.put(
                endpoint: "\(Constants.Endpoints.reviews)/\(reviewId)",
                body: request,
                needsAuth: true
            )
            
            self.successMessage = "리뷰가 수정되었습니다"
            print("리뷰 수정 성공: \(response.data.id)")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("리뷰 수정 실패: \(error.errorDescription ?? "알 수 없는 오류")")
        } catch {
            self.errorMessage = "리뷰 수정 실패: \(error.localizedDescription)"
            print("리뷰 수정 실패: \(error)")
        }
        
        isLoading = false
    }
    
    // 리뷰 삭제
    func deleteReview(reviewId: Int) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            struct EmptyResponse: Codable {}
            let _: ReviewResponse = try await NetworkManager.shared.delete(
                endpoint: "\(Constants.Endpoints.reviews)/\(reviewId)",
                needsAuth: true
            )
            
            self.successMessage = "리뷰가 삭제되었습니다"
            print("리뷰 삭제 성공: \(reviewId)")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("리뷰 삭제 실패: \(error.errorDescription ?? "알 수 없는 오류")")
        } catch {
            self.errorMessage = "리뷰 삭제 실패: \(error.localizedDescription)"
            print("리뷰 삭제 실패: \(error)")
        }
        
        isLoading = false
    }
    
    // 트랙 리뷰 목록 조회
    func fetchTrackReviews(trackId: String, page: Int = 0, size: Int = 10) async {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(Constants.Endpoints.trackReviews)/\(trackId)?page=\(page)&size=\(size)"
        
        do {
            let response: ReviewListResponse = try await NetworkManager.shared.get(
                endpoint: endpoint,
                needsAuth: false
            )
            
            self.reviews = response.data.content
            self.currentPage = response.data.number
            self.totalPages = response.data.totalPages
            self.hasMore = !response.data.last
            
            print("트랙 리뷰 조회 성공: \(response.data.content.count)개")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("트랙 리뷰 조회 실패: \(error.errorDescription ?? "알 수 없는 오류")")
        } catch {
            self.errorMessage = "트랙 리뷰 조회 실패: \(error.localizedDescription)"
            print("트랙 리뷰 조회 실패: \(error)")
        }
        
        isLoading = false
    }
    
    // 내 리뷰 목록 조회
    func fetchMyReviews(page: Int = 0, size: Int = 10) async {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(Constants.Endpoints.myReviews)?page=\(page)&size=\(size)"
        
        do {
            let response: ReviewListResponse = try await NetworkManager.shared.get(
                endpoint: endpoint,
                needsAuth: true
            )
            
            self.myReviews = response.data.content
            print("내 리뷰 조회 성공: \(response.data.content.count)개")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("내 리뷰 조회 실패: \(error.errorDescription ?? "알 수 없는 오류")")
        } catch {
            self.errorMessage = "내 리뷰 조회 실패: \(error.localizedDescription)"
            print("내 리뷰 조회 실패: \(error)")
        }
        
        isLoading = false
    }
    
    // 트랙 평점 통계 조회
    func fetchTrackStatistics(trackId: String) async {
        let endpoint = "\(Constants.Endpoints.reviewStatistics)/\(trackId)/statistics"
        
        do {
            let response: ReviewStatisticsResponse = try await NetworkManager.shared.get(
                endpoint: endpoint,
                needsAuth: false
            )
            
            self.statistics = response.data
            print("평점 통계 조회 성공: 평균 \(response.data.averageRating)")
            
        } catch let error as NetworkError {
            print("평점 통계 조회 실패: \(error.errorDescription ?? "알 수 없는 오류")")
        } catch {
            print("평점 통계 조회 실패: \(error)")
        }
    }
}
