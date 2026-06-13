package com.tracklog.api.domain.review.service;

import com.tracklog.api.domain.music.dto.TrackDto;
import com.tracklog.api.domain.music.entity.Track;
import com.tracklog.api.domain.music.repository.TrackRepository;
import com.tracklog.api.domain.music.service.SpotifyService;
import com.tracklog.api.domain.review.dto.ReviewRequest;
import com.tracklog.api.domain.review.dto.ReviewResponse;
import com.tracklog.api.domain.review.dto.TrackRatingStatistics;
import com.tracklog.api.domain.review.entity.Review;
import com.tracklog.api.domain.review.repository.ReviewRepository;
import com.tracklog.api.domain.user.entity.User;
import com.tracklog.api.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReviewService {
    
    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;
    private final TrackRepository trackRepository;
    private final SpotifyService spotifyService; 

    /**
     * 리뷰 작성
     */
    @Transactional
    public ReviewResponse createReview(Long userId, ReviewRequest request) {
        log.info("리뷰 작성 시작 - userId: {}, spotifyTrackId: {}", userId, request.getTrackId());
    
        // ✅ Spotify ID로 Track 조회, 없으면. Spotify API에서 가져와서 저장
        Track track = trackRepository.findBySpotifyId(request.getTrackId())
                .orElseGet(() -> {
                    log.info("트랙이 DB에 없음. Spotify에서 가져오는 중...");
                    try {
                        // Spotify API에서 트랙 정보 가져오기
                        TrackDto trackDto = spotifyService.getTrack(request.getTrackId());
                        //. DB에 저장
                        return spotifyService.saveTrack(trackDto);
                    } catch (Exception e) {
                        log.error("Spotify에서 트랙 조회 실패: {}", e.getMessage());
                        throw new RuntimeException("트랙을 찾을 수 없습니다: " + request.getTrackId());
                    }
                });
    
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다"));
    
        //. 중복 체크
        if (reviewRepository.existsByUserAndTrack(user, track)) {
        throw new RuntimeException("이미 해당 곡에 대한 리뷰가 존재합니다");
        }
    
    Review review = Review.builder()
            .user(user)
            .track(track)
            .rating(request.getRating())
            .content(request.getContent())
            .build();
    
    Review savedReview = reviewRepository.save(review);
    log.info("✓ 리뷰 작성 완료 - reviewId: {}", savedReview.getId());
    
    return ReviewResponse.from(savedReview);
}
    
    /**
     * 리뷰 수정
     */
    @Transactional
    public ReviewResponse updateReview(Long reviewId, Long userId, ReviewRequest request) {
        log.info("리뷰 수정 시작 - reviewId: {}, userId: {}", reviewId, userId);
        
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("리뷰를 찾을 수 없습니다"));
        
        // 권한 확인
        if (!review.isOwnedBy(userId)) {
            throw new RuntimeException("리뷰를 수정할 권한이 없습니다");
        }
        
        review.updateReview(request.getRating(), request.getContent());
        
        log.info("✓ 리뷰 수정 완료");
        return ReviewResponse.from(review);
    }
    
    //전체 리뷰
    public Page<ReviewResponse> getAllReviews(Pageable pageable) {
        log.info("전체 리뷰 목록 조회 - Page: {}, Size: {}", pageable.getPageNumber(), pageable.getPageSize());
        
        // 1. Repository에서 모든 리뷰를 페이징 조회 (정렬 조건은 Controller의 Pageable 설정을 따름)
        Page<Review> reviews = reviewRepository.findAll(pageable);
        
        // 2. Page 내 엔티티들을 ReviewResponse DTO로 변환하여 반환
        return reviews.map(ReviewResponse::from);
    }
    
    /**
     * 리뷰 삭제
     */
    @Transactional
    public void deleteReview(Long reviewId, Long userId) {
        log.info("리뷰 삭제 시작 - reviewId: {}, userId: {}", reviewId, userId);
        
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("리뷰를 찾을 수 없습니다"));
        
        // 권한 확인
        if (!review.isOwnedBy(userId)) {
            throw new RuntimeException("리뷰를 삭제할 권한이 없습니다");
        }
        
        reviewRepository.delete(review);
        log.info("✓ 리뷰 삭제 완료");
    }
    
    /**
     * 트랙의 모든 리뷰 조회 (Spotify ID 사용)
     */
    public Page<ReviewResponse> getTrackReviews(String spotifyTrackId, Pageable pageable) {
        Track track = trackRepository.findBySpotifyId(spotifyTrackId)
                .orElseThrow(() -> new RuntimeException("트랙을 찾을 수 없습니다"));
        
        Page<Review> reviews = reviewRepository.findByTrackOrderByCreatedAtDesc(track, pageable);
        return reviews.map(ReviewResponse::from);
    }
    
    /**
     * 사용자의 모든 리뷰 조회
     */
    public Page<ReviewResponse> getUserReviews(Long userId, Pageable pageable) {
        Page<Review> reviews = reviewRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        return reviews.map(ReviewResponse::from);
    }
    
    /**
     * 트랙 평점 통계 (Spotify ID 사용)
     */
    public TrackRatingStatistics getTrackStatistics(String spotifyTrackId) {
        Track track = trackRepository.findBySpotifyId(spotifyTrackId)
                .orElseThrow(() -> new RuntimeException("트랙을 찾을 수 없습니다"));
        
        Double avgRating = reviewRepository.findAverageRatingByTrack(track);
        Long reviewCount = reviewRepository.countByTrack(track);
        
        // 평점별 개수
        List<Object[]> ratingCounts = reviewRepository.countByTrackGroupByRating(track);
        Map<Integer, Long> countMap = new HashMap<>();
        for (Object[] row : ratingCounts) {
            countMap.put((Integer) row[0], (Long) row[1]);
        }
        
        return TrackRatingStatistics.builder()
                .trackId(spotifyTrackId)
                .trackName(track.getName())
                .artist(track.getArtist())
                .averageRating(avgRating != null ? avgRating : 0.0)
                .reviewCount(reviewCount)
                .rating5Count(countMap.getOrDefault(5, 0L))
                .rating4Count(countMap.getOrDefault(4, 0L))
                .rating3Count(countMap.getOrDefault(3, 0L))
                .rating2Count(countMap.getOrDefault(2, 0L))
                .rating1Count(countMap.getOrDefault(1, 0L))
                .build();
    }

    /**
     * 리뷰 단건 조회
     */
    public ReviewResponse getReview(Long reviewId) {
        log.info("리뷰 조회 - reviewId: {}", reviewId);
    
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("리뷰를 찾을 수 없습니다"));
    
        return ReviewResponse.from(review);
    }

    /**
     * 특정 트랙에 대한 사용자의 리뷰 조회 (Spotify ID 사용)
     */
    public ReviewResponse getMyReviewForTrack(Long userId, String spotifyTrackId) {
        log.info("내 리뷰 조회 - userId: {}, spotifyTrackId: {}", userId, spotifyTrackId);
        
        Track track = trackRepository.findBySpotifyId(spotifyTrackId)
                .orElseThrow(() -> new RuntimeException("트랙을 찾을 수 없습니다"));
        
        Review review = reviewRepository.findByUserIdAndTrack(userId, track)
                .orElseThrow(() -> new RuntimeException("해당 트랙에 대한 리뷰가 없습니다"));
        
        return ReviewResponse.from(review);
    }
}