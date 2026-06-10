package com.tracklog.api.domain.review.service;

import com.tracklog.api.domain.music.entity.Track;
import com.tracklog.api.domain.music.repository.TrackRepository;
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
    
    /**
     * 리뷰 작성
     */
    @Transactional
    public ReviewResponse createReview(Long userId, ReviewRequest request) {
        log.info("리뷰 작성 시작 - userId: {}, trackId: {}", userId, request.getTrackId());
        
        // 중복 리뷰 확인
        if (reviewRepository.existsByUserIdAndTrackId(userId, request.getTrackId())) {
            throw new RuntimeException("이미 해당 곡에 대한 리뷰가 존재합니다");
        }
        
        // 사용자 조회
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다"));
        
        // 트랙 조회
        Track track = trackRepository.findById(request.getTrackId())
                .orElseThrow(() -> new RuntimeException("트랙을 찾을 수 없습니다"));
        
        // 리뷰 생성
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
     * 트랙의 모든 리뷰 조회
     */
    public Page<ReviewResponse> getTrackReviews(Long trackId, Pageable pageable) {
        Page<Review> reviews = reviewRepository.findByTrackIdOrderByCreatedAtDesc(trackId, pageable);
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
     * 트랙 평점 통계
     */
    public TrackRatingStatistics getTrackStatistics(Long trackId) {
        Track track = trackRepository.findById(trackId)
                .orElseThrow(() -> new RuntimeException("트랙을 찾을 수 없습니다"));
        
        Double avgRating = reviewRepository.findAverageRatingByTrackId(trackId);
        Long reviewCount = reviewRepository.countByTrackId(trackId);
        
        // 평점별 개수
        List<Object[]> ratingCounts = reviewRepository.countByTrackIdGroupByRating(trackId);
        Map<Integer, Long> countMap = new HashMap<>();
        for (Object[] row : ratingCounts) {
            countMap.put((Integer) row[0], (Long) row[1]);
        }
        
        return TrackRatingStatistics.builder()
                .trackId(trackId)
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

    public ReviewResponse getReview(Long reviewId) {
        log.info("리뷰 조회 - reviewId: {}", reviewId);
    
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("리뷰를 찾을 수 없습니다"));
    
        return ReviewResponse.from(review);
    }


    //특정 트랙에 대한 사용자의 리뷰 조회 
    public ReviewResponse getMyReviewForTrack(Long userId, Long trackId) {
        log.info("내 리뷰 조회 - userId: {}, trackId: {}", userId, trackId);
    
        Review review = reviewRepository.findByUserIdAndTrackId(userId, trackId)
                 .orElseThrow(() -> new RuntimeException("해당 트랙에 대한 리뷰가 없습니다"));
    
        return ReviewResponse.from(review);
    }
}