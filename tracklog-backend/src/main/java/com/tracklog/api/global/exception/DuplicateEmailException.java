package com.tracklog.api.global.exception;

import org.springframework.http.HttpStatus;

public class DuplicateEmailException extends CustomException {
    public DuplicateEmailException(String email) {
        super("EMAIL_DUPLICATED", "이미 존재하는 이메일입니다: " + email, HttpStatus.CONFLICT);
    }
}