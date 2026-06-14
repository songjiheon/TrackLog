package com.tracklog.api.domain.performance.controller;

import com.tracklog.api.domain.performance.dto.PerformanceResponse;
import com.tracklog.api.domain.performance.entity.Performance;
import com.tracklog.api.domain.performance.service.KopisService;
import com.tracklog.api.domain.performance.service.PerformanceService;
import com.tracklog.api.global.common.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/performances")
@RequiredArgsConstructor
@Tag(name = "Performance", description = "공연 정보 API")
public class PerformanceController {
    
    private final PerformanceService performanceService;
    private final KopisService kopisService;
    
    /**
     * KOPIS에서 공연 데이터 가져오기 (관리자용)
     */
    @PostMapping("/fetch")
    @Operation(summary = "KOPIS 공연 데이터 가져오기", description = "KOPIS API에서 공연 정보를 가져와 DB에 저장합니다")
    public ResponseEntity<ApiResponse<Map<String, Object>>> fetchPerformances(
            @Parameter(description = "시작일 (YYYYMMDD)") 
            @RequestParam(required = false) String startDate,
            
            @Parameter(description = "종료일 (YYYYMMDD)") 
            @RequestParam(required = false) String endDate,
            
            @Parameter(description = "조회 개수") 
            @RequestParam(defaultValue = "50") int rows
    ) {
        log.info("=== KOPIS 공연 데이터 가져오기 요청 ===");
        
        // 기본값: 오늘부터 3개월
        if (startDate == null) {
            startDate = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        }
        if (endDate == null) {
            endDate = LocalDate.now().plusMonths(3).format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        }
        
        List<Performance> performances = kopisService.fetchAndSavePerformances(startDate, endDate, rows);
        
        Map<String, Object> result = Map.of(
            "message", "KOPIS 공연 데이터 저장 완료",
            "savedCount", performances.size(),
            "period", startDate + " ~ " + endDate
        );
        
        return ResponseEntity.ok(ApiResponse.success(result));
    }
    
    /**
     * 공연 전체 목록 조회
     */
    @GetMapping
    @Operation(summary = "공연 목록 조회", description = "저장된 모든 공연 목록을 조회합니다")
    public ResponseEntity<ApiResponse<Page<PerformanceResponse>>> getAllPerformances(
            @Parameter(description = "페이지 번호") 
            @RequestParam(defaultValue = "0") int page,
            
            @Parameter(description = "페이지 크기") 
            @RequestParam(defaultValue = "20") int size,
            
            @Parameter(description = "정렬 기준 (startDate, title)") 
            @RequestParam(defaultValue = "startDate") String sort,
            
            @Parameter(description = "정렬 방향 (asc, desc)") 
            @RequestParam(defaultValue = "desc") String direction
    ) {
        log.info("=== 공연 목록 조회 ===");
        
        Sort.Direction sortDirection = "asc".equalsIgnoreCase(direction) ? 
                Sort.Direction.ASC : Sort.Direction.DESC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortDirection, sort));
        
        Page<PerformanceResponse> performances = performanceService.getAllPerformances(pageable);
        
        log.info("✓ 조회 완료: {} 건", performances.getTotalElements());
        
        return ResponseEntity.ok(ApiResponse.success(performances));
    }
    
    /**
     * 공연 상세 조회
     */
    @GetMapping("/{id}")
    @Operation(summary = "공연 상세 조회", description = "특정 공연의 상세 정보를 조회합니다")
    public ResponseEntity<ApiResponse<PerformanceResponse>> getPerformance(
            @Parameter(description = "공연 ID") 
            @PathVariable Long id
    ) {
        log.info("=== 공연 상세 조회: {} ===", id);
        
        PerformanceResponse performance = performanceService.getPerformance(id);
        
        return ResponseEntity.ok(ApiResponse.success(performance));
    }
    
    /**
     * 공연 중인 목록
     */
    @GetMapping("/ongoing")
    @Operation(summary = "공연 중인 목록", description = "현재 공연 중인 공연 목록을 조회합니다")
    public ResponseEntity<ApiResponse<Page<PerformanceResponse>>> getOngoingPerformances(
            @Parameter(description = "페이지 번호") 
            @RequestParam(defaultValue = "0") int page,
            
            @Parameter(description = "페이지 크기") 
            @RequestParam(defaultValue = "20") int size
    ) {
        log.info("=== 공연 중인 목록 조회 ===");
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "startDate"));
        
        Page<PerformanceResponse> performances = performanceService.getOngoingPerformances(pageable);
        
        log.info("✓ 공연 중: {} 건", performances.getTotalElements());
        
        return ResponseEntity.ok(ApiResponse.success(performances));
    }
    
    /**
     * 공연 예정 목록
     */
    @GetMapping("/upcoming")
    @Operation(summary = "공연 예정 목록", description = "앞으로 시작 예정인 공연 목록을 조회합니다")
    public ResponseEntity<ApiResponse<Page<PerformanceResponse>>> getUpcomingPerformances(
            @Parameter(description = "페이지 번호") 
            @RequestParam(defaultValue = "0") int page,
            
            @Parameter(description = "페이지 크기") 
            @RequestParam(defaultValue = "20") int size
    ) {
        log.info("=== 공연 예정 목록 조회 ===");
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "startDate"));
        
        Page<PerformanceResponse> performances = performanceService.getUpcomingPerformances(pageable);
        
        log.info("✓ 공연 예정: {} 건", performances.getTotalElements());
        
        return ResponseEntity.ok(ApiResponse.success(performances));
    }
    
    /**
     * 공연 검색 (제목)
     */
    @GetMapping("/search")
    @Operation(summary = "공연 검색", description = "제목으로 공연을 검색합니다")
    public ResponseEntity<ApiResponse<Page<PerformanceResponse>>> searchPerformances(
            @Parameter(description = "검색 키워드") 
            @RequestParam String keyword,
            
            @Parameter(description = "페이지 번호") 
            @RequestParam(defaultValue = "0") int page,
            
            @Parameter(description = "페이지 크기") 
            @RequestParam(defaultValue = "20") int size
    ) {
        log.info("=== 공연 검색: {} ===", keyword);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "startDate"));
        
        Page<PerformanceResponse> performances = performanceService.searchByTitle(keyword, pageable);
        
        log.info("✓ 검색 결과: {} 건", performances.getTotalElements());
        
        return ResponseEntity.ok(ApiResponse.success(performances));
    }
    
    /**
     * 장르별 조회
     */
    @GetMapping("/genre/{genre}")
    @Operation(summary = "장르별 공연 조회", description = "특정 장르의 공연을 조회합니다")
    public ResponseEntity<ApiResponse<Page<PerformanceResponse>>> getPerformancesByGenre(
            @Parameter(description = "장르 (콘서트, 뮤지컬, 연극 등)") 
            @PathVariable String genre,
            
            @Parameter(description = "페이지 번호") 
            @RequestParam(defaultValue = "0") int page,
            
            @Parameter(description = "페이지 크기") 
            @RequestParam(defaultValue = "20") int size
    ) {
        log.info("=== 장르별 공연 조회: {} ===", genre);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "startDate"));
        
        Page<PerformanceResponse> performances = performanceService.getByGenre(genre, pageable);
        
        log.info("✓ {} 장르: {} 건", genre, performances.getTotalElements());
        
        return ResponseEntity.ok(ApiResponse.success(performances));
    }
    
    /**
     * 지역별 조회
     */
    @GetMapping("/area/{area}")
    @Operation(summary = "지역별 공연 조회", description = "특정 지역의 공연을 조회합니다")
    public ResponseEntity<ApiResponse<Page<PerformanceResponse>>> getPerformancesByArea(
            @Parameter(description = "지역 (서울, 경기, 부산 등)") 
            @PathVariable String area,
            
            @Parameter(description = "페이지 번호") 
            @RequestParam(defaultValue = "0") int page,
            
            @Parameter(description = "페이지 크기") 
            @RequestParam(defaultValue = "20") int size
    ) {
        log.info("=== 지역별 공연 조회: {} ===", area);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "startDate"));
        
        Page<PerformanceResponse> performances = performanceService.getByArea(area, pageable);
        
        log.info("✓ {} 지역: {} 건", area, performances.getTotalElements());
        
        return ResponseEntity.ok(ApiResponse.success(performances));
    }
}