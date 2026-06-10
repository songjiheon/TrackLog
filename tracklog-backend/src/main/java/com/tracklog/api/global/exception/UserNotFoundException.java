package com.tracklog.api.global.exception;

import org.springframework.http.HttpStatus;

public class UserNotFoundException extends CustomException {
    
    // ID로 찾을 때
    public UserNotFoundException(Long id) {
        super("USER_NOT_FOUND", "사용자를 찾을 수 없습니다: " + id, HttpStatus.NOT_FOUND);
    }
    
    // 이메일로 찾을 때
    public UserNotFoundException(String email) {
        super("USER_NOT_FOUND", "사용자를 찾을 수 없습니다: " + email, HttpStatus.NOT_FOUND);
    }
}