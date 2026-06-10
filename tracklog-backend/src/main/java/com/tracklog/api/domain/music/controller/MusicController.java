package com.tracklog.api.domain.music.controller;

import com.tracklog.api.domain.music.dto.TrackDto;
import com.tracklog.api.domain.music.service.SpotifyService;
import com.tracklog.api.domain.spotify.service.SpotifyAuthService;
import com.tracklog.api.global.common.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import se.michaelthelin.spotify.SpotifyApi;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/music")
@RequiredArgsConstructor
public class MusicController {
    
    private final SpotifyService spotifyService;
    private final SpotifyAuthService spotifyAuthService;
    private final SpotifyApi spotifyApi;
    
    @Value("${spotify.redirect-uri:unknown}")
    private String redirectUri;
    
    @PostMapping("/debug/force-set-token")
    public ResponseEntity<?> forceSetToken() {
    log.info("=== 강제 토큰 설정 ===");
    
    // AuthService에서 토큰 가져오기
    String token = spotifyAuthService.getCurrentAccessToken();
    log.info("AuthService 토큰: {}", token != null ? token.substring(0, 30) : "null");
    
    if (token == null) {
        return ResponseEntity.badRequest().body(Map.of(
            "success", false,
            "message", "AuthService에 토큰이 없습니다"
        ));
    }
    
    // SpotifyApi에 직접 설정
    spotifyApi.setAccessToken(token);
    
    // 검증
    String verifyToken = spotifyApi.getAccessToken();
    boolean match = token.equals(verifyToken);
    
    log.info("설정 완료. 일치: {}", match);
    
    return ResponseEntity.ok(Map.of(
        "success", true,
        "message", "토큰 강제 설정 완료",
        "tokensMatch", match,
        "spotifyApiToken", verifyToken != null ? verifyToken.substring(0, 30) : "null",
        "authServiceToken", token.substring(0, 30)
    ));
}
    /**
     * 음악 검색
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<TrackDto>>> searchTracks(
            @RequestParam String query,
            @RequestParam(defaultValue = "10") int limit
    ) {
        log.info("=== 음악 검색 요청 ===");
        log.info("Query: {}, Limit: {}", query, limit);
        
        try {
            List<TrackDto> tracks = spotifyService.searchTracks(query, limit);
            log.info("✓ 검색 성공: {}개 결과 반환", tracks.size());
            return ResponseEntity.ok(ApiResponse.success(tracks));
            
        } catch (Exception e) {
            log.error("✗ 검색 실패: {}", e.getMessage(), e);
            throw e;
        }
    }

    /**
     * 트랙 ID로 조회
     */
    @GetMapping("/track/{trackId}")
    public ResponseEntity<ApiResponse<TrackDto>> getTrack(@PathVariable String trackId) {
        log.info("=== 트랙 조회 요청 ===");
        log.info("Track ID: {}", trackId);
        
        try {
            TrackDto track = spotifyService.getTrack(trackId);
            log.info("✓ 트랙 조회 성공: {}", track.getName());
            return ResponseEntity.ok(ApiResponse.success(track));
            
        } catch (Exception e) {
            log.error("✗ 트랙 조회 실패: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * 디버깅: 현재 토큰 상태 확인
     */
    @GetMapping("/debug/token-status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getTokenStatus() {
        Map<String, Object> status = new HashMap<>();
        
        // SpotifyApi 토큰 상태
        String apiToken = spotifyApi.getAccessToken();
        status.put("spotifyApiHasToken", apiToken != null);
        status.put("spotifyApiTokenPreview", apiToken != null ? 
                apiToken.substring(0, Math.min(20, apiToken.length())) + "..." : "없음");
        
        // AuthService 토큰 상태
        String authToken = spotifyAuthService.getCurrentAccessToken();
        status.put("authServiceAuthenticated", spotifyAuthService.isAuthenticated());
        status.put("authServiceHasToken", authToken != null);
        status.put("authServiceTokenPreview", authToken != null ? 
                authToken.substring(0, Math.min(20, authToken.length())) + "..." : "없음");
        
        // 토큰 일치 여부
        status.put("tokensMatch", apiToken != null && apiToken.equals(authToken));
        
        // Refresh Token 상태
        String refreshToken = spotifyAuthService.getCurrentRefreshToken();
        status.put("hasRefreshToken", refreshToken != null);
        
        log.info("토큰 상태 조회: {}", status);
        
        return ResponseEntity.ok(ApiResponse.success(status));
    }
    
    /**
     * 디버깅: 강제 토큰 갱신
     */
    @PostMapping("/debug/refresh-token")
    public ResponseEntity<ApiResponse<Map<String, String>>> forceRefreshToken() {
        try {
            log.info("=== 강제 토큰 갱신 요청 ===");
            
            if (!spotifyAuthService.isAuthenticated()) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("UNAUTHORIZED", "로그인이 필요합니다"));
            }
            
            String oldToken = spotifyAuthService.getCurrentAccessToken();
            log.info("기존 토큰: {}...", oldToken != null ? oldToken.substring(0, 20) : "없음");
            
            spotifyAuthService.refreshAccessToken();
            
            String newToken = spotifyAuthService.getCurrentAccessToken();
            log.info("새 토큰: {}...", newToken != null ? newToken.substring(0, 20) : "없음");
            
            // SpotifyApi에도 반영
            spotifyApi.setAccessToken(newToken);
            
            Map<String, String> result = new HashMap<>();
            result.put("message", "토큰 갱신 완료");
            result.put("oldTokenPreview", oldToken != null ? oldToken.substring(0, 20) + "..." : "없음");
            result.put("newTokenPreview", newToken != null ? newToken.substring(0, 20) + "..." : "없음");
            
            return ResponseEntity.ok(ApiResponse.success(result));
            
        } catch (Exception e) {
            log.error("✗ 토큰 갱신 실패", e);
            return ResponseEntity.status(500)
                    .body(ApiResponse.error("TOKEN_REFRESH_FAILED", "토큰 갱신 실패: " + e.getMessage()));
        }
    }
    
    /**
     * 디버깅: 전체 상태 확인 (상세)
     */
    @GetMapping("/debug/full-status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getFullStatus() {
        Map<String, Object> status = new HashMap<>();
        
        try {
            // 1. SpotifyApi 상태
            Map<String, Object> apiStatus = new HashMap<>();
            
            String accessToken = spotifyApi.getAccessToken();
            apiStatus.put("accessToken", accessToken != null ? 
                    accessToken.substring(0, Math.min(30, accessToken.length())) + "..." : "없음");
            
            String refreshToken = spotifyApi.getRefreshToken();
            apiStatus.put("refreshToken", refreshToken != null ? 
                    "존재 (" + refreshToken.substring(0, 20) + "...)" : "없음");
            
            apiStatus.put("clientId", spotifyApi.getClientId());
            apiStatus.put("redirectUri", redirectUri);
            
            status.put("spotifyApi", apiStatus);
            
            // 2. AuthService 상태
            Map<String, Object> authStatus = new HashMap<>();
            authStatus.put("authenticated", spotifyAuthService.isAuthenticated());
            
            String authAccessToken = spotifyAuthService.getCurrentAccessToken();
            authStatus.put("accessToken", authAccessToken != null ? 
                    authAccessToken.substring(0, Math.min(30, authAccessToken.length())) + "..." : "없음");
            
            authStatus.put("refreshToken", spotifyAuthService.getCurrentRefreshToken() != null ? 
                    "존재" : "없음");
            
            status.put("authService", authStatus);
            
            // 3. 토큰 비교
            String apiToken = spotifyApi.getAccessToken();
            String authToken = spotifyAuthService.getCurrentAccessToken();
            status.put("tokensMatch", apiToken != null && apiToken.equals(authToken));
            status.put("canRefresh", spotifyAuthService.getCurrentRefreshToken() != null);
            
            log.info("전체 상태 조회: {}", status);
            
            return ResponseEntity.ok(ApiResponse.success(status));
            
        } catch (Exception e) {
            log.error("상태 조회 실패", e);
            status.put("error", e.getMessage());
            return ResponseEntity.status(500).body(ApiResponse.success(status));
        }
    }
    
    /**
     * 디버깅: 토큰 수동 설정 (테스트용)
     */
    @PostMapping("/debug/set-token")
    public ResponseEntity<ApiResponse<String>> setToken(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        
        if (token == null || token.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("INVALID_REQUEST", "token 필드가 필요합니다"));
        }
        
        log.info("수동 토큰 설정: {}...", token.substring(0, Math.min(20, token.length())));
        
        spotifyApi.setAccessToken(token);
        
        return ResponseEntity.ok(ApiResponse.success("토큰 설정 완료"));
    }
    
    /**
     * Health Check
     */
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<Map<String, Object>>> healthCheck() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("authenticated", spotifyAuthService.isAuthenticated());
        health.put("hasToken", spotifyApi.getAccessToken() != null);
        
        return ResponseEntity.ok(ApiResponse.success(health));
    }
}