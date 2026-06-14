import Foundation

// User Model
struct User: Identifiable, Codable {
    let id: Int
    let email: String
    let nickname: String
    let profileImage: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case nickname
        case profileImage
        case createdAt
    }
}

// Login Request
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// SignUp Request
struct SignUpRequest: Codable {
    let email: String
    let password: String
    let nickname: String
}

// Auth Response
struct AuthResponse: Codable {
    let success: Bool
    let data: AuthData
}

struct AuthData: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

// 비밀 번호 변경
struct ChangePasswordRequest: Codable {
    let currentPassword: String
    let newPassword: String
}
