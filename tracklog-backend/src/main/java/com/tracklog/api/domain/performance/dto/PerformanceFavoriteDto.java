package com.tracklog.api.domain.performance.dto;

import com.tracklog.api.domain.performance.entity.PerformanceFavorite;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PerformanceFavoriteDto {
    private Long id;                  // 관심 등록 고유 ID
    private Long performanceId;       // 내부 시스템 공연 ID (PK)
    private String kopisId;           // KOPIS 공연 ID
    private String title;             // 공연명
    private String genre;             // 장르
    private String place;             // 공연장명
    private LocalDate startDate;      // 시작일
    private String posterUrl;         // 포스터 URL
    private LocalDateTime createdAt;  // 관심 등록 일시

    public static PerformanceFavoriteDto from(PerformanceFavorite favorite) {
        return PerformanceFavoriteDto.builder()
                .id(favorite.getId())
                .performanceId(favorite.getPerformance().getId())
                .kopisId(favorite.getPerformance().getKopisId())
                .title(favorite.getPerformance().getTitle())
                .genre(favorite.getPerformance().getGenre())
                .place(favorite.getPerformance().getPlace())
                .startDate(favorite.getPerformance().getStartDate())
                .posterUrl(favorite.getPerformance().getPosterUrl())
                .createdAt(favorite.getCreatedAt())
                .build();
    }
}