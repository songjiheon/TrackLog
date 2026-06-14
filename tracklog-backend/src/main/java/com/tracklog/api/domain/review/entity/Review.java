package com.tracklog.api.domain.review.entity;

import com.tracklog.api.domain.music.entity.Track;
import com.tracklog.api.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "reviews")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
@EntityListeners(AuditingEntityListener.class)
public class Review {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "track_id", nullable = false)
    private Track track;
    
    @Column(nullable = false)
    private Integer rating; // 1~5점
    
    @Column(columnDefinition = "TEXT")
    private String content; // 리뷰 내용 (선택)
    
    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    @Column(nullable = false)
    private LocalDateTime updatedAt;
    
    // 비즈니스 메서드
    public void updateReview(Integer rating, String content) {
        this.rating = rating;
        this.content = content;
    }
    
    public boolean isOwnedBy(Long userId) {
        return this.user.getId().equals(userId);
    }
}