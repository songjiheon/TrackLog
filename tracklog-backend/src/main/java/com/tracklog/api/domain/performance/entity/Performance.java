package com.tracklog.api.domain.performance.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "performances")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Performance {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true, length = 50)
    private String kopisId; // KOPIS 공연 ID (mt20id)
    
    @Column(nullable = false, length = 255)
    private String title; // 공연명
    
    @Column(length = 100)
    private String genre; // 장르
    
    @Column(length = 50)
    private String state; // 공연 상태
    
    @Column(length = 255)
    private String place; // 공연장명
    
    @Column(length = 100)
    private String area; // 지역
    
    @Column
    private LocalDate startDate; // 시작일
    
    @Column
    private LocalDate endDate; // 종료일
    
    @Column(length = 500)
    private String posterUrl; // 포스터 URL
    
    @Column(length = 500)
    private String cast; // 출연진
    
    @Column(length = 100)
    private String runtime; // 공연시간
    
    @Column(length = 50)
    private String age; // 관람연령
    
    @Column(columnDefinition = "TEXT")
    private String synopsis; // 줄거리
    
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(nullable = false)
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}