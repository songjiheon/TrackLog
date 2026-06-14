//
//  ProfileView.swift
//  TrackLog-Frontend
//
//  프로필 화면
//

import SwiftUI

struct ProfileView: View {
    // @StateObject private var authViewModel = AuthViewModel()
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // 프로필 헤더
                    ProfileHeader(user: authViewModel.currentUser)
                    
                    // 메뉴 리스트
                    VStack(spacing: 15) {
                        // ✅ 내 리뷰
                        NavigationLink(destination: MyReviewsView()) {
                            HStack(spacing: 15) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.primary)
                                    .frame(width: 30)
                                
                                Text("내 리뷰")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(12)
                        }
                        
                        // ✅ 좋아요한 음악
                        NavigationLink(destination: FavoriteMusicView()) {
                            HStack(spacing: 15) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(.systemPink)) // hex 에러 방지용 안전한 컬러 지정
                                    .frame(width: 30)
                                
                                Text("좋아요한 음악")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textTertiary)
                            }
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(12)
                        }
                        NavigationLink(destination: FavoritePerformanceView()) {
                            HStack(spacing: 15) {
                                Image(systemName: "ticket.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.purple) // 공연 테마에 어울리는 보라색 지정
                                    .frame(width: 30)
                                                        
                                Text("관심 공연")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.textPrimary)
                                                        
                                Spacer()
                                                        
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textTertiary)
                                }
                                .padding()
                                .background(AppTheme.cardBackground)
                                .cornerRadius(12)
                                }
                    }
                    .padding(.horizontal)
                    
                    // 로그아웃 버튼
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Text("로그아웃")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.error)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // 앱 버전 정보
                    Text("버전 1.0.0")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                        .padding(.top, 10)
                } // VStack 끝
                .padding(.vertical, 30)
            } // ScrollView 끝
        } // ZStack 끝
        .navigationTitle("프로필")
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
    } // body 끝
} // ProfileView 끝

// MARK: - 프로필 헤더
struct ProfileHeader: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 15) {
            // 프로필 이미지
            Circle()
                .fill(AppTheme.cardBackground)
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.textTertiary)
                )
            
            // 사용자 정보
            VStack(spacing: 5) {
                Text(user?.nickname ?? "사용자")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(user?.email ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            } // 내부 VStack 끝
        } // 외부 VStack 끝
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    } // body 끝
} // ProfileHeader 끝

// MARK: - 메뉴 버튼
struct MenuButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textTertiary)
            } // HStack 끝
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
        } // Button 끝
    } // body 끝
} // MenuButton 끝

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // 프리뷰 관찰용 더미 데이터 주입
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
