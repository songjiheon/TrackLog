import SwiftUI

// 로그인 화면
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // 로고
                VStack(spacing: 15) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                    
                    Text("TrackLog")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                .padding(.bottom, 50)
                
                // 입력 필드
                VStack(spacing: 20) {
                    CustomTextField(
                        placeholder: "이메일",
                        text: $email,
                        keyboardType: .emailAddress
                    )
                    
                    CustomSecureField(
                        placeholder: "비밀번호",
                        text: $password
                    )
                }
                .padding(.horizontal, 30)
                
                // 로그인 버튼
                Button(action: {
                    Task {
                        await authViewModel.login(email: email, password: password)
                        print("🔍 로그인 후 isAuthenticated: \(authViewModel.isAuthenticated)")
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(AppTheme.primary)
                            .frame(height: 50)
                        
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Text("로그인")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                .disabled(authViewModel.isLoading)
                
                // 에러 메시지
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.error)
                        .padding(.horizontal, 30)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // 회원가입
                VStack(spacing: 20) {
                    Rectangle()
                        .fill(AppTheme.textTertiary.opacity(0.3))
                        .frame(height: 1)
                        .padding(.horizontal, 30)
                    
                    HStack(spacing: 5) {
                        Text("계정이 없으신가요?")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Button(action: {
                            showSignUp = true
                        }) {
                            Text("가입하기")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(authViewModel)
        }
    }
}
// 커스텀 텍스트 필드
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField("", text: $text)
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .foregroundColor(AppTheme.textTertiary)
            }
            .foregroundColor(AppTheme.textPrimary)
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(8)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
    }
}

//  커스텀 보안 필드
struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        SecureField("", text: $text)
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .foregroundColor(AppTheme.textTertiary)
            }
            .foregroundColor(AppTheme.textPrimary)
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(8)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
