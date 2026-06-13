package com.tracklog.api.domain.performance.controller;

import com.tracklog.api.domain.performance.dto.PerformanceFavoriteDto;
import com.tracklog.api.domain.performance.service.PerformanceFavoriteService;
import com.tracklog.api.global.common.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/performance-favorites")
@RequiredArgsConstructor
@Tag(name = "Performance Favorite", description = "관심 공연 관리 API")
public class PerformanceFavoriteController {
    
    private final PerformanceFavoriteService performanceFavoriteService;
    
    /**
     * 관심 공연 추가/취소 토글
     */
    @PostMapping("/{performanceId}")
    @Operation(summary = "관심 공연 토글", description = "관심 공연을 추가하거나 이미 등록되어 있다면 취소합니다.")
    public ResponseEntity<ApiResponse<Map<String, Boolean>>> togglePerformanceFavorite(
            @PathVariable Long performanceId,
            @AuthenticationPrincipal Long userId
    ) {
        log.info("=== 관심 공연 토글 요청 ===");
        log.info("User ID: {}, Performance ID: {}", userId, performanceId);
        
        boolean isFavorited = performanceFavoriteService.toggleFavorite(userId, performanceId);
        
        return ResponseEntity.ok(ApiResponse.success(Map.of("isFavorited", isFavorited)));
    }
    
    /**
     * 관심 공연 상태 확인
     */
    @GetMapping("/{performanceId}/status")
    @Operation(summary = "관심 공연 상태 확인", description = "현재 사용자가 해당 공연을 관심 등록했는지 여부를 확인합니다.")
    public ResponseEntity<ApiResponse<Map<String, Boolean>>> checkPerformanceFavoriteStatus(
            @PathVariable Long performanceId,
            @AuthenticationPrincipal Long userId
    ) {
        log.info("=== 관심 공연 상태 확인 요청 ===");
        log.info("User ID: {}, Performance ID: {}", userId, performanceId);
        
        boolean isFavorited = performanceFavoriteService.isFavorite(userId, performanceId);
        
        return ResponseEntity.ok(ApiResponse.success(Map.of("isFavorited", isFavorited)));
    }
    
    /**
     * 내 관심 공연 목록 조회
     */
    @GetMapping
    @Operation(summary = "내 관심 공연 목록", description = "로그인한 사용자의 관심 공연 목록을 최신 등록순으로 조회합니다.")
    public ResponseEntity<ApiResponse<Page<PerformanceFavoriteDto>>> getMyPerformanceFavorites(
            @AuthenticationPrincipal Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        log.info("=== 내 관심 공연 목록 조회 요청 ===");
        log.info("User ID: {}, Page: {}, Size: {}", userId, page, size);
        
        // 관심 등록 시간(createdAt)을 기준으로 역순 정렬(최신순)하여 페이징 세팅
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<PerformanceFavoriteDto> favorites = performanceFavoriteService.getUserFavorites(userId, pageable);
        
        log.info("✓ 조회 완료: 총 {} 건", favorites.getTotalElements());
        
        return ResponseEntity.ok(ApiResponse.success(favorites));
    }
}