package com.tracklog.api.global.exception;

import org.springframework.http.HttpStatus;

public class InvalidPasswordException extends CustomException {
    public InvalidPasswordException() {
        super("INVALID_PASSWORD", "비밀번호가 일치하지 않습니다", HttpStatus.UNAUTHORIZED);
    }
}