//
//  MyReviewsView.swift
//  TrackLog-Frontend
//
//  내 리뷰 목록 화면
//

import SwiftUI

struct MyReviewsView: View {
    @StateObject private var reviewViewModel = ReviewViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            Text("내 리뷰 화면 테스트")  // ✅ 임시 테스트
                            .foregroundColor(.white)
            
            ScrollView {
                VStack(spacing: 15) {
                    if reviewViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                            .padding()
                    } else if reviewViewModel.myReviews.isEmpty {
                        CommonEmptyView(
                            icon: "square.and.pencil",
                            title: "작성한 리뷰가 없습니다",
                            description: "음악을 검색하고 리뷰를 작성해보세요"
                        )
                        .padding(.top, 50)
                    } else {
                        ForEach(reviewViewModel.myReviews) { review in
                            ReviewCardView(review: review)
                        }
                    }
                }
                .padding()
            }
        }.onAppear{
            print("리뷰 나타남")
        }
        .navigationTitle("내 리뷰")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await reviewViewModel.fetchMyReviews()
        }
    }
}

struct MyReviewsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MyReviewsView()
        }
    }
}
