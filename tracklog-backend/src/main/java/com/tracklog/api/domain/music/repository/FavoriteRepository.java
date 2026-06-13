package com.tracklog.api.domain.music.repository;

import com.tracklog.api.domain.music.entity.Favorite;
import com.tracklog.api.domain.music.entity.Track;
import com.tracklog.api.domain.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {
    
    // 사용자의 특정 트랙 좋아요 조회
    Optional<Favorite> findByUserAndTrack(User user, Track track);
    
    // 좋아요 존재 확인
    boolean existsByUserAndTrack(User user, Track track);
    
    // 사용자의 좋아요 목록 (페이징)
    Page<Favorite> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);
    
    // 사용자의 좋아요 개수
    Long countByUser(User user);
    
    // 트랙의 좋아요 개수
    Long countByTrack(Track track);
}