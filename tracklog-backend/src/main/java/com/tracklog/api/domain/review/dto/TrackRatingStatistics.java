package com.tracklog.api.domain.review.dto;


import lombok.*;


@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrackRatingStatistics {
    
    private Long trackId;
    private String trackName;
    private String artist;
    private Double averageRating;
    private Long reviewCount;
    private Long rating5Count;
    private Long rating4Count;
    private Long rating3Count;
    private Long rating2Count;
    private Long rating1Count;
}