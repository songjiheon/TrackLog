package com.tracklog.api.domain.review.repository;

import com.tracklog.api.domain.music.entity.Track;
import com.tracklog.api.domain.review.entity.Review;
import com.tracklog.api.domain.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ReviewRepository extends JpaRepository<Review, Long> {
    
    // ✅ Track 엔티티로 조회 (Spotify ID 대응)
    Optional<Review> findByUserIdAndTrack(Long userId, Track track);
    
    // ✅ Track 엔티티로 조회
    Page<Review> findByTrackOrderByCreatedAtDesc(Track track, Pageable pageable);
    
    // 특정 사용자의 모든 리뷰 (페이징)
    Page<Review> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);
    
    // ✅ Track 엔티티로 평균 평점
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.track = :track")
    Double findAverageRatingByTrack(@Param("track") Track track);
    
    // ✅ Track 엔티티로 리뷰 개수
    Long countByTrack(Track track);
    
    // ✅ Track 엔티티로 평점별 개수
    @Query("SELECT r.rating, COUNT(r) FROM Review r WHERE r.track = :track GROUP BY r.rating")
    List<Object[]> countByTrackGroupByRating(@Param("track") Track track);
    
    // ✅ User + Track 엔티티로 중복 확인
    boolean existsByUserAndTrack(User user, Track track);
    
    // ===== 기존 메소드 (하위 호환성 유지) =====
    
    // DB ID로 조회 (레거시)
    Optional<Review> findByUserIdAndTrackId(Long userId, Long trackId);
    Page<Review> findByTrackIdOrderByCreatedAtDesc(Long trackId, Pageable pageable);
    
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.track.id = :trackId")
    Double findAverageRatingByTrackId(@Param("trackId") Long trackId);
    
    Long countByTrackId(Long trackId);
    
    @Query("SELECT r.rating, COUNT(r) FROM Review r WHERE r.track.id = :trackId GROUP BY r.rating")
    List<Object[]> countByTrackIdGroupByRating(@Param("trackId") Long trackId);
    
    boolean existsByUserIdAndTrackId(Long userId, Long trackId);
}