import SwiftUI

// 리뷰 작성 화면
struct ReviewWriteView: View {
    let track: Track
    @Environment(\.dismiss) var dismiss
    @StateObject private var reviewViewModel = ReviewViewModel()
    
    @State private var rating: Double = 3.0
    @State private var content: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // 곡 정보
                        TrackInfoSection(track: track)
                        
                        // 평점 선택
                        RatingSelector(rating: $rating)
                        
                        // 리뷰 내용
                        ReviewTextEditor(content: $content)
                        
                        // 제출 버튼
                        SubmitButton(isLoading: reviewViewModel.isLoading) {
                            submitReview()
                        }
                        
                        // 에러 메시지
                        if let error = reviewViewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.error)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("리뷰 작성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textPrimary)
                }
            }
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("알림", isPresented: $showAlert) {
                Button("확인", role: .cancel) {
                    if reviewViewModel.successMessage != nil {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // 리뷰 제출
    func submitReview() {
        Task {
            await reviewViewModel.createReview(
                trackId: track.spotifyId,
                rating: rating,
                content: content.isEmpty ? nil : content
            )
            
            if let success = reviewViewModel.successMessage {
                alertMessage = success
                showAlert = true
            } else if let error = reviewViewModel.errorMessage {
                alertMessage = error
                showAlert = true
            }
        }
    }
}

// 곡 정보 섹션
struct TrackInfoSection: View {
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
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(AppTheme.cardBackground)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(AppTheme.textTertiary)
                    )
            }
            
            // 곡 정보
            VStack(alignment: .leading, spacing: 6) {
                Text(track.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
                Text(track.artist)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
                
                Text(track.album)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}

// 평점 선택
struct RatingSelector: View {
    @Binding var rating: Double
    
    var body: some View {
        VStack(spacing: 20) {
            Text("별점을 선택해주세요")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            // 별 표시
            HStack(spacing: 20) {
                ForEach(1...5, id: \.self) { index in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            rating = Double(index)
                        }
                    }) {
                        Image(systemName: rating >= Double(index) ? "star.fill" : "star")
                            .font(.system(size: 36))
                            .foregroundColor(rating >= Double(index) ? AppTheme.primary : AppTheme.textTertiary)
                    }
                }
            }
            
            // 점수 표시
            Text(String(format: "%.1f점", rating))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.primary)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}

// 리뷰 텍스트 에디터
struct ReviewTextEditor: View {
    @Binding var content: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("리뷰 작성 (선택)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("이 곡에 대한 생각을 자유롭게 적어주세요")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textTertiary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                
                TextEditor(text: $content)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(height: 150)
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
            
            Text("\(content.count) / 500")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// 제출 버튼
struct SubmitButton: View {
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(AppTheme.primary)
                    .frame(height: 50)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text("리뷰 등록")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                }
            }
        }
        .disabled(isLoading)
        .padding(.top, 10)
    }
}

struct ReviewWriteView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewWriteView(track: Track(
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
