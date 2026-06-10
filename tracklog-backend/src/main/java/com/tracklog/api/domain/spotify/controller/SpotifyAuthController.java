package com.tracklog.api.domain.spotify.controller;

import com.tracklog.api.domain.spotify.service.SpotifyAuthService;
import com.tracklog.api.global.common.ApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/spotify")
@RequiredArgsConstructor
public class SpotifyAuthController {
    
    private final SpotifyAuthService spotifyAuthService;
    
    @GetMapping("/login-url")
    public ResponseEntity<ApiResponse<Map<String, String>>> getLoginUrl() {
        String authUrl = spotifyAuthService.getAuthorizationUrl();
        return ResponseEntity.ok(ApiResponse.success(Map.of(
                "authUrl", authUrl,
                "message", "이 URL로 접속하여 Spotify 로그인을 완료하세요"
        )));
    }
    
    @GetMapping("/callback")
    public ResponseEntity<ApiResponse<String>> callback(@RequestParam String code) {
        boolean success = spotifyAuthService.handleCallback(code);
        
        if (success) {
            return ResponseEntity.ok(ApiResponse.success(
                    "✓ Spotify 인증 성공! 이제 음악 검색 API를 사용할 수 있습니다."
            ));
        } else {
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("AUTH_FAILED", "Spotify 인증 실패"));
        }
    }
    
    @GetMapping("/status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getAuthStatus() {
        boolean isAuthenticated = spotifyAuthService.isAuthenticated();
        String token = spotifyAuthService.getCurrentAccessToken();
        
        return ResponseEntity.ok(ApiResponse.success(Map.of(
                "authenticated", isAuthenticated,
                "hasToken", token != null,
                "tokenPreview", token != null ? token.substring(0, Math.min(20, token.length())) + "..." : "없음"
        )));
    }
}