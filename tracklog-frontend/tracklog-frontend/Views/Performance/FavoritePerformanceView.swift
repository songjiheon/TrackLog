import SwiftUI

//  관심 공연 목록 화면
struct FavoritePerformanceView: View {
    @StateObject private var performanceFavoriteViewModel = PerformanceFavoriteViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 15) {
                    if performanceFavoriteViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                            .padding()
                    } else if performanceFavoriteViewModel.favorites.isEmpty {
                        CommonEmptyView(
                            icon: "ticket.fill",
                            title: "관심 공연이 없습니다",
                            description: "마음에 드는 공연에 관심 등록을 해보세요"
                        )
                        .padding(.top, 50)
                    } else {
                        ForEach(performanceFavoriteViewModel.favorites) { favorite in
                            // 상세 화면 이동 )
                            NavigationLink(destination: PerformanceDetailView(performanceId: favorite.performanceId)) {
                                FavoritePerformanceRow(favorite: favorite)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("관심 공연")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await performanceFavoriteViewModel.fetchFavorites()
        }
    }
}

// 관심 공연 리스트
struct FavoritePerformanceRow: View {
    let favorite: PerformanceFavorite
    
    var body: some View {
        HStack(spacing: 15) {
            // 공연 포스터 이미지
            if let posterUrl = favorite.posterUrl, let url = URL(string: posterUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(AppTheme.cardBackground)
                        .overlay(
                            Image(systemName: "theatermasks.fill")
                                .foregroundColor(AppTheme.textTertiary)
                        )
                }
                .frame(width: 50, height: 68) // 공연 포스터 최적화 비율
                .cornerRadius(6)
                .clipped()
            } else {
                Rectangle()
                    .fill(AppTheme.cardBackground)
                    .frame(width: 50, height: 68)
                    .cornerRadius(6)
                    .overlay(
                        Image(systemName: "theatermasks.fill")
                            .foregroundColor(AppTheme.textTertiary)
                    )
            }
            
            // 공연 메인 정보
            VStack(alignment: .leading, spacing: 5) {
                Text(favorite.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                if let place = favorite.place {
                    Text(place)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
                
                if let startDate = favorite.startDate {
                    Text("개막일: \(startDate)")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "ticket.fill")
                .foregroundColor(.purple)
                .font(.system(size: 18))
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(10)
    }
}
