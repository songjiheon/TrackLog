package com.tracklog.api.domain.review.controller;

import com.tracklog.api.domain.review.dto.ReviewRequest;
import com.tracklog.api.domain.review.dto.ReviewResponse;
import com.tracklog.api.domain.review.dto.TrackRatingStatistics;
import com.tracklog.api.domain.review.service.ReviewService;
import com.tracklog.api.global.common.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/v1/reviews")
@RequiredArgsConstructor
@Tag(name = "Review", description = "리뷰 관리 API")
public class ReviewController {
    
    private final ReviewService reviewService;
    
    /**
     * 리뷰 작성
     */
    @PostMapping
    @Operation(summary = "리뷰 작성", description = "트랙에 대한 리뷰를 작성합니다")
    public ResponseEntity<ApiResponse<ReviewResponse>> createReview(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody ReviewRequest request
    ) {
        log.info("=== 리뷰 작성 요청 ===");
        log.info("User ID: {}, Track ID: {}, Rating: {}", 
                userId, request.getTrackId(), request.getRating());
        
        ReviewResponse response = reviewService.createReview(userId, request);
        
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    /**
     * 리뷰 수정
     */
    @PutMapping("/{reviewId}")
    @Operation(summary = "리뷰 수정", description = "작성한 리뷰를 수정합니다")
    public ResponseEntity<ApiResponse<ReviewResponse>> updateReview(
            @PathVariable Long reviewId,
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody ReviewRequest request
    ) {
        log.info("=== 리뷰 수정 요청 ===");
        log.info("Review ID: {}, User ID: {}", reviewId, userId);
        
        ReviewResponse response = reviewService.updateReview(reviewId, userId, request);
        
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    /**
     * 리뷰 삭제
     */
    @DeleteMapping("/{reviewId}")
    @Operation(summary = "리뷰 삭제", description = "작성한 리뷰를 삭제합니다")
    public ResponseEntity<ApiResponse<Void>> deleteReview(
            @PathVariable Long reviewId,
            @AuthenticationPrincipal Long userId
    ) {
        log.info("=== 리뷰 삭제 요청 ===");
        log.info("Review ID: {}, User ID: {}", reviewId, userId);
        
        reviewService.deleteReview(reviewId, userId);
        
        return ResponseEntity.ok(ApiResponse.success(null));
    }
    
    /**
     * 리뷰 단건 조회
     */
    @GetMapping("/{reviewId}")
    @Operation(summary = "리뷰 조회", description = "특정 리뷰를 조회합니다")
    public ResponseEntity<ApiResponse<ReviewResponse>> getReview(
            @PathVariable Long reviewId
    ) {
        log.info("=== 리뷰 조회 요청 ===");
        log.info("Review ID: {}", reviewId);
        
        ReviewResponse response = reviewService.getReview(reviewId);
        
        return ResponseEntity.ok(ApiResponse.success(response));
    }
    
    /**
     * 트랙의 모든 리뷰 조회 (페이징)
     */
    @GetMapping("/track/{trackId}")
    @Operation(summary = "트랙 리뷰 목록", description = "특정 트랙의 모든 리뷰를 조회합니다")
    public ResponseEntity<ApiResponse<Page<ReviewResponse>>> getTrackReviews(
            @Parameter(description = "트랙 ID") 
            @PathVariable Long trackId,
            
            @Parameter(description = "페이지 번호 (0부터 시작)") 
            @RequestParam(defaultValue = "0") int page,
            
            @Parameter(description = "페이지 크기") 
            @RequestParam(defaultValue = "10") int size
    ) {
        log.info("=== 트랙 리뷰 목록 조회 ===");
        log.info("Track ID: {}, Page: {}, Size: {}", trackId, page, size);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        
        Page<ReviewResponse> reviews = reviewService.getTrackReviews(trackId, pageable);
        
        log.info("✓ 조회 완료: {} 건", reviews.getTotalElements());
        
        return ResponseEntity.ok(ApiResponse.success(reviews));
    }
    
    /**
     * 사용자의 모든 리뷰 조회 (페이징)
     */
    @GetMapping("/user/{userId}")
    @Operation(summary = "사용자 리뷰 목록", description = "특정 사용자의 모든 리뷰를 조회합니다")
    public ResponseEntity<ApiResponse<Page<ReviewResponse>>> getUserReviews(
            @Parameter(description = "사용자 ID") 
            @PathVariable Long userId,
            
            @Parameter(description = "페이지 번호") 
            @RequestParam(defaultValue = "0") int page,
            
            @Parameter(description = "페이지 크기") 
            @RequestParam(defaultValue = "10") int size
    ) {
        log.info("=== 사용자 리뷰 목록 조회 ===");
        log.info("User ID: {}, Page: {}, Size: {}", userId, page, size);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        
        Page<ReviewResponse> reviews = reviewService.getUserReviews(userId, pageable);
        
        log.info("✓ 조회 완료: {} 건", reviews.getTotalElements());
        
        return ResponseEntity.ok(ApiResponse.success(reviews));
    }
    
    /**
     * 내 리뷰 목록 조회 (페이징)
     */
    @GetMapping("/my")
    @Operation(summary = "내 리뷰 목록", description = "로그인한 사용자의 모든 리뷰를 조회합니다")
    public ResponseEntity<ApiResponse<Page<ReviewResponse>>> getMyReviews(
            @AuthenticationPrincipal Long userId,
            
            @Parameter(description = "페이지 번호") 
            @RequestParam(defaultValue = "0") int page,
            
            @Parameter(description = "페이지 크기") 
            @RequestParam(defaultValue = "10") int size
    ) {
        log.info("=== 내 리뷰 목록 조회 ===");
        log.info("User ID: {}", userId);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        
        Page<ReviewResponse> reviews = reviewService.getUserReviews(userId, pageable);
        
        return ResponseEntity.ok(ApiResponse.success(reviews));
    }
    
    /**
     * 트랙 평점 통계
     */
    @GetMapping("/track/{trackId}/statistics")
    @Operation(summary = "트랙 평점 통계", description = "트랙의 평균 평점과 평점 분포를 조회합니다")
    public ResponseEntity<ApiResponse<TrackRatingStatistics>> getTrackStatistics(
            @Parameter(description = "트랙 ID") @PathVariable Long trackId
    ) {
        log.info("=== 트랙 평점 통계 조회 ===");
        log.info("Track ID: {}", trackId);
        
        TrackRatingStatistics statistics = reviewService.getTrackStatistics(trackId);
        
        log.info("✓ 평균 평점: {}, 리뷰 수: {}", 
                statistics.getAverageRating(), statistics.getReviewCount());
        
        return ResponseEntity.ok(ApiResponse.success(statistics));
    }
    
    /**
     * 특정 트랙에 대한 내 리뷰 조회
     */
    @GetMapping("/track/{trackId}/my")
    @Operation(summary = "내 리뷰 조회", description = "특정 트랙에 대한 내 리뷰를 조회합니다")
    public ResponseEntity<ApiResponse<ReviewResponse>> getMyReviewForTrack(
            @PathVariable Long trackId,
            @AuthenticationPrincipal Long userId
    ) {
        log.info("=== 내 리뷰 조회 ===");
        log.info("Track ID: {}, User ID: {}", trackId, userId);
        
        ReviewResponse review = reviewService.getMyReviewForTrack(userId, trackId);
        
        return ResponseEntity.ok(ApiResponse.success(review));
    }
}