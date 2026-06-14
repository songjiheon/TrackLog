import SwiftUI

//  공연 목록 화면
struct PerformanceListView: View {
    @StateObject private var viewModel = PerformanceViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: PerformanceFilter = .all
    @State private var showFilterSheet = false
    
    enum PerformanceFilter {
        case all
        case ongoing
        case upcoming
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 검색바
                    SearchBar(searchText: $searchText, onSearch: {
                        Task {
                            await viewModel.searchPerformances(keyword: searchText)
                        }
                    })
                    
                    // 필터 버튼
                    FilterButtons(selectedFilter: $selectedFilter) { filter in
                        Task {
                            await loadPerformances(filter: filter)
                        }
                    }
                    
                    // 공연 목록
                    if viewModel.isLoading && viewModel.performances.isEmpty {
                        CommonLoadingView(message: "공연 정보를 불러오는 중...")
                    } else if let error = viewModel.errorMessage {
                        CommonErrorView(message: error) {
                            Task {
                                await loadPerformances(filter: selectedFilter)
                            }
                        }
                    } else if viewModel.performances.isEmpty {
                        CommonEmptyView(
                            icon: "music.note.list",
                            title: "공연 정보가 없습니다",
                            description: "검색어를 변경하거나\n다른 필터를 선택해보세요"
                        )
                    } else {
                        // ← 이 부분 추가!
                        PerformanceList(viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("공연 정보")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            if viewModel.performances.isEmpty {
                await loadPerformances(filter: .all)
            }
        }
    
        
    }
    
    // 공연 로드
    func loadPerformances(filter: PerformanceFilter) async {
        switch filter {
        case .all:
            await viewModel.fetchPerformances(refresh: true)
        case .ongoing:
            await viewModel.fetchOngoingPerformances()
        case .upcoming:
            await viewModel.fetchUpcomingPerformances()
        }
    }
}

// 필터 버튼
struct FilterButtons: View {
    @Binding var selectedFilter: PerformanceListView.PerformanceFilter
    let onFilterChange: (PerformanceListView.PerformanceFilter) -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            FilterButton(
                title: "전체",
                isSelected: selectedFilter == .all
            ) {
                selectedFilter = .all
                onFilterChange(.all)
            }
            
            FilterButton(
                title: "공연중",
                isSelected: selectedFilter == .ongoing
            ) {
                selectedFilter = .ongoing
                onFilterChange(.ongoing)
            }
            
            FilterButton(
                title: "공연예정",
                isSelected: selectedFilter == .upcoming
            ) {
                selectedFilter = .upcoming
                onFilterChange(.upcoming)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// 필터 버튼 (개별)
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .black : AppTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primary : AppTheme.cardBackground)
                .cornerRadius(20)
        }
    }
}

// 공연 리스트
struct PerformanceList: View {
    @ObservedObject var viewModel: PerformanceViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(viewModel.performances) { performance in
                    NavigationLink(destination: PerformanceDetailView(performanceId: performance.id)) {
                        PerformanceCardView(performance: performance)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // 무한 스크롤 로딩
                if viewModel.hasMore && !viewModel.performances.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                            .padding()
                        Spacer()
                    }
                    .onAppear {
                        Task {
                            await viewModel.loadMore()
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// 공연 카드
struct PerformanceCardView: View {
    let performance: Performance
    @State private var imageLoadFailed = false
    
    var body: some View {
        HStack(spacing: 15) {
            // 포스터 이미지
            if let posterUrl = performance.posterUrl, let url = URL(string: posterUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(AppTheme.cardBackground)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                            )
                            .onAppear {
                                print("이미지 로딩 시작: \(posterUrl)")
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .onAppear {
                                print("이미지 로딩 성공: \(posterUrl)")
                            }
                    case .failure(let error):
                        Rectangle()
                            .fill(AppTheme.cardBackground)
                            .overlay(
                                VStack(spacing: 5) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 25))
                                        .foregroundColor(AppTheme.textTertiary)
                                    Text("로딩 실패")
                                        .font(.system(size: 9))
                                        .foregroundColor(AppTheme.textTertiary)
                                }
                            )
                            .onAppear {
                                print("이미지 로딩 실패: \(posterUrl)")
                                print("에러: \(error.localizedDescription)")
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 90, height: 120)
                .clipped()
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(AppTheme.cardBackground)
                    .frame(width: 90, height: 120)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(AppTheme.textTertiary)
                    )
                    .onAppear {
                        print("posterUrl 없음: \(performance.title)")
                    }
            }
            
            // 나머지 공연 정보는 동일...
            
            
            
            // 공연 정보
            VStack(alignment: .leading, spacing: 8) {
                // 제목
                Text(performance.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
                // 장소
                if let place = performance.place {
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textTertiary)
                        Text(place)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                // 날짜
                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                    Text(performance.formattedDateRange)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                // 상태 & 장르
                HStack(spacing: 8) {
                    if let state = performance.state {
                        Text(state)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(stateColor(state))
                            .cornerRadius(4)
                    }
                    
                    if let genre = performance.genre {
                        Text(genre)
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textTertiary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.secondaryBackground)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
    
    func stateColor(_ state: String) -> Color {
        switch state {
        case "공연중":
            return Color(hex: "#1DB954")
        case "공연예정":
            return Color(hex: "#3B82F6")
        case "공연완료":
            return Color(hex: "#6A6A6A")
        default:
            return Color(hex: "#6A6A6A")
        }
    }
}

// 로딩 뷰
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                .scaleEffect(1.5)
            
            Text("공연 정보를 불러오는 중...")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//  에러 뷰
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.error)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Text("다시 시도")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppTheme.primary)
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//  빈 화면
struct EmptyPerformanceView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.textTertiary)
            
            Text("공연 정보가 없습니다")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textSecondary)
            
            Text("검색어를 변경하거나\n다른 필터를 선택해보세요")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PerformanceListView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceListView()
    }
}
