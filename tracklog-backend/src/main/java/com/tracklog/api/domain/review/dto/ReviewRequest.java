package com.tracklog.api.domain.review.dto;

import com.tracklog.api.domain.review.entity.Review;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDateTime;

// 리뷰 생성/수정 요청
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReviewRequest {
    
    @NotNull(message = "트랙 ID는 필수입니다")
    private Long trackId;
    
    @NotNull(message = "별점은 필수입니다")
    @Min(value = 1, message = "별점은 1~5 사이여야 합니다")
    @Max(value = 5, message = "별점은 1~5 사이여야 합니다")
    private Integer rating;
    
    @Size(max = 1000, message = "리뷰는 1000자 이하여야 합니다")
    private String content;
}
