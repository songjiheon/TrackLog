import SwiftUI

//  회원가입 화면 
struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AuthViewModel()
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var nickname = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // 배경
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // 헤더
                        Text("계정 만들기")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.top, 40)
                            .padding(.bottom, 20)
                        
                        // 입력 필드
                        VStack(spacing: 20) {
                            CustomTextField(
                                placeholder: "이메일",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            CustomTextField(
                                placeholder: "사용자명",
                                text: $nickname
                            )
                            
                            CustomSecureField(
                                placeholder: "비밀번호 (8자 이상)",
                                text: $password
                            )
                            
                            CustomSecureField(
                                placeholder: "비밀번호 확인",
                                text: $confirmPassword
                            )
                        }
                        .padding(.horizontal, 30)
                        
                        // 회원가입 버튼
                        Button(action: {
                            handleSignUp()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(isValidInput ? AppTheme.primary : AppTheme.textTertiary)
                                    .frame(height: 50)
                                
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("가입하기")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        .disabled(viewModel.isLoading || !isValidInput)
                        
                        // 에러 메시지
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.error)
                                .padding(.horizontal, 30)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("알림", isPresented: $showAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    var isValidInput: Bool {
        !email.isEmpty &&
        !nickname.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword
    }
    
    func handleSignUp() {
        guard email.contains("@") else {
            alertMessage = "올바른 이메일 형식을 입력해주세요"
            showAlert = true
            return
        }
        
        guard password.count >= 8 else {
            alertMessage = "비밀번호는 8자 이상이어야 합니다"
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "비밀번호가 일치하지 않습니다"
            showAlert = true
            return
        }
        
        Task {
            await viewModel.signUp(email: email, password: password, nickname: nickname)
            
            if viewModel.isAuthenticated {
                dismiss()
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
