import SwiftUI

// 플레이리스트 디테일 뷰
struct PlaylistDetailView: View {
    let playlistId: Int
    
    @StateObject private var viewModel = PlaylistViewModel()
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if viewModel.isLoading && viewModel.selectedPlaylist == nil {
                    CommonLoadingView(message: "불러오는 중...")
                } else if let error = viewModel.errorMessage {
                    CommonErrorView(message: error) {
                        Task {
                            await viewModel.fetchPlaylistDetail(playlistId: playlistId)
                        }
                    }
                } else if let playlist = viewModel.selectedPlaylist {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            headerSection(playlist: playlist)
                            
                            if playlist.tracks.isEmpty {
                                CommonEmptyView(
                                    icon: "music.note.list",
                                    title: "플레이리스트에 곡이 없습니다",
                                    description: "음악을 검색해서 이 플레이리스트에 곡을 추가해보세요"
                                )
                            } else {
                                trackListSection(playlist: playlist)
                            }
                        }
                        .padding()
                    }
                } else {
                    CommonEmptyView(
                        icon: "exclamationmark.triangle",
                        title: "플레이리스트 정보를 불러올 수 없습니다",
                        description: "잠시 후 다시 시도해주세요"
                    )
                }
            }
            .navigationTitle("플레이리스트")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchPlaylistDetail(playlistId: playlistId)
        }
        .alert("플레이리스트 삭제", isPresented: $showingDeleteAlert) {
            Button("삭제", role: .destructive) {
                Task {
                    await deletePlaylist()
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 플레이리스트를 삭제하시겠어요? 되돌릴 수 없습니다.")
        }
        .sheet(isPresented: $showingEditSheet) {
            if let playlist = viewModel.selectedPlaylist {
                PlaylistEditView(
                    playlist: playlist
                ) { name, desc, isPublic in
                    Task {
                        try? await PlaylistService.shared.updatePlaylist(
                            playlistId: Int(playlist.id),
                            name: name,
                            description: desc,
                            isPublic: isPublic
                        )
                        await viewModel.fetchPlaylistDetail(playlistId: playlistId)
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private func headerSection(playlist: PlaylistDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.cardBackground)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: playlist.isPublic ? "globe" : "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.primary)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(playlist.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(2)
                    
                    if let desc = playlist.description, !desc.isEmpty {
                        Text(desc)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Text("\(playlist.tracks.count)곡 • \(playlist.isPublic ? "공개" : "비공개")")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Track List Section
    @ViewBuilder
    private func trackListSection(playlist: PlaylistDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("곡 목록")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 10) {
                ForEach(playlist.tracks, id: \.spotifyId) { track in
                    PlaylistTrackRow(
                        track: track,
                        onRemove: {
                            if let id = track.id {
                                Task {
                                    await viewModel.removeTrackFromSelectedPlaylist(trackId: Int(id))
                                }
                            }
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Delete Playlist
    private func deletePlaylist() async {
        do {
            try await PlaylistService.shared.deletePlaylist(playlistId: playlistId)
            // 여기서는 단순히 이전 화면으로 돌아가도록
            // NavigationStack 상위에서 처리 필요 (환경에 따라)
            print("플레이리스트 삭제 완료")
        } catch {
            print("플레이리스트 삭제 실패:", error)
        }
    }
}
