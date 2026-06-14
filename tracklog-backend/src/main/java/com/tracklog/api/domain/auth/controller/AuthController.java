package com.tracklog.api.domain.auth.controller;

import com.tracklog.api.domain.auth.dto.AuthRequest;
import com.tracklog.api.domain.auth.dto.AuthResponse;
import com.tracklog.api.domain.auth.service.AuthService;
import com.tracklog.api.global.common.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Auth", description = "인증 관련 API")
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthService authService;
    
    @Operation(
        summary = "로그인", 
        description = "이메일과 비밀번호로 로그인하여 JWT 토큰을 발급받습니다."
    )
    @ApiResponses(value = {
        @io.swagger.v3.oas.annotations.responses.ApiResponse(
            responseCode = "200", 
            description = "로그인 성공",
            content = @Content(schema = @Schema(implementation = AuthResponse.class))
        ),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(
            responseCode = "401", 
            description = "비밀번호 불일치"
        ),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(
            responseCode = "404", 
            description = "사용자 없음"
        )
    })
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                description = "로그인 정보",
                content = @Content(schema = @Schema(implementation = AuthRequest.Login.class))
            )
            @Valid @RequestBody AuthRequest.Login request
    ) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    @Operation(
        summary = "비밀번호 변경", 
        description = "현재 비밀번호를 확인하고 새 비밀번호로 변경합니다."
    )
    @SecurityRequirement(name = "bearerAuth")
    @PutMapping("/password/{userId}")
    public ResponseEntity<ApiResponse<AuthResponse>> changePassword(
            @Parameter(description = "사용자 ID", example = "1") @PathVariable Long userId,
            @Valid @RequestBody AuthRequest.ChangePassword request
    ) {
        AuthResponse response = authService.changePassword(userId, request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }
}