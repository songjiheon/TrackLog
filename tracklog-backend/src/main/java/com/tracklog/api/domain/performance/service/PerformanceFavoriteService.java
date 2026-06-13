package com.tracklog.api.domain.performance.service;

import com.tracklog.api.domain.performance.dto.PerformanceFavoriteDto;
import com.tracklog.api.domain.performance.entity.Performance;
import com.tracklog.api.domain.performance.entity.PerformanceFavorite;
import com.tracklog.api.domain.performance.repository.PerformanceFavoriteRepository;
import com.tracklog.api.domain.performance.repository.PerformanceRepository;
import com.tracklog.api.domain.user.entity.User;
import com.tracklog.api.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PerformanceFavoriteService {

    private final PerformanceFavoriteRepository performanceFavoriteRepository;
    private final PerformanceRepository performanceRepository;
    private final UserRepository userRepository;

    /**
     * 관심 공연 추가/취소 토글
     */
    @Transactional
    public boolean toggleFavorite(Long userId, Long performanceId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        Performance performance = performanceRepository.findById(performanceId)
                .orElseThrow(() -> new RuntimeException("공연 정보를 찾을 수 없습니다."));

        return performanceFavoriteRepository.findByUserAndPerformance(user, performance)
                .map(favorite -> {
                    performanceFavoriteRepository.delete(favorite);
                    log.info("✓ 관심 공연 취소 완료 - User: {}, Performance: {}", userId, performanceId);
                    return false;
                })
                .orElseGet(() -> {
                    PerformanceFavorite newFavorite = PerformanceFavorite.builder()
                            .user(user)
                            .performance(performance)
                            .build();
                    performanceFavoriteRepository.save(newFavorite);
                    log.info("✓ 관심 공연 추가 완료 - User: {}, Performance: {}", userId, performanceId);
                    return true;
                });
    }

    /**
     * 관심 공연 상태 확인
     */
    public boolean isFavorite(Long userId, Long performanceId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));
        
        Performance performance = performanceRepository.findById(performanceId)
                .orElseThrow(() -> new RuntimeException("공연 정보를 찾을 수 없습니다."));

        return performanceFavoriteRepository.existsByUserAndPerformance(user, performance);
    }

    /**
     * 사용자의 관심 공연 목록 조회 (페이징)
     */
    public Page<PerformanceFavoriteDto> getUserFavorites(Long userId, Pageable pageable) {
        if (!userRepository.existsById(userId)) {
            throw new RuntimeException("사용자를 찾을 수 없습니다.");
        }
        
        Page<PerformanceFavorite> favorites = performanceFavoriteRepository.findByUserIdWithPerformance(userId, pageable);
        return favorites.map(PerformanceFavoriteDto::from);
    }
}