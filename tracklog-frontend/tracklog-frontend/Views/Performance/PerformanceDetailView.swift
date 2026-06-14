import SwiftUI
import MapKit

//  공연 상세 정보 화면

struct PerformanceDetailView: View {
    let performanceId: Int
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PerformanceViewModel()
    
    // 관심 공연 전용 뷰모델 추가
    @StateObject private var favoriteViewModel = PerformanceFavoriteViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            if viewModel.isLoading {
                CommonLoadingView(message: "공연 정보를 불러오는 중...")
            } else if let error = viewModel.errorMessage {
                CommonErrorView(message: error) {
                    Task {
                        await viewModel.fetchPerformanceDetail(id: performanceId)
                    }
                }
            } else if let performance = viewModel.selectedPerformance {
                ScrollView {
                    VStack(spacing: 0) {
                        // 포스터 이미지
                        PosterImageView(posterUrl: performance.posterUrl)
                        
                        // 공연 정보
                        PerformanceInfoSection(performance: performance)
                        
                        // 공연 장소 정보
                        VenueSection(performance: performance)
                        
                        // 공연 상세 정보
                        DetailInfoSection(performance: performance)
                        
                        // 시놉시스
                        if let synopsis = performance.synopsis {
                            SynopsisSection(synopsis: synopsis)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // 버 연동 하트 버튼 액션
                Button(action: {
                    Task {
                        await favoriteViewModel.toggleFavorite(performanceId: performanceId)
                    }
                }) {
                    Image(systemName: favoriteViewModel.isFavorited(performanceId: performanceId) ? "heart.fill" : "heart")
                        .foregroundColor(favoriteViewModel.isFavorited(performanceId: performanceId) ? Color(.systemPink) : AppTheme.textPrimary)
                }
            }
        }
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await viewModel.fetchPerformanceDetail(id: performanceId)
                }
                group.addTask {
                    await favoriteViewModel.checkFavoriteStatus(performanceId: performanceId)
                }
            }
        }
    }
}



// 포스터 이미지
struct PosterImageView: View {
    let posterUrl: String?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let posterUrl = posterUrl, let url = URL(string: posterUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(AppTheme.cardBackground)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                        )
                }
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                .clipped()
            } else {
                Rectangle()
                    .fill(AppTheme.cardBackground)
                    .frame(height: 400)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.textTertiary)
                    )
            }
            
            LinearGradient(
                colors: [.clear, AppTheme.background.opacity(0.8), AppTheme.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 150)
        }
    }
}

// 공연 정보 섹션
struct PerformanceInfoSection: View {
    let performance: Performance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // 제목
            Text(performance.title)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal)
            
            // 상태 & 장르
            HStack(spacing: 10) {
                if let state = performance.state {
                    StateChip(state: state)
                }
                
                if let genre = performance.genre {
                    GenreChip(genre: genre)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
                .background(AppTheme.textTertiary.opacity(0.3))
                .padding(.horizontal)
        }
        .padding(.vertical, 20)
    }
}

// 상태 칩
struct StateChip: View {
    let state: String
    
    var body: some View {
        Text(state)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(stateColor)
            .cornerRadius(15)
    }
    
    var stateColor: Color {
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

//  장르 칩
struct GenreChip: View {
    let genre: String
    
    var body: some View {
        Text(genre)
            .font(.system(size: 13))
            .foregroundColor(AppTheme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.cardBackground)
            .cornerRadius(15)
    }
}

// 공연장 정보 섹션
struct VenueSection: View {
    let performance: Performance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionTitle(title: "공연장 정보")
            
            VStack(alignment: .leading, spacing: 12) {
                if let place = performance.place {
                    InfoRow(
                        icon: "location.fill",
                        title: "공연장",
                        value: place
                    )
                }
                
                if let area = performance.area {
                    InfoRow(
                        icon: "map.fill",
                        title: "지역",
                        value: area
                    )
                }
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
            
            Divider()
                .background(AppTheme.textTertiary.opacity(0.3))
                .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
}

// 상세 정보 섹션
struct DetailInfoSection: View {
    let performance: Performance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionTitle(title: "공연 상세")
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(
                    icon: "calendar",
                    title: "공연 기간",
                    value: performance.formattedDateRange
                )
                
                if let runtime = performance.runtime {
                    InfoRow(
                        icon: "clock.fill",
                        title: "공연 시간",
                        value: runtime
                    )
                }
                
                if let age = performance.age {
                    InfoRow(
                        icon: "person.fill",
                        title: "관람 연령",
                        value: age
                    )
                }
                
                if let cast = performance.cast {
                    InfoRow(
                        icon: "person.2.fill",
                        title: "출연진",
                        value: cast,
                        multiline: true
                    )
                }
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
            
            Divider()
                .background(AppTheme.textTertiary.opacity(0.3))
                .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
}

// 시놉시스 섹션
struct SynopsisSection: View {
    let synopsis: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionTitle(title: "공연 소개")
            
            VStack(alignment: .leading, spacing: 10) {
                Text(synopsis)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineSpacing(6)
                    .lineLimit(isExpanded ? nil : 5)
                
                if synopsis.count > 150 {
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        Text(isExpanded ? "접기" : "더보기")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .padding(.bottom, 30)
    }
}

// 섹션 타이틀
struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(AppTheme.textPrimary)
            .padding(.horizontal)
    }
}

//  정보 행
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var multiline: Bool = false
    
    var body: some View {
        HStack(alignment: multiline ? .top : .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textTertiary)
                
                Text(value)
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(multiline ? nil : 1)
            }
            
            Spacer()
        }
    }
}

struct PerformanceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PerformanceDetailView(performanceId: 1)
        }
    }
}
