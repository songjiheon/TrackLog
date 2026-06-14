//
//  PlaylistMainView.swift
//  TrackLog-Frontend
//

import SwiftUI

struct PlaylistMainView: View {
    @StateObject private var viewModel = PlaylistViewModel()
    @State private var showingCreateSheet = false
    @State private var selectedTab = 0   // 0: 내 플리, 1: 둘러보기
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 상단 탭 (내 플리 / 둘러보기)
                Picker("", selection: $selectedTab) {
                    Text("나의 플레이리스트").tag(0)
                    Text("둘러보기").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .colorMultiply(AppTheme.primary)
                
                // 컨텐츠
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isLoading && viewModel.myPlaylists.isEmpty && viewModel.explorePlaylists.isEmpty {
                            CommonLoadingView(message: "불러오는 중...")
                        } else if let error = viewModel.errorMessage {
                            CommonErrorView(message: error) {
                                Task {
                                    if selectedTab == 0 {
                                        await viewModel.fetchMyPlaylists()
                                    } else {
                                        await viewModel.fetchExplorePlaylists()
                                    }
                                }
                            }
                        } else {
                            if selectedTab == 0 {
                                MyPlaylistsSection(viewModel: viewModel)
                            } else {
                                ExplorePlaylistsSection(viewModel: viewModel)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("플레이리스트")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                Button {
                    showingCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(AppTheme.primary)
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            PlaylistCreateView { name, desc, isPublic in
                Task {
                    await viewModel.createPlaylist(
                        name: name,
                        description: desc,
                        isPublic: isPublic
                    )
                    await viewModel.fetchMyPlaylists()
                }
            }
        }
        .task {
            // 처음엔 내 플리만 로드
            await viewModel.fetchMyPlaylists()
        }
    }
}

// 나의 플레이리스트 섹션
struct MyPlaylistsSection: View {
    @ObservedObject var viewModel: PlaylistViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("나의 플레이리스트")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            if viewModel.myPlaylists.isEmpty {
                CommonEmptyView(
                    icon: "text.badge.plus",
                    title: "플레이리스트가 없습니다",
                    description: "상단의 + 버튼을 눌러 나만의 플레이리스트를 만들어보세요"
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.myPlaylists) { playlist in
                        NavigationLink(
                            destination: PlaylistDetailView(playlistId: playlist.id)
                        ) {
                            PlaylistRowView(playlist: playlist)
                        }
                    }
                }
            }
        }
    }
}

// 로딩
struct ExplorePlaylistsSection: View {
    @ObservedObject var viewModel: PlaylistViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("둘러보기")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            if viewModel.explorePlaylists.isEmpty {
                CommonEmptyView(
                    icon: "music.note.list",
                    title: "표시할 플레이리스트가 없습니다",
                    description: "조금만 기다리면 사람들이 만든 플레이리스트가 여기에 보여요"
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.explorePlaylists) { playlist in
                        NavigationLink(
                            destination: PlaylistDetailView(playlistId: playlist.id)
                        ) {
                            PlaylistRowView(playlist: playlist)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchExplorePlaylistsOnce()
        }
    }
}
    

// 단일 플레이리스트
struct PlaylistRowView: View {
    let playlist: PlaylistResponse
    
    var body: some View {
        HStack(spacing: 12) {
            // 간단 썸네일 (첫 글자/아이콘)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.cardBackground)
                    .frame(width: 50, height: 50)
                
                Image(systemName: playlist.isPublic ? "globe" : "lock.fill")
                    .foregroundColor(AppTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                if let desc = playlist.description, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
                
                Text("\(playlist.trackCount)곡")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(10)
    }
}
