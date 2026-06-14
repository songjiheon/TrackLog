package com.tracklog.api.domain.music.dto;

import com.tracklog.api.domain.music.entity.Favorite;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FavoriteDto {
    
    private Long id;
    private Long userId;
    private String spotifyId;
    private String trackName;
    private String artist;
    private String album;
    private String albumImageUrl;
    private LocalDateTime createdAt;
    
    public static FavoriteDto from(Favorite favorite) {
        return FavoriteDto.builder()
                .id(favorite.getId())
                .userId(favorite.getUser().getId())
                .spotifyId(favorite.getTrack().getSpotifyId())
                .trackName(favorite.getTrack().getName())
                .artist(favorite.getTrack().getArtist())
                .album(favorite.getTrack().getAlbum())
                .albumImageUrl(favorite.getTrack().getAlbumImageUrl())
                .createdAt(favorite.getCreatedAt())
                .build();
    }
}