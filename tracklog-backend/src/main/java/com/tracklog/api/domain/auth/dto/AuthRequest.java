package com.tracklog.api.domain.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

public class AuthRequest {
    
    @Getter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Login {
        
        @NotBlank(message = "이메일은 필수입니다")
        @Email(message = "올바른 이메일 형식이 아닙니다")
        private String email;
        
        @NotBlank(message = "비밀번호는 필수입니다")
        private String password;
    }
    
    @Getter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ChangePassword {
        
        @NotBlank(message = "현재 비밀번호는 필수입니다")
        private String currentPassword;
        
        @NotBlank(message = "새 비밀번호는 필수입니다")
        private String newPassword;
    }
}