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
    private String accessToken;      
    private String refreshToken;     
    
    public static AuthResponse of(UserResponse user, String message) {
        return AuthResponse.builder()
                .user(user)
                .message(message)
                .build();
    }
    
    public static AuthResponse withTokens(
            UserResponse user, 
            String accessToken, 
            String refreshToken,
            String message
    ) {
        return AuthResponse.builder()
                .user(user)
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .message(message)
                .build();
    }
}