package com.tracklog.api.domain.performance.repository;

import com.tracklog.api.domain.performance.entity.Performance;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.Optional;

public interface PerformanceRepository extends JpaRepository<Performance, Long> {
    
    // KOPIS ID로 조회
    Optional<Performance> findByKopisId(String kopisId);
    
    // KOPIS ID 존재 여부
    boolean existsByKopisId(String kopisId);
    
    // 제목으로 검색
    Page<Performance> findByTitleContaining(String title, Pageable pageable);
    
    // 장르별 조회
    Page<Performance> findByGenre(String genre, Pageable pageable);
    
    // 지역별 조회
    Page<Performance> findByArea(String area, Pageable pageable);
    
    // 공연 중인 목록 (현재 날짜 기준)
    @Query("SELECT p FROM Performance p WHERE p.startDate <= :today AND p.endDate >= :today")
    Page<Performance> findOngoingPerformances(@Param("today") LocalDate today, Pageable pageable);
    
    // 공연 예정 목록
    @Query("SELECT p FROM Performance p WHERE p.startDate > :today")
    Page<Performance> findUpcomingPerformances(@Param("today") LocalDate today, Pageable pageable);
}