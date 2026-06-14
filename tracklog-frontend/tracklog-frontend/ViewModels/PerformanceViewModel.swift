import Foundation
import SwiftUI
import Combine

@MainActor
class PerformanceViewModel: ObservableObject {
    
    @Published var performances: [Performance] = []
    @Published var selectedPerformance: Performance?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 페이지네이션
    @Published var currentPage = 0
    @Published var totalPages = 0
    @Published var totalElements = 0
    @Published var hasMore = true
    
    // 공연 목록 조회
    func fetchPerformances(page: Int = 0, size: Int = 20, refresh: Bool = false) async {
        if refresh {
            performances = []
            currentPage = 0
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let pageData = try await PerformanceService.shared.getAllPerformances(
                page: page,
                size: size
            )
            
            if refresh {
                self.performances = pageData.content
            } else {
                self.performances.append(contentsOf: pageData.content)
            }
            
            self.currentPage = pageData.number
            self.totalPages = pageData.totalPages
            self.totalElements = pageData.totalElements
            self.hasMore = !pageData.last
            
            print("공연 목록 조회 성공: \(pageData.content.count)개")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("공연 목록 조회 실패: \(error.errorDescription ?? "")")
        } catch {
            self.errorMessage = "공연 목록 조회 실패"
            print("공연 목록 조회 실패: \(error)")
        }
        
        isLoading = false
    }
    
    // 공연 상세 조회
    func fetchPerformanceDetail(id: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let performance = try await PerformanceService.shared.getPerformance(id: id)
            self.selectedPerformance = performance
            print("공연 상세 조회 성공: \(performance.title)")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("공연 상세 조회 실패: \(error.errorDescription ?? "")")
        } catch {
            self.errorMessage = "공연 상세 조회 실패"
            print("공연 상세 조회 실패: \(error)")
        }
        
        isLoading = false
    }
    
    // 공연 중인 목록
    func fetchOngoingPerformances(page: Int = 0, size: Int = 20) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let pageData = try await PerformanceService.shared.getOngoingPerformances(
                page: page,
                size: size
            )
            
            self.performances = pageData.content
            self.totalElements = pageData.totalElements
            print("공연 중인 목록 조회 성공: \(pageData.content.count)개")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "공연 중인 목록 조회 실패"
        }
        
        isLoading = false
    }
    
    // MARK: - 공연 예정 목록
    func fetchUpcomingPerformances(page: Int = 0, size: Int = 20) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let pageData = try await PerformanceService.shared.getUpcomingPerformances(
                page: page,
                size: size
            )
            
            self.performances = pageData.content
            self.totalElements = pageData.totalElements
            print("공연 예정 목록 조회 성공: \(pageData.content.count)개")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "공연 예정 목록 조회 실패"
        }
        
        isLoading = false
    }
    
    // MARK: - 공연 검색
    func searchPerformances(keyword: String, page: Int = 0, size: Int = 20) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let pageData = try await PerformanceService.shared.searchPerformances(
                keyword: keyword,
                page: page,
                size: size
            )
            
            self.performances = pageData.content
            self.totalElements = pageData.totalElements
            print("공연 검색 성공: \(pageData.content.count)개")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
        } catch {
            self.errorMessage = "공연 검색 실패"
        }
        
        isLoading = false
    }
    
    // 다음 페이지 로드
    func loadMore() async {
        guard hasMore && !isLoading else { return }
        await fetchPerformances(page: currentPage + 1)
    }
}
