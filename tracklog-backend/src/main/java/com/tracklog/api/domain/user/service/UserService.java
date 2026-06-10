package com.tracklog.api.domain.user.service;

import com.tracklog.api.domain.user.dto.UserRequest;
import com.tracklog.api.domain.user.dto.UserResponse;
import com.tracklog.api.domain.user.entity.User;
import com.tracklog.api.domain.user.repository.UserRepository;
import com.tracklog.api.global.exception.DuplicateEmailException;
import com.tracklog.api.global.exception.UserNotFoundException;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {
    
    private final UserRepository userRepository;
    
    // 전체 사용자 조회
    public List<UserResponse> getAllUsers() {
        return userRepository.findAll().stream()
                .map(UserResponse::from)
                .collect(Collectors.toList());
    }
    
    // 특정 사용자 조회
    public UserResponse getUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id));
        return UserResponse.from(user);
    }
    
    // 사용자 생성
    @Transactional
    public UserResponse createUser(UserRequest.Create request) {
        // 이메일 중복 체크
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException(request.getEmail());
        }
        
        User user = User.builder()
                .email(request.getEmail())
                .password(request.getPassword()) // TODO: 암호화 필요
                .nickname(request.getNickname())
                .profileImage(request.getProfileImage())
                .build();
        
        User saved = userRepository.save(user);
        return UserResponse.from(saved);
    }
    
    // 사용자 수정
    @Transactional
    public UserResponse updateUser(Long id, UserRequest.Update request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다: " + id));
        
        // Entity에 update 메서드 추가 필요
        User updated = userRepository.save(user);
        return UserResponse.from(updated);
    }
    
    // 사용자 삭제
    @Transactional
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("사용자를 찾을 수 없습니다: " + id);
        }
        userRepository.deleteById(id);
    }
    
    // 이메일로 사용자 조회
    public UserResponse getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다: " + email));
        return UserResponse.from(user);
    }
}