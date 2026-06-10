package com.tracklog.api.domain.review.dto;

import com.tracklog.api.domain.review.entity.Review;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReviewResponse {
    
    private Long id;
    private Long userId;
    private String nickname;
    private Long trackId;
    private String trackName;
    private String artist;
    private Integer rating;
    private String content;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public static ReviewResponse from(Review review) {
        return ReviewResponse.builder()
                .id(review.getId())
                .userId(review.getUser().getId())
                .nickname(review.getUser().getNickname())
                .trackId(review.getTrack().getId())
                .trackName(review.getTrack().getName())
                .artist(review.getTrack().getArtist())
                .rating(review.getRating())
                .content(review.getContent())
                .createdAt(review.getCreatedAt())
                .updatedAt(review.getUpdatedAt())
                .build();
    }
}