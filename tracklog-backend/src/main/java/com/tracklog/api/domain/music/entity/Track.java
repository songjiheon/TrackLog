package com.tracklog.api.domain.music.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;

@Entity
@Table(name = "tracks")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Track {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true)
    private String spotifyId;  // Spotify Track ID
    
    @Column(nullable = false)
    private String name;
    
    @Column(nullable = false)
    private String artist;
    
    private String album;
    
    private String albumImageUrl;
    
    private Integer durationMs;  // 재생 시간 (밀리초)
    
    private String previewUrl;  // 미리듣기 URL
    
    @Column(length = 1000)
    private String spotifyUri;
    
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /* 
    @OneToMany(mappedBy = "track", cascade = CascadeType.ALL)
    private List<Review> reviews = new ArrayList<>();
    
    // 평균 별점 계산 메서드 추가
    public Double getAverageRating() {
        if (reviews.isEmpty()) return 0.0;
        return reviews.stream()
                .mapToInt(Review::getRating)
                .average()
                .orElse(0.0);
    }
                */
}