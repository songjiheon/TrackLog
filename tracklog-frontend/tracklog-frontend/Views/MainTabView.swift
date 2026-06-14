import SwiftUI

// 메인 탭바
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // 탭 컨텐츠
                Group {
                    switch selectedTab {
                    case 0:
                        MusicSearchView()
                    case 1:
                        PerformanceListView()
                    case 2:
                        PlaylistMainView()
                    case 3:
                        ProfileView()
                    default:
                        MusicSearchView()
                    }
                }
                
                // 커스텀 탭바
                CustomTabBar(selectedTab: $selectedTab)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// 커스텀 탭바
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 구분선
            Divider()
                .background(AppTheme.textTertiary.opacity(0.2))
            
            HStack(spacing: 0) {
                // 음악 탐색
                TabBarButton(
                    icon: "music.note.list",
                    title: "음악",
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                // 공연 정보
                TabBarButton(
                    icon: "ticket",
                    title: "공연",
                    isSelected: selectedTab == 1
                ) {
                    selectedTab = 1
                }
                // 플리
                TabBarButton(
                    icon: "text.badge.plus",
                    title: "플레이리스트",
                    isSelected: selectedTab == 2
                ) {
                        selectedTab = 2
                }
                
                // 프로필
                TabBarButton(
                    icon: "person.fill",
                    title: "프로필",
                    isSelected: selectedTab == 3
                ) {
                    selectedTab = 3
                }
            }
            .frame(height: 60)
            .background(AppTheme.secondaryBackground)
        }
    }
}

// 탭바 버튼
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textTertiary)
                    .frame(height: 24)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
