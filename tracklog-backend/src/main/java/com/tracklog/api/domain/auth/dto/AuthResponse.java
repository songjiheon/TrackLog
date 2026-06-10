package com.tracklog.api.domain.auth.dto;

import com.tracklog.api.domain.user.dto.UserResponse;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@AllArgsConstructor
@Builder
public class AuthResponse {
    
    private UserResponse user;
    private String message;
    
    public static AuthResponse of(UserResponse user, String message) {
        return AuthResponse.builder()
                .user(user)
                .message(message)
                .build();
    }
}