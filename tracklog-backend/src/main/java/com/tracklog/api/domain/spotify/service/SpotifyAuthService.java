package com.tracklog.api.domain.spotify.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.hc.core5.http.ParseException;
import org.springframework.stereotype.Service;
import se.michaelthelin.spotify.SpotifyApi;
import se.michaelthelin.spotify.exceptions.SpotifyWebApiException;
import se.michaelthelin.spotify.model_objects.credentials.AuthorizationCodeCredentials;
import se.michaelthelin.spotify.requests.authorization.authorization_code.AuthorizationCodeRefreshRequest;
import se.michaelthelin.spotify.requests.authorization.authorization_code.AuthorizationCodeRequest;
import se.michaelthelin.spotify.requests.authorization.authorization_code.AuthorizationCodeUriRequest;

import java.io.IOException;
import java.net.URI;
import java.time.Instant;

@Slf4j
@Service
@RequiredArgsConstructor
public class SpotifyAuthService {
    
    private final SpotifyApi spotifyApi;
    
    private String currentAccessToken;
    private String currentRefreshToken;
    private Instant tokenExpiryTime; // 토큰 만료 시간 추적
    
    /**
     * Spotify 로그인 URL 생성
     */
    public String getAuthorizationUrl() {
    AuthorizationCodeUriRequest authorizationCodeUriRequest = spotifyApi
            .authorizationCodeUri()
            .scope("user-read-private user-read-email")  // ← 하나의 문자열로, 공백으로 구분
            .show_dialog(false)
            .build();
    
    URI uri = authorizationCodeUriRequest.execute();
    log.info("✓ Authorization URL 생성: {}", uri.toString());
    return uri.toString();
}
    
    /**
     * OAuth Callback 처리
     */
    public boolean handleCallback(String code) {
        try {
            AuthorizationCodeRequest authorizationCodeRequest = spotifyApi
                    .authorizationCode(code)
                    .build();
            
            AuthorizationCodeCredentials credentials = authorizationCodeRequest.execute();
            
            // 토큰 저장
            updateTokens(credentials);
            
            log.info("✓ OAuth Access Token 발급 성공! 만료: {}초", credentials.getExpiresIn());
            log.debug("Access Token: {}", currentAccessToken);
            log.debug("Refresh Token: {}", currentRefreshToken);
            
            return true;
            
        } catch (IOException | SpotifyWebApiException | ParseException e) {
            log.error("✗ OAuth 인증 실패", e);
            return false;
        }
    }
    
    /**
     * Access Token 갱신 (Refresh Token 사용)
     */
    public void refreshAccessToken() {
        if (currentRefreshToken == null || currentRefreshToken.isEmpty()) {
            log.error("✗ Refresh Token이 없습니다. 다시 로그인해야 합니다.");
            throw new RuntimeException("Refresh Token이 없습니다. /api/v1/spotify/login-url로 다시 로그인하세요.");
        }
        
        try {
            log.info("토큰 갱신 시도 중...");
            
            spotifyApi.setRefreshToken(currentRefreshToken);
            
            AuthorizationCodeRefreshRequest refreshRequest = spotifyApi
                    .authorizationCodeRefresh()
                    .build();
            
            AuthorizationCodeCredentials credentials = refreshRequest.execute();
            
            // 새 토큰으로 업데이트
            updateTokens(credentials);
            
            log.info("✓ Access Token 갱신 성공! 만료: {}초", credentials.getExpiresIn());
            
        } catch (IOException | SpotifyWebApiException | ParseException e) {
            log.error("✗ 토큰 갱신 실패", e);
            
            // 갱신 실패 시 토큰 초기화
            clearTokens();
            
            throw new RuntimeException(
                "토큰 갱신에 실패했습니다. 다시 로그인해주세요.", e
            );
        }
    }
    
    /**
     * 토큰 업데이트 (공통 로직)
     */
    private void updateTokens(AuthorizationCodeCredentials credentials) {
        currentAccessToken = credentials.getAccessToken();
        
        // Refresh Token은 갱신 시 null일 수 있음 (기존 것 유지)
        if (credentials.getRefreshToken() != null) {
            currentRefreshToken = credentials.getRefreshToken();
        }
        
        // 만료 시간 계산 (현재 시간 + expiresIn - 여유 시간 60초)
        Integer expiresIn = credentials.getExpiresIn();
        if (expiresIn != null) {
            tokenExpiryTime = Instant.now().plusSeconds(expiresIn - 60);
        }
        
        spotifyApi.setAccessToken(currentAccessToken);
        spotifyApi.setRefreshToken(currentRefreshToken);
    }
    
    /**
     * 토큰 초기화
     */
    private void clearTokens() {
        currentAccessToken = null;
        currentRefreshToken = null;
        tokenExpiryTime = null;
        spotifyApi.setAccessToken(null);
        spotifyApi.setRefreshToken(null);
    }
    
    /**
     * 현재 Access Token 반환 (자동 갱신)
     */
    public String getCurrentAccessToken() {
        // 토큰이 만료되었거나 곧 만료될 경우 자동 갱신
        if (isTokenExpired() && currentRefreshToken != null) {
            log.info("토큰이 만료되어 자동 갱신합니다.");
            refreshAccessToken();
        }
        
        return currentAccessToken;
    }
    
    /**
     * 인증 상태 확인
     */
    public boolean isAuthenticated() {
        if (currentAccessToken == null || currentAccessToken.isEmpty()) {
            return false;
        }
        
        // 토큰이 만료되었으면 갱신 시도
        if (isTokenExpired() && currentRefreshToken != null) {
            try {
                refreshAccessToken();
                return true;
            } catch (Exception e) {
                log.warn("토큰 갱신 실패, 인증 상태 false 반환");
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * 토큰 만료 여부 확인
     */
    private boolean isTokenExpired() {
        if (tokenExpiryTime == null) {
            return false; // 만료 시간 정보가 없으면 만료되지 않은 것으로 간주
        }
        
        boolean expired = Instant.now().isAfter(tokenExpiryTime);
        
        if (expired) {
            log.debug("토큰 만료됨. 현재: {}, 만료 시간: {}", Instant.now(), tokenExpiryTime);
        }
        
        return expired;
    }
    
    /**
     * Refresh Token 반환 (선택적)
     */
    public String getCurrentRefreshToken() {
        return currentRefreshToken;
    }
    
    /**
     * 로그아웃 (토큰 제거)
     */
    public void logout() {
        log.info("로그아웃 - 토큰 제거");
        clearTokens();
    }
    
    /**
     * 디버그: 현재 토큰 상태 출력
     */
    public void printTokenStatus() {
        log.debug("=== Spotify Token Status ===");
        log.debug("Access Token: {}", currentAccessToken != null ? "존재" : "없음");
        log.debug("Refresh Token: {}", currentRefreshToken != null ? "존재" : "없음");
        log.debug("만료 시간: {}", tokenExpiryTime);
        log.debug("만료 여부: {}", isTokenExpired());
        log.debug("인증 상태: {}", isAuthenticated());
        log.debug("===========================");
    }
}