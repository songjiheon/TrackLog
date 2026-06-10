package com.tracklog.api.domain.review.repository;

import com.tracklog.api.domain.review.entity.Review;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ReviewRepository extends JpaRepository<Review, Long> {
    
    // 사용자의 특정 트랙 리뷰 조회
    Optional<Review> findByUserIdAndTrackId(Long userId, Long trackId);
    
    // 특정 트랙의 모든 리뷰 (페이징)
    Page<Review> findByTrackIdOrderByCreatedAtDesc(Long trackId, Pageable pageable);
    
    // 특정 사용자의 모든 리뷰 (페이징)
    Page<Review> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);
    
    // 트랙의 평균 평점
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.track.id = :trackId")
    Double findAverageRatingByTrackId(@Param("trackId") Long trackId);
    
    // 트랙의 리뷰 개수
    Long countByTrackId(Long trackId);
    
    // 트랙의 평점별 개수
    @Query("SELECT r.rating, COUNT(r) FROM Review r WHERE r.track.id = :trackId GROUP BY r.rating")
    java.util.List<Object[]> countByTrackIdGroupByRating(@Param("trackId") Long trackId);
    
    // 중복 리뷰 존재 확인
    boolean existsByUserIdAndTrackId(Long userId, Long trackId);
}