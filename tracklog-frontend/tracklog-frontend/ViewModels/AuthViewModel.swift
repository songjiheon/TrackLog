//
//  AuthViewModel.swift
//  TrackLog-Frontend
//
//  인증 관련 비즈니스 로직
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        checkAuthStatus()
    }
    
    // 인증 상태 확인
    func checkAuthStatus() {
        if let token = KeychainManager.shared.getAccessToken() {
            isAuthenticated = true
            print("인증 상태: 로그인됨")
        } else {
            isAuthenticated = false
            print("인증 상태: 로그아웃됨")
        }
    }
    
    // 회원가입
    func signUp(email: String, password: String, nickname: String) async {
        isLoading = true
        errorMessage = nil
        
        let request = SignUpRequest(email: email, password: password, nickname: nickname)
        
        do {
            // 회원가입 응답 구조
            struct SignUpResponse: Codable {
                let success: Bool
                let data: SignUpUser
            }
            
            struct SignUpUser: Codable {
                let id: Int
                let email: String
                let nickname: String
                let profileImage: String?
                let createdAt: String
                let updatedAt: String
            }
            
            let response: SignUpResponse = try await NetworkManager.shared.post(
                endpoint: Constants.Endpoints.signUp,
                body: request,
                needsAuth: false
            )
            
            print("회원가입 성공: \(response.data.nickname)")
            
            // 자동 로그인
            print("자동 로그인 시도...")
            await login(email: email, password: password)
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("회원가입 실패: \(error.errorDescription ?? "")")
            isLoading = false // 에러 발생 시 여기서 isLoading 해제
        } catch {
            self.errorMessage = "회원가입 실패: \(error.localizedDescription)"
            print("회원가입 실패: \(error)")
            isLoading = false // 에러 발생 시 여기서 isLoading 해제
        }
    }

    // 로그인
    func login(email: String, password: String) async {
        isLoading = true // 로그인 시작 시 로딩 활성화
        errorMessage = nil
        
        let request = LoginRequest(email: email, password: password)
        print("로그인 시도: \(email)")
        
        do {
            let response: AuthResponse = try await NetworkManager.shared.post(
                endpoint: Constants.Endpoints.login,
                body: request,
                needsAuth: false
            )
            
            print("로그인 성공!")
            print("토큰: \(response.data.accessToken.prefix(20))...")
            print("사용자: \(response.data.user.nickname)")
            
            KeychainManager.shared.saveAccessToken(response.data.accessToken)
            KeychainManager.shared.saveRefreshToken(response.data.refreshToken)
            
            self.currentUser = response.data.user
            self.isAuthenticated = true
            
            // 디버깅 프린트 통합
            print("isAuthenticated: \(self.isAuthenticated)")
            print("currentUser: \(self.currentUser?.nickname ?? "nil")")
            
        } catch let error as NetworkError {
            print("로그인 실패: \(error)")
            self.errorMessage = error.errorDescription
        } catch {
            print("알 수 없는 에러: \(error)")
            self.errorMessage = "로그인 실패: \(error.localizedDescription)"
        }
        
        isLoading = false // 로그인 종료 시 로딩 해제 (성공/실패 공통)
    }
    
    // 로그아웃
    func logout() {
            print("🚪 로그아웃 시작")
            
            // 1. Keychain에서 토큰 삭제
            KeychainManager.shared.deleteAllTokens()
            
            // 2. 상태 초기화
            isAuthenticated = false
            currentUser = nil
            
            print("로그아웃 완료")
        }
        
    
    // 비밀번호 변경
    func changePassword(currentPassword: String, newPassword: String) async {
        guard let userId = currentUser?.id else {
            errorMessage = "사용자 정보가 없습니다"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = ChangePasswordRequest(
            currentPassword: currentPassword,
            newPassword: newPassword
        )
        
        do {
            let _: AuthResponse = try await NetworkManager.shared.put(
                endpoint: "\(Constants.Endpoints.changePassword)/\(userId)",
                body: request,
                needsAuth: true
            )
            
            print("비밀번호 변경 성공")
            
        } catch let error as NetworkError {
            self.errorMessage = error.errorDescription
            print("비밀번호 변경 실패: \(error.errorDescription ?? "알 수 없는 오류")")
        } catch {
            self.errorMessage = "비밀번호 변경 실패: \(error.localizedDescription)"
            print("비밀번호 변경 실패: \(error)")
        }
        
        isLoading = false
    }
}
