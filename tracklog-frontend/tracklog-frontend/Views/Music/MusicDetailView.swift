import SwiftUI

//  음악 상세 정보 및 리뷰 화면
struct MusicDetailView: View {
    let track: Track
    @Environment(\.dismiss) var dismiss
    @StateObject private var reviewViewModel = ReviewViewModel()
    @State private var showWriteReview = false
    @StateObject private var favoriteViewModel = FavoriteViewModel()
    
    @StateObject private var playlistViewModel = PlaylistViewModel()
    @State private var showingPlaylistSelect = false

    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // 앨범 커버 & 기본 정보
                    MusicHeaderView(track: track)
                    
                    // 평점 통계
                    if let statistics = reviewViewModel.statistics {
                        RatingStatisticsView(statistics: statistics)
                    }
                    
                    // 리뷰 작성 버튼
                    WriteReviewButton(showWriteReview: $showWriteReview)
                    
                    // 리뷰 목록
                    ReviewListSection(reviews: reviewViewModel.reviews, isLoading: reviewViewModel.isLoading)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            Task {
                                await favoriteViewModel.toggleFavorite(spotifyId: track.spotifyId)
                            }
                        }) {
                            Image(systemName: favoriteViewModel.isFavorited(spotifyId: track.spotifyId) ? "heart.fill" : "heart")
                                .foregroundColor(favoriteViewModel.isFavorited(spotifyId: track.spotifyId) ?
                                                Color(hex: "#E22134") : AppTheme.textPrimary)
                                .font(.system(size: 20))
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingPlaylistSelect = true
                        }) {
                            Image(systemName: "text.badge.plus") //. 또는 "music.note.list"
                                .foregroundColor(AppTheme.textPrimary)
                                .font(.system(size: 20))
                        }
                    }
            
                }
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showWriteReview) {
            ReviewWriteView(track: track)
        }.sheet(isPresented: $showingPlaylistSelect){
            PlaylistSelectView(
                    track: track,
                    playlistViewModel: playlistViewModel
                )
        }
        .task {
            await reviewViewModel.fetchTrackReviews(trackId: track.spotifyId)
            await reviewViewModel.fetchTrackStatistics(trackId: track.spotifyId)
            await favoriteViewModel.checkFavoriteStatus(spotifyId: track.spotifyId)
        }
    }
}

// 음악 헤더
struct MusicHeaderView: View {
    let track: Track
    
    var body: some View {
        VStack(spacing: 20) {
            // 앨범 커버
            if let imageUrl = track.albumImageUrl, let url = URL(string: imageUrl) {
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
                .frame(width: 200, height: 200)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            } else {
                Rectangle()
                    .fill(AppTheme.cardBackground)
                    .frame(width: 200, height: 200)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.textTertiary)
                    )
            }
            
            // 곡 정보
            VStack(spacing: 8) {
                Text(track.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(track.artist)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(track.album)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textTertiary)
                
                Text(track.formattedDuration)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textTertiary)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 30)
    }
}

// 평점 통계
struct RatingStatisticsView: View {
    let statistics: ReviewStatistics
    
    var body: some View {
        VStack(spacing: 20) {
            // 평균 평점
            VStack(spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(statistics.formattedAverageRating)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.primary)
                }
                
                Text("\(statistics.reviewCount)개의 평가")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            // 평점 분포
            VStack(spacing: 8) {
                ForEach((1...5).reversed(), id: \.self) { rating in
                    let count = statistics.ratingDistribution[rating] ?? 0
                    RatingBarView(rating: rating, count: count, total: statistics.reviewCount)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 25)
        .background(AppTheme.secondaryBackground)
    }
}

// 평점 바
struct RatingBarView: View {
    let rating: Int
    let count: Int
    let total: Int
    
    var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Text("\(rating)")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 15)
            
            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(AppTheme.primary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.cardBackground)
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(AppTheme.primary)
                        .frame(width: geometry.size.width * percentage, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            Text("\(count)")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// 리뷰 작성 버튼
struct WriteReviewButton: View {
    @Binding var showWriteReview: Bool
    
    var body: some View {
        Button(action: {
            showWriteReview = true
        }) {
            HStack {
                Image(systemName: "square.and.pencil")
                Text("리뷰 작성하기")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.primary)
            .cornerRadius(25)
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
    }
}

// 리뷰 목록 섹션
struct ReviewListSection: View {
    let reviews: [Review]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("리뷰")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if reviews.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.textTertiary)
                    Text("첫 번째 리뷰를 작성해보세요")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
            } else {
                VStack(spacing: 15) {
                    ForEach(reviews) { review in
                        NavigationLink(destination: ReviewDetailView(review: review)) {
                            DetailReviewCardView(review: review)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 30)
    }
}

// 상세 리뷰 카드
struct DetailReviewCardView: View {
    let review: Review
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(AppTheme.cardBackground)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(AppTheme.textTertiary)
                            .font(.system(size: 18))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.nickname ?? "익명")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(review.rating) ? "star.fill" : "star")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                        
                        Text(review.simpleFormattedDate)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }
                
                Spacer()
            }
            
            if let content = review.content, !content.isEmpty {
                Text(content)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(isExpanded ? nil : 3)
                
                if content.count > 100 && !isExpanded {
                    Button(action: {
                        withAnimation {
                            isExpanded = true
                        }
                    }) {
                        Text("더보기")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}

// 리뷰 상세 화면
struct ReviewDetailView: View {
    let review: Review
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 사용자 정보
                    HStack(spacing: 15) {
                        Circle()
                            .fill(AppTheme.cardBackground)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(AppTheme.textTertiary)
                                    .font(.system(size: 22))
                            )
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(review.nickname ?? "익명")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text(review.simpleFormattedDate)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(12)
                    
                    // 평점
                    HStack(spacing: 5) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(review.rating) ? "star.fill" : "star")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 5)
                    
                    // 리뷰 내용
                    if let content = review.content, !content.isEmpty {
                        Text(content)
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textPrimary)
                            .lineSpacing(5)
                    } else {
                        Text("작성된 리뷰가 없습니다.")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textTertiary)
                            .italic()
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("리뷰 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct MusicDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MusicDetailView(track: Track(
                id: 1,
                spotifyId: "test",
                name: "테스트 곡",
                artist: "아티스트",
                album: "앨범",
                albumImageUrl: nil,
                durationMs: 180000,
                previewUrl: nil
            ))
        }
    }
}
struct PlaylistSelectView: View {
    let track: Track
    @ObservedObject var playlistViewModel: PlaylistViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if isLoading && playlistViewModel.myPlaylists.isEmpty {
                        CommonLoadingView(message: "플레이리스트 불러오는 중...")
                    } else if let error = errorMessage {
                        CommonErrorView(message: error) {
                            Task {
                                await loadPlaylists()
                            }
                        }
                    } else if playlistViewModel.myPlaylists.isEmpty {
                        CommonEmptyView(
                            icon: "text.badge.plus",
                            title: "플레이리스트가 없습니다",
                            description: "플레이리스트 화면에서 먼저 하나 만들어보세요."
                        )
                        .padding()
                    } else {
                        List {
                            ForEach(playlistViewModel.myPlaylists) { playlist in
                                Button {
                                    Task {
                                        await addTrack(to: playlist)
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(playlist.name)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(AppTheme.textPrimary)
                                            
                                            if let desc = playlist.description, !desc.isEmpty {
                                                Text(desc)
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(AppTheme.textSecondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                        Spacer()
                                        Text("\(playlist.trackCount)곡")
                                            .font(.system(size: 12))
                                            .foregroundStyle(AppTheme.textTertiary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .listRowBackground(AppTheme.cardBackground)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("플레이리스트에 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
            }
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task {
                await loadPlaylists()
            }
        }
    }
    
    
    private func loadPlaylists() async {
        isLoading = true
        errorMessage = nil
        do {
            await playlistViewModel.fetchMyPlaylists()
        } catch {
            errorMessage = "플레이리스트 로드 실패: \(error.localizedDescription)"
        }
        print("플리 선택 화면 - myPlaylists 개수: \(playlistViewModel.myPlaylists.count)")
        isLoading = false
    }
    
    private func addTrack(to playlist: PlaylistResponse) async {
        isLoading = true
        errorMessage = nil
        do {
            try await PlaylistService.shared.addTrackToPlaylist(
                playlistId: playlist.id,
                spotifyId: track.spotifyId
            )
            dismiss()
        } catch {
            errorMessage = "추가 실패: \(error.localizedDescription)"
            print("플레이리스트 추가 실패:", error)
        }
        isLoading = false
    }
}
