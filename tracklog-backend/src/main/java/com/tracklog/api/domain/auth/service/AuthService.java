package com.tracklog.api.domain.auth.service;

import com.tracklog.api.domain.auth.dto.AuthRequest;
import com.tracklog.api.domain.auth.dto.AuthResponse;
import com.tracklog.api.domain.user.dto.UserResponse;
import com.tracklog.api.domain.user.entity.User;
import com.tracklog.api.domain.user.repository.UserRepository;
import com.tracklog.api.global.exception.InvalidPasswordException;
import com.tracklog.api.global.exception.UserNotFoundException;
import com.tracklog.api.global.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    /**
     * 로그인
     */
    public AuthResponse login(AuthRequest.Login request) {
        // 사용자 조회
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UserNotFoundException(request.getEmail()));
        
        // 비밀번호 검증
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new InvalidPasswordException();
        }
        
        // 🆕 JWT 토큰 생성
        String accessToken = jwtTokenProvider.createAccessToken(user.getId(), user.getEmail());
        String refreshToken = jwtTokenProvider.createRefreshToken(user.getId());
        
        log.info("User logged in: {}", user.getEmail());
        
        return AuthResponse.withTokens(
                UserResponse.from(user),
                accessToken,
                refreshToken,
                "로그인 성공"
        );
    }
    
    /**
     * 비밀번호 변경
     */
    @Transactional
    public AuthResponse changePassword(Long userId, AuthRequest.ChangePassword request) {
        // 사용자 조회
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
        
        // 현재 비밀번호 검증
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new InvalidPasswordException();
        }
        
        // 새 비밀번호 암호화 및 저장
        String encodedPassword = passwordEncoder.encode(request.getNewPassword());
        user.updatePassword(encodedPassword);
        
        log.info("Password changed for user: {}", user.getEmail());
        
        return AuthResponse.of(
                UserResponse.from(user),
                "비밀번호 변경 완료"
        );
    }
}