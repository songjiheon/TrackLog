package com.tracklog.api.domain.performance.repository;

import com.tracklog.api.domain.performance.entity.Performance;
import com.tracklog.api.domain.performance.entity.PerformanceFavorite;
import com.tracklog.api.domain.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface PerformanceFavoriteRepository extends JpaRepository<PerformanceFavorite, Long> {
    
    // 유저와 공연 정보로 관심 등록 내역 찾기
    Optional<PerformanceFavorite> findByUserAndPerformance(User user, Performance performance);
    
    // 유저와 공연 정보로 등록 여부 존재 확인
    boolean existsByUserAndPerformance(User user, Performance performance);
    
    // 유저 ID 기준 내 관심 공연 목록 페이징 조회 (Fetch Join으로 N+1 문제 방지)
    @Query("select pf from PerformanceFavorite pf join fetch pf.performance where pf.user.id = :userId")
    Page<PerformanceFavorite> findByUserIdWithPerformance(@Param("userId") Long userId, Pageable pageable);
}