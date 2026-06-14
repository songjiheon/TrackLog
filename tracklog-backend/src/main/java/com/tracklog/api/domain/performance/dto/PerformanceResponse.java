package com.tracklog.api.domain.performance.dto;

import com.tracklog.api.domain.performance.entity.Performance;
import lombok.*;

import java.time.LocalDate;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PerformanceResponse {
    
    private Long id;
    private String kopisId;
    private String title;
    private String genre;
    private String state;
    private String place;
    private String area;
    private LocalDate startDate;
    private LocalDate endDate;
    private String posterUrl;
    private String cast;
    private String runtime;
    private String age;
    private String synopsis;
    
    public static PerformanceResponse from(Performance performance) {
        return PerformanceResponse.builder()
                .id(performance.getId())
                .kopisId(performance.getKopisId())
                .title(performance.getTitle())
                .genre(performance.getGenre())
                .state(performance.getState())
                .place(performance.getPlace())
                .area(performance.getArea())
                .startDate(performance.getStartDate())
                .endDate(performance.getEndDate())
                .posterUrl(performance.getPosterUrl())
                .cast(performance.getCast())
                .runtime(performance.getRuntime())
                .age(performance.getAge())
                .synopsis(performance.getSynopsis())
                .build();
    }
}
