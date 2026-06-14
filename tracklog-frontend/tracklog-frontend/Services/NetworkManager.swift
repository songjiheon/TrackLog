import Foundation

// Network Error
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case encodingError
    case serverError(String)
    case unauthorized
    case notFound
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다"
        case .noData:
            return "데이터가 없습니다"
        case .decodingError:
            return "데이터 파싱에 실패했습니다"
        case .encodingError:
            return "데이터 인코딩에 실패했습니다"
        case .serverError(let message):
            return "서버 오류: \(message)"
        case .unauthorized:
            return "인증이 필요합니다"
        case .notFound:
            return "요청한 리소스를 찾을 수 없습니다"
        case .unknown(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
}

// API Response Wrapper
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
    let code: String?
}

// Network Manager
class NetworkManager {
    
    // Singleton
    static let shared = NetworkManager()
    
    private init() {}
    
    // Generic Request Method
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        needsAuth: Bool = false
    ) async throws -> T {
        
        // 1. URL 생성
        guard let url = URL(string: Constants.baseURL + endpoint) else {
            print("Invalid URL: \(Constants.baseURL + endpoint)")
            throw NetworkError.invalidURL
        }
        
        // 2. URLRequest 생성
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // 3. JWT 토큰 추가 (인증 필요한 경우)
        if needsAuth {
            if let token = KeychainManager.shared.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                print("Authorization 헤더 추가")
            } else {
                print("토큰이 없습니다")
                throw NetworkError.unauthorized
            }
        }
        
        // 4. Request Body 추가
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
                
                // 디버깅: Body 내용 출력
                if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                    print("equest Body: \(bodyString)")
                }
            } catch {
                print("Encoding Error: \(error)")
                throw NetworkError.encodingError
            }
        }
        
        // 5. API 요청 로깅
        print("[\(method)] \(url.absoluteString)")
        
        // 6. 네트워크 요청
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // 7. HTTP 상태 코드 확인
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            print("Response Status: \(httpResponse.statusCode)")
            
            // 8. 상태 코드별 처리
            switch httpResponse.statusCode {
            case 200...299:
                // 성공
                break
            case 401:
                print("401 Unauthorized")
                throw NetworkError.unauthorized
            case 404:
                print("404 Not Found")
                throw NetworkError.notFound
            case 400...499:
                // 클라이언트 오류
                if let errorMessage = try? JSONDecoder().decode(APIResponse<String>.self, from: data).message {
                    throw NetworkError.serverError(errorMessage)
                }
                throw NetworkError.serverError("클라이언트 오류 (\(httpResponse.statusCode))")
            case 500...599:
                // 서버 오류
                throw NetworkError.serverError("서버 오류 (\(httpResponse.statusCode))")
            default:
                throw NetworkError.serverError("알 수 없는 오류 (\(httpResponse.statusCode))")
            }
            
            // 9. 디버깅: 응답 데이터 출력
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }
            
            // 10. JSON 디코딩
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decoded = try decoder.decode(T.self, from: data)
                print("Decoding 성공")
                return decoded
            } catch {
                print("Decoding Error: \(error)")
                throw NetworkError.decodingError
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            print("Network Error: \(error)")
            throw NetworkError.unknown(error)
        }
    }
    
    // MARK: - Convenience Methods
    
    /// GET 요청
    func get<T: Decodable>(
        endpoint: String,
        needsAuth: Bool = false
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: "GET",
            needsAuth: needsAuth
        )
    }
    
    /// POST 요청
    func post<T: Decodable>(
        endpoint: String,
        body: Encodable,
        needsAuth: Bool = false
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: "POST",
            body: body,
            needsAuth: needsAuth
        )
    }
    
    /// PUT 요청
    func put<T: Decodable>(
        endpoint: String,
        body: Encodable,
        needsAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: "PUT",
            body: body,
            needsAuth: needsAuth
        )
    }
    
    /// DELETE 요청
    func delete<T: Decodable>(
        endpoint: String,
        needsAuth: Bool = true
    ) async throws -> T {
        return try await request(
            endpoint: endpoint,
            method: "DELETE",
            needsAuth: needsAuth
        )
    }
}
