//
//  KeychainManager.swift
//  TrackLog-Frontend
//
//  JWT 토큰을 Keychain에 안전하게 저장/조회/삭제
//

import Foundation
import Security

class KeychainManager {
    
    // Singleton
    static let shared = KeychainManager()
    
    private init() {}
    
    // Access Token 저장
    func saveAccessToken(_ token: String) {
        save(token, forKey: Constants.Keychain.accessToken)
    }
    
    // Access Token 조회
    func getAccessToken() -> String? {
        return get(forKey: Constants.Keychain.accessToken)
    }
    
    // Refresh Token 저장
    func saveRefreshToken(_ token: String) {
        save(token, forKey: Constants.Keychain.refreshToken)
    }
    
    // Refresh Token 조회
    func getRefreshToken() -> String? {
        return get(forKey: Constants.Keychain.refreshToken)
    }
    
    // 모든 토큰 삭제 (로그아웃)
    func deleteAllTokens() {
        delete(forKey: Constants.Keychain.accessToken)
        delete(forKey: Constants.Keychain.refreshToken)
    }
    
    
    // Keychain에 값 저장
    private func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else {
            print("Failed to convert string to data")
            return
        }
        
        // 기존 항목 삭제 (중복 방지)
        delete(forKey: key)
        
        // 새로운 항목 추가
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("Keychain 저장 성공: \(key)")
        } else {
            print("Keychain 저장 실패: \(key), Status: \(status)")
        }
    }
    
    // Keychain에서 값 조회
    private func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            print("Keychain 조회 성공: \(key)")
            return value
        } else {
            print("Keychain 조회 실패: \(key), Status: \(status)")
            return nil
        }
    }
    
    // Keychain에서 값 삭제
    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            print("Keychain 삭제 성공: \(key)")
        } else {
            print("Keychain 삭제 실패: \(key), Status: \(status)")
        }
    }
}
