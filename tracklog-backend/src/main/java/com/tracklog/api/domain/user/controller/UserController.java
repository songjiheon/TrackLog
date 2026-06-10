package com.tracklog.api.domain.user.controller;

import com.tracklog.api.domain.user.dto.UserRequest;
import com.tracklog.api.domain.user.dto.UserResponse;
import com.tracklog.api.domain.user.service.UserService;
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
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "User", description = "사용자 관리 API")
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @Operation(summary = "전체 사용자 조회", description = "모든 사용자 목록을 조회합니다.")
    @SecurityRequirement(name = "bearerAuth")
    @GetMapping
    public ResponseEntity<ApiResponse<List<UserResponse>>> getAllUsers() {
        return ResponseEntity.ok(ApiResponse.success(userService.getAllUsers()));
    }
    
    @Operation(summary = "현재 로그인한 사용자 정보", description = "JWT 토큰으로 인증된 현재 사용자의 정보를 조회합니다.")
    @SecurityRequirement(name = "bearerAuth")
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(
            @Parameter(hidden = true) Authentication authentication
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ResponseEntity.ok(ApiResponse.success(userService.getUser(userId)));
    }
    
    @Operation(summary = "특정 사용자 조회", description = "ID로 특정 사용자를 조회합니다.")
    @SecurityRequirement(name = "bearerAuth")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(
            @Parameter(description = "사용자 ID", example = "1") @PathVariable Long id
    ) {
        return ResponseEntity.ok(ApiResponse.success(userService.getUser(id)));
    }
    
    @Operation(summary = "회원가입", description = "새로운 사용자를 등록합니다.")
    @ApiResponses(value = {
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "201", description = "회원가입 성공"),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "409", description = "이미 존재하는 이메일")
    })
    @PostMapping
    public ResponseEntity<ApiResponse<UserResponse>> createUser(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                description = "회원가입 정보",
                content = @Content(schema = @Schema(implementation = UserRequest.Create.class))
            )
            @Valid @RequestBody UserRequest.Create request
    ) {
        UserResponse response = userService.createUser(request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(response));
    }
    
    @Operation(summary = "사용자 정보 수정", description = "사용자의 프로필 정보를 수정합니다.")
    @SecurityRequirement(name = "bearerAuth")
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> updateUser(
            @Parameter(description = "사용자 ID") @PathVariable Long id,
            @Valid @RequestBody UserRequest.Update request
    ) {
        return ResponseEntity.ok(ApiResponse.success(userService.updateUser(id, request)));
    }
    
    @Operation(summary = "사용자 삭제", description = "사용자 계정을 삭제합니다.")
    @SecurityRequirement(name = "bearerAuth")
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUser(
            @Parameter(description = "사용자 ID") @PathVariable Long id
    ) {
        userService.deleteUser(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    @Operation(summary = "이메일로 사용자 조회", description = "이메일 주소로 사용자를 검색합니다.")
    @SecurityRequirement(name = "bearerAuth")
    @GetMapping("/email/{email}")
    public ResponseEntity<ApiResponse<UserResponse>> getUserByEmail(
            @Parameter(description = "이메일 주소", example = "user@tracklog.com") @PathVariable String email
    ) {
        return ResponseEntity.ok(ApiResponse.success(userService.getUserByEmail(email)));
    }
}