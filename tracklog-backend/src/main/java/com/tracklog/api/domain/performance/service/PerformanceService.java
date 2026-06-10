package com.tracklog.api.domain.performance.service;

import com.tracklog.api.domain.performance.dto.PerformanceResponse;
import com.tracklog.api.domain.performance.entity.Performance;
import com.tracklog.api.domain.performance.repository.PerformanceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PerformanceService {
    
    private final PerformanceRepository performanceRepository;
    
    /**
     * 공연 목록 조회 (전체)
     */
    public Page<PerformanceResponse> getAllPerformances(Pageable pageable) {
        Page<Performance> performances = performanceRepository.findAll(pageable);
        return performances.map(PerformanceResponse::from);
    }
    
    /**
     * 공연 중인 목록
     */
    public Page<PerformanceResponse> getOngoingPerformances(Pageable pageable) {
        LocalDate today = LocalDate.now();
        Page<Performance> performances = performanceRepository.findOngoingPerformances(today, pageable);
        return performances.map(PerformanceResponse::from);
    }
    
    /**
     * 공연 예정 목록
     */
    public Page<PerformanceResponse> getUpcomingPerformances(Pageable pageable) {
        LocalDate today = LocalDate.now();
        Page<Performance> performances = performanceRepository.findUpcomingPerformances(today, pageable);
        return performances.map(PerformanceResponse::from);
    }
    
    /**
     * 제목으로 검색
     */
    public Page<PerformanceResponse> searchByTitle(String keyword, Pageable pageable) {
        Page<Performance> performances = performanceRepository.findByTitleContaining(keyword, pageable);
        return performances.map(PerformanceResponse::from);
    }
    
    /**
     * 장르별 조회
     */
    public Page<PerformanceResponse> getByGenre(String genre, Pageable pageable) {
        Page<Performance> performances = performanceRepository.findByGenre(genre, pageable);
        return performances.map(PerformanceResponse::from);
    }
    
    /**
     * 지역별 조회
     */
    public Page<PerformanceResponse> getByArea(String area, Pageable pageable) {
        Page<Performance> performances = performanceRepository.findByArea(area, pageable);
        return performances.map(PerformanceResponse::from);
    }
    
    /**
     * 공연 상세 조회
     */
    public PerformanceResponse getPerformance(Long id) {
        Performance performance = performanceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("공연을 찾을 수 없습니다"));
        
        return PerformanceResponse.from(performance);
    }
}