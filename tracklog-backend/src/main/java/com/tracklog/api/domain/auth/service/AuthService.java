package com.tracklog.api.domain.auth.service;

import com.tracklog.api.domain.auth.dto.AuthRequest;
import com.tracklog.api.domain.auth.dto.AuthResponse;
import com.tracklog.api.domain.user.dto.UserResponse;
import com.tracklog.api.domain.user.entity.User;
import com.tracklog.api.domain.user.repository.UserRepository;
import com.tracklog.api.global.exception.InvalidPasswordException;
import com.tracklog.api.global.exception.UserNotFoundException;
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
        
        log.info("User logged in: {}", user.getEmail());
        
        return AuthResponse.of(
                UserResponse.from(user),
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