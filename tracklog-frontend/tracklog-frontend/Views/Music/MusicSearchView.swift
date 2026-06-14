import SwiftUI

//  음악 검색 및 리뷰 메인 화면
struct MusicSearchView: View {
    @StateObject private var musicViewModel = MusicViewModel()
    @StateObject private var reviewViewModel = ReviewViewModel()
    @State private var searchText = ""
    @State private var selectedTab = 0
    
    var body: some View {
        
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 검색창
                    SearchBar(searchText: $searchText, onSearch: {
                        Task {
                            await musicViewModel.searchTracks(query: searchText)
                        }
                    })
                    
                    // 탭 선택
                    if searchText.isEmpty {
                        Picker("", selection: $selectedTab) {
                            Text("최신 리뷰").tag(0)
                            Text("인기 음악").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .colorMultiply(AppTheme.primary)
                    }
                    
                    // 컨텐츠
                    ScrollView {
                        VStack(spacing: 20) {
                            if musicViewModel.isLoading {
                                CommonLoadingView(message: "검색 중...")
                            } else if let error = musicViewModel.errorMessage {
                                CommonErrorView(message: error) {
                                    Task {
                                        await musicViewModel.searchTracks(query: searchText)
                                    }
                                }
                            } else if !searchText.isEmpty {
                                // 검색 결과
                                SearchResultsView(tracks: musicViewModel.searchResults)
                            } else {
                                // 검색 전 화면
                                switch selectedTab {
                                case 0:
                                    RecentReviewsSection(reviewViewModel: reviewViewModel)
                                case 1:
                                    PopularMusicSection(musicViewModel: musicViewModel)
                                default:
                                    EmptyView()
                                }
                            }
                        }
                        .padding()
                    }
                
            }
            .navigationTitle("음악 탐색")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            // 초기 로드: 최신 리뷰
            await reviewViewModel.fetchRecentReviews()
        }
    }
}

// 검색바
struct SearchBar: View {
    @Binding var searchText: String
    let onSearch: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textSecondary)
            
            TextField("", text: $searchText)
                .placeholder(when: searchText.isEmpty) {
                    Text("아티스트, 노래 검색...")
                        .foregroundColor(AppTheme.textTertiary)
                }
                .foregroundColor(AppTheme.textPrimary)
                .onSubmit {
                    onSearch()
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

// 검색 결과 뷰
struct SearchResultsView: View {
    let tracks: [Track]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if tracks.isEmpty {
                CommonEmptyView(
                    icon: "music.note.list",
                    title: "검색 결과가 없습니다",
                    description: "다른 키워드로 검색해보세요"
                )
            } else {
                Text("검색 결과 \(tracks.count)곡")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
                
                VStack(spacing: 10) {
                    ForEach(tracks, id: \.spotifyId) { track in
                        NavigationLink(destination: MusicDetailView(track: track)) {
                            TrackSearchResultRow(track: track)
                        }
                    }
                }
            }
        }
    }
}

// 트랙 검색 결과 행
struct TrackSearchResultRow: View {
    let track: Track
    
    var body: some View {
        HStack(spacing: 15) {
            // 앨범 이미지
            if let imageUrl = track.albumImageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(AppTheme.cardBackground)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(6)
            } else {
                Rectangle()
                    .fill(AppTheme.cardBackground)
                    .frame(width: 60, height: 60)
                    .cornerRadius(6)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(AppTheme.textTertiary)
                    )
            }
            
            // 곡 정보
            VStack(alignment: .leading, spacing: 6) {
                Text(track.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                Text(track.artist)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
                
                Text(track.album)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 재생 시간
            Text(track.formattedDuration)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textTertiary)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(10)
    }
}

// 최신 리뷰 섹션
struct RecentReviewsSection: View {
    @ObservedObject var reviewViewModel: ReviewViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("최신 리뷰")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            if reviewViewModel.recentReviews.isEmpty {
                CommonEmptyView(
                    icon: "square.and.pencil",
                    title: "작성한 리뷰가 없습니다",
                    description: "음악을 검색하고 첫 리뷰를 작성해보세요"
                )
            } else {
                VStack(spacing: 15) {
                    ForEach(reviewViewModel.recentReviews.prefix(10)) { review in
                        ReviewCardView(review: review)
                    }
                }
            }
        }
    }
}

//  리뷰 카드
struct ReviewCardView: View {
    let review: Review
    
    var body: some View {
        if let trackName = review.trackName, let artist = review.artist {
            NavigationLink(destination: MusicDetailView(track: createTrackFromReview())) {
                reviewContent
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            reviewContent
        }
    }
    
    private var reviewContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 사용자 정보 & 날짜
            HStack {
                Circle()
                    .fill(AppTheme.cardBackground)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(AppTheme.textTertiary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.nickname ?? review.nickname ?? "익명")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(review.rating) ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                }
                
                Spacer()
                
                Text(review.simpleFormattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
            }
            
            // 트랙 정보
            HStack(spacing: 8) {
                // 앨범 이미지
                if let imageUrl = review.albumImageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                            .scaleEffect(0.6)
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
                } else {
                    Rectangle()
                        .fill(AppTheme.cardBackground.opacity(0.5))
                        .frame(width: 50, height: 50)
                        .cornerRadius(6)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(AppTheme.textTertiary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.trackName ?? "알 수 없음")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                    
                    Text(review.artist ?? "알 수 없음")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(AppTheme.cardBackground.opacity(0.5))
            .cornerRadius(8)
            
            // 리뷰 내용
            if let content = review.content, !content.isEmpty {
                Text("    \(content)")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(10)
    }
    // Review 데이터로 Track 생성
    private func createTrackFromReview() -> Track {
        Track(
            id: nil,
            spotifyId: review.trackId,
            name: review.trackName ?? "",
            artist: review.artist ?? "",
            album: "",
            albumImageUrl: review.albumImageUrl,
            durationMs: 0,
            previewUrl: nil
        )
    }
}

// 인기 음악 섹션
struct PopularMusicSection: View {
    @ObservedObject var musicViewModel: MusicViewModel
    @State private var hasLoaded = false
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("인기 음악")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                // 새로고침 버튼
                Button(action: {
                    Task {
                        await musicViewModel.fetchPopularTracks()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(AppTheme.primary)
                        .font(.system(size: 16))
                }
            }
            
            if musicViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if musicViewModel.popularTracks.isEmpty {
                CommonEmptyView(
                    icon: "music.note",
                    title: "인기 음악",
                    description: "새로고침을 눌러 인기 음악을 불러오세요"
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(musicViewModel.popularTracks, id: \.spotifyId) { track in
                        NavigationLink(destination: MusicDetailView(track: track)) {
                            TrackSearchResultRow(track: track)
                        }
                    }
                }
            }
        }
        .onAppear {
            // 처음 로드 시 자동으로 가져오기
            if !hasLoaded && musicViewModel.popularTracks.isEmpty {
                            hasLoaded = true
                            Task {
                                await musicViewModel.fetchPopularTracks()
                            }
                        }
        }
    }
}

struct MusicSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MusicSearchView()
    }
}
