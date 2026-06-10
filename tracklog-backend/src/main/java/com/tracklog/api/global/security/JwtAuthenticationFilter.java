package com.tracklog.api.global.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    
    private final JwtTokenProvider jwtTokenProvider;
    
    // JWT 검증을 건너뛸 경로들
    private static final List<String> EXCLUDED_PATHS = Arrays.asList(
        "/api/v1/auth/",
        "/api/v1/users",
        "/api/v1/spotify/",
        "/api/v1/music/",
        "/actuator/",
        "/swagger-ui/",
        "/v3/api-docs/",
        "/swagger-resources/",
        "/webjars/"
    );
    
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        boolean shouldSkip = EXCLUDED_PATHS.stream()
                .anyMatch(excludedPath -> path.startsWith(excludedPath));
        
        if (shouldSkip) {
            log.debug("JWT 필터 건너뛰기: {}", path);
        }
        
        return shouldSkip;
    }
    
    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        
        String path = request.getRequestURI();
        log.debug("JWT 필터 실행: {}", path);
        
        try {
            String token = getTokenFromRequest(request);
            
            if (StringUtils.hasText(token)) {
                log.debug("토큰 발견: {}...", token.substring(0, Math.min(20, token.length())));
                
                if (jwtTokenProvider.validateToken(token)) {
                    Long userId = jwtTokenProvider.getUserIdFromToken(token);
                    String email = jwtTokenProvider.getEmailFromToken(token);
                    
                    // Authentication 객체 생성
                    UsernamePasswordAuthenticationToken authentication = 
                        new UsernamePasswordAuthenticationToken(
                            userId,  // principal
                            null,    // credentials
                            Collections.emptyList()  // authorities
                        );
                    
                    authentication.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request)
                    );
                    
                    // SecurityContext에 인증 정보 설정
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                    
                    log.debug("JWT 인증 성공: userId={}, email={}", userId, email);
                } else {
                    log.debug("JWT 토큰 검증 실패");
                }
            } else {
                log.debug("토큰 없음 - 인증 없이 계속 진행");
            }
        } catch (Exception e) {
            log.error("JWT 인증 처리 중 오류 발생: {}", e.getMessage());
            log.debug("예외 상세:", e);
            // 인증 실패해도 필터 체인은 계속 진행 (permitAll 경로를 위해)
        }
        
        log.debug("필터 체인 계속 진행: {}", path);
        filterChain.doFilter(request, response);
    }
    
    /**
     * Request Header에서 토큰 추출
     */
    private String getTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        
        return null;
    }
}