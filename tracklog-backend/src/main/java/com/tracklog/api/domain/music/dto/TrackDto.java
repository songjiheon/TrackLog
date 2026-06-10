package com.tracklog.api.domain.music.dto;

import com.tracklog.api.domain.music.entity.Track;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@AllArgsConstructor
@Builder
public class TrackDto {
    
    private Long id;
    private String spotifyId;
    private String name;
    private String artist;
    private String album;
    private String albumImageUrl;
    private Integer durationMs;
    private String previewUrl;
    
    public static TrackDto from(Track track) {
        return TrackDto.builder()
                .id(track.getId())
                .spotifyId(track.getSpotifyId())
                .name(track.getName())
                .artist(track.getArtist())
                .album(track.getAlbum())
                .albumImageUrl(track.getAlbumImageUrl())
                .durationMs(track.getDurationMs())
                .previewUrl(track.getPreviewUrl())
                .build();
    }
}