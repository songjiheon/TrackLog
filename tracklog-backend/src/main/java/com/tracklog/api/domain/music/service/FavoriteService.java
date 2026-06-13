package com.tracklog.api.domain.music.service;

import com.tracklog.api.domain.music.dto.FavoriteDto;
import com.tracklog.api.domain.music.dto.TrackDto;
import com.tracklog.api.domain.music.entity.Favorite;
import com.tracklog.api.domain.music.entity.Track;
import com.tracklog.api.domain.music.repository.FavoriteRepository;
import com.tracklog.api.domain.music.repository.TrackRepository;
import com.tracklog.api.domain.user.entity.User;
import com.tracklog.api.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FavoriteService {
    
    private final FavoriteRepository favoriteRepository;
    private final TrackRepository trackRepository;
    private final UserRepository userRepository;
    private final SpotifyService spotifyService;
    
    /**
     * 좋아요 추가/취소 토글
     */
    @Transactional
    public boolean toggleFavorite(Long userId, String spotifyTrackId) {
        log.info("좋아요 토글 - userId: {}, spotifyTrackId: {}", userId, spotifyTrackId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다"));
        
        // Track 조회 또는 생성
        Track track = trackRepository.findBySpotifyId(spotifyTrackId)
                .orElseGet(() -> {
                    log.info("트랙이 DB에 없음. Spotify에서 가져오는 중...");
                    try {
                        TrackDto trackDto = spotifyService.getTrack(spotifyTrackId);
                        return spotifyService.saveTrack(trackDto);
                    } catch (Exception e) {
                        throw new RuntimeException("트랙을 찾을 수 없습니다: " + spotifyTrackId);
                    }
                });
        
        // 이미 좋아요되어 있으면 취소
        Optional<Favorite> existingFavorite = favoriteRepository.findByUserAndTrack(user, track);
        if (existingFavorite.isPresent()) {
            favoriteRepository.delete(existingFavorite.get());
            log.info("✓ 좋아요 취소");
            return false; // 좋아요 취소됨
        }
        
        // 좋아요 추가
        Favorite favorite = Favorite.builder()
                .user(user)
                .track(track)
                .build();
        
        favoriteRepository.save(favorite);
        log.info("✓ 좋아요 추가");
        return true; // 좋아요 추가됨
    }
    
    /**
     * 좋아요 상태 확인
     */
    public boolean isFavorite(Long userId, String spotifyTrackId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다"));
        
        Track track = trackRepository.findBySpotifyId(spotifyTrackId)
                .orElse(null);
        
        if (track == null) {
            return false;
        }
        
        return favoriteRepository.existsByUserAndTrack(user, track);
    }
    
    /**
     * 사용자의 좋아요 목록 조회
     */
    public Page<FavoriteDto> getUserFavorites(Long userId, Pageable pageable) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다"));
        
        Page<Favorite> favorites = favoriteRepository.findByUserOrderByCreatedAtDesc(user, pageable);
        
        return favorites.map(FavoriteDto::from);
    }
}