package com.tracklog.api.domain.auth.controller;

import com.tracklog.api.domain.auth.dto.AuthRequest;
import com.tracklog.api.domain.auth.dto.AuthResponse;
import com.tracklog.api.domain.auth.service.AuthService;
import com.tracklog.api.global.common.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthService authService;
    
    //로그인
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody AuthRequest.Login request
    ) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    //비밀번호 변경
    @PutMapping("/password/{userId}")
    public ResponseEntity<ApiResponse<AuthResponse>> changePassword(
            @PathVariable Long userId,
            @Valid @RequestBody AuthRequest.ChangePassword request
    ) {
        AuthResponse response = authService.changePassword(userId, request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}