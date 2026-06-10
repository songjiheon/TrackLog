package com.tracklog.api.domain.performance.dto;

import lombok.*;

import java.time.LocalDate;


@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PerformanceSearchRequest {
    private String keyword;      // 제목 검색
    private String genre;        // 장르 필터
    private String area;         // 지역 필터
    private String state;        // 상태 필터 (공연중/예정/종료)
    private LocalDate startDate; // 시작일 필터
    private LocalDate endDate;   // 종료일 필터
}
