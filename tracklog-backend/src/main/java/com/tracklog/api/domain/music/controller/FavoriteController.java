package com.tracklog.api.domain.music.controller;

import com.tracklog.api.domain.music.dto.FavoriteDto;
import com.tracklog.api.domain.music.service.FavoriteService;
import com.tracklog.api.global.common.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/favorites")
@RequiredArgsConstructor
@Tag(name = "Favorite", description = "좋아요 관리 API")
public class FavoriteController {
    
    private final FavoriteService favoriteService;
    
    /**
     * 좋아요 추가/취소 토글
     */
    @PostMapping("/{spotifyTrackId}")
    @Operation(summary = "좋아요 토글", description = "좋아요 추가 또는 취소")
    public ResponseEntity<ApiResponse<Map<String, Boolean>>> toggleFavorite(
            @PathVariable String spotifyTrackId,
            @AuthenticationPrincipal Long userId
    ) {
        log.info("=== 좋아요 토글 요청 ===");
        log.info("User ID: {}, Track ID: {}", userId, spotifyTrackId);
        
        boolean isFavorited = favoriteService.toggleFavorite(userId, spotifyTrackId);
        
        return ResponseEntity.ok(ApiResponse.success(Map.of("isFavorited", isFavorited)));
    }
    
    /**
     * 좋아요 상태 확인
     */
    @GetMapping("/{spotifyTrackId}/status")
    @Operation(summary = "좋아요 상태 확인")
    public ResponseEntity<ApiResponse<Map<String, Boolean>>> checkFavoriteStatus(
            @PathVariable String spotifyTrackId,
            @AuthenticationPrincipal Long userId
    ) {
        boolean isFavorited = favoriteService.isFavorite(userId, spotifyTrackId);
        
        return ResponseEntity.ok(ApiResponse.success(Map.of("isFavorited", isFavorited)));
    }
    
    /**
     * 내 좋아요 목록 조회
     */
    @GetMapping
    @Operation(summary = "내 좋아요 목록", description = "사용자의 좋아요한 음악 목록 조회")
    public ResponseEntity<ApiResponse<Page<FavoriteDto>>> getMyFavorites(
            @AuthenticationPrincipal Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        log.info("=== 좋아요 목록 조회 ===");
        log.info("User ID: {}", userId);
        
        Pageable pageable = PageRequest.of(page, size);
        Page<FavoriteDto> favorites = favoriteService.getUserFavorites(userId, pageable);
        
        log.info("✓ 조회 완료: {} 건", favorites.getTotalElements());
        
        return ResponseEntity.ok(ApiResponse.success(favorites));
    }
}