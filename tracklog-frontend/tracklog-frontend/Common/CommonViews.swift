//  공통 UI 컴포넌트

import SwiftUI

// 로딩 뷰
struct CommonLoadingView: View {
    var message: String = "로딩 중..."
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.primary))
                .scaleEffect(1.5)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// 에러 뷰
struct CommonErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.error)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Text("다시 시도")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppTheme.primary)
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// 빈 화면
struct CommonEmptyView: View {
    let icon: String
    let title: String
    let description: String?
    
    init(icon: String = "tray", title: String, description: String? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(AppTheme.textTertiary)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textSecondary)
            
            if let description = description {
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
