//
//  FavoriteMusicView.swift
//  TrackLog-Frontend
//
//  좋아요한 음악 목록 화면
//

import SwiftUI

struct FavoriteMusicView: View {
    @StateObject private var favoriteViewModel = FavoriteViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 15) {
                    if favoriteViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                            .padding()
                    } else if favoriteViewModel.favorites.isEmpty {
                        CommonEmptyView(
                            icon: "heart.fill",
                            title: "좋아요한 음악이 없습니다",
                            description: "마음에 드는 음악에 좋아요를 눌러보세요"
                        )
                        .padding(.top, 50)
                    } else {
                        ForEach(favoriteViewModel.favorites) { favorite in
                            NavigationLink(destination: MusicDetailView(track: favorite.toTrack())) {
                                FavoriteTrackRow(favorite: favorite)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("좋아요한 음악")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await favoriteViewModel.fetchFavorites()
        }
    }
}

// MARK: - 좋아요 트랙 행
struct FavoriteTrackRow: View {
    let favorite: Favorite
    
    var body: some View {
        HStack(spacing: 15) {
            // 앨범 이미지
            if let imageUrl = favorite.albumImageUrl, let url = URL(string: imageUrl) {
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
            }
            
            // 곡 정보
            VStack(alignment: .leading, spacing: 6) {
                Text(favorite.trackName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                Text(favorite.artist)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
                
                Text(favorite.album)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "heart.fill")
                .foregroundColor(Color(hex: "#E22134"))
                .font(.system(size: 18))
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(10)
    }
}
