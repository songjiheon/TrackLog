package com.tracklog.api.domain.music.service;

import com.tracklog.api.domain.music.dto.TrackDto;
import com.tracklog.api.domain.music.entity.Track;
import com.tracklog.api.domain.music.repository.TrackRepository;

import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.hc.core5.http.ParseException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import se.michaelthelin.spotify.SpotifyApi;
import se.michaelthelin.spotify.exceptions.SpotifyWebApiException;
import se.michaelthelin.spotify.model_objects.credentials.ClientCredentials;
import se.michaelthelin.spotify.model_objects.specification.Paging;
import se.michaelthelin.spotify.requests.authorization.client_credentials.ClientCredentialsRequest;
import se.michaelthelin.spotify.requests.data.search.simplified.SearchTracksRequest;
import se.michaelthelin.spotify.requests.data.tracks.GetTrackRequest;

import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SpotifyService {
    
    private final SpotifyApi spotifyApi;
    private final TrackRepository trackRepository;
    
    private Instant tokenExpiryTime;
    
    /**
     * 음악 검색 (Client Credentials 사용)
     */
    /* 
    public List<TrackDto> searchTracks(String query, int limit) {
        log.info("=== 음악 검색 시작 ===");
        log.info("Query: {}, Limit: {}", query, limit);
        
        // 토큰 확인 및 갱신
        ensureValidToken();
        
        try {
            SearchTracksRequest searchTracksRequest = spotifyApi
                    .searchTracks(query)
                    .limit(limit)
                    .market(com.neovisionaries.i18n.CountryCode.KR)
                    .build();
            
            Paging<se.michaelthelin.spotify.model_objects.specification.Track> trackPaging = 
                    searchTracksRequest.execute();
            
            log.info("✓ 검색 성공: {}개 결과", trackPaging.getItems().length);
            
            return Arrays.stream(trackPaging.getItems())
                    .map(this::convertToTrackDto)
                    .collect(Collectors.toList());
                    
        } catch (IOException | SpotifyWebApiException | ParseException e) {
            log.error("✗ 음악 검색 실패", e);
            throw new RuntimeException("음악 검색에 실패했습니다: " + e.getMessage(), e);
        }
    }
        */

    public List<TrackDto> searchTracks(String query, int limit) {
    log.info("=== 음악 검색 시작 ===");
    log.info("Query: {}, Limit: {}", query, limit);
    
    ensureValidToken();
    
    try {
        List<TrackDto> allTracks = new ArrayList<>();
        
        // ✅ limit을 10씩 나눠서 요청
        int remaining = limit;
        int offset = 0;
        
        while (remaining > 0) {
            int currentLimit = Math.min(10, remaining);
            
            log.info("요청 - offset: {}, limit: {}", offset, currentLimit);
            
            SearchTracksRequest searchTracksRequest = spotifyApi
                    .searchTracks(query)
                    .limit(currentLimit)
                    .offset(offset)
                    .build();
            
            Paging<se.michaelthelin.spotify.model_objects.specification.Track> trackPaging = 
                    searchTracksRequest.execute();
            
            se.michaelthelin.spotify.model_objects.specification.Track[] items = trackPaging.getItems();
            
            if (items.length == 0) {
                break; // 더 이상 결과 없음
            }
            
            List<TrackDto> tracks = Arrays.stream(items)
                    .map(this::convertToTrackDto)
                    .collect(Collectors.toList());
            
            allTracks.addAll(tracks);
            
            offset += currentLimit;
            remaining -= currentLimit;
            
            // 실제 반환된 결과가 요청한 것보다 적으면 더 이상 없는 것
            if (items.length < currentLimit) {
                break;
            }
        }
        
        log.info("✓ 검색 성공: {}개 결과", allTracks.size());
        
        return allTracks;
        
    } catch (IOException | SpotifyWebApiException | ParseException e) {
        log.error("✗ 음악 검색 실패: {}", e.getMessage());
        throw new RuntimeException("음악 검색에 실패했습니다: " + e.getMessage(), e);
    }
}
    
    /**
     * 트랙 ID로 직접 조회
     */
    public TrackDto getTrack(String trackId) {
        log.info("=== 트랙 조회 시작: {} ===", trackId);
        
        ensureValidToken();
        
        try {
            GetTrackRequest getTrackRequest = spotifyApi.getTrack(trackId).build();
            se.michaelthelin.spotify.model_objects.specification.Track track = 
                    getTrackRequest.execute();
            
            log.info("✓ 트랙 조회 성공: {} - {}", track.getName(), track.getArtists()[0].getName());
            
            return convertToTrackDto(track);
            
        } catch (IOException | SpotifyWebApiException | ParseException e) {
            log.error("✗ 트랙 조회 실패: {}", trackId, e);
            throw new RuntimeException("트랙 조회에 실패했습니다", e);
        }
    }
    
    /**
     * 유효한 토큰 확보 (Client Credentials)
     */
    private void ensureValidToken() {
        // 토큰이 없거나 만료 예정이면 새로 발급
        if (spotifyApi.getAccessToken() == null || isTokenExpiringSoon()) {
            log.info("토큰 갱신 필요");
            authenticateClientCredentials();
        } else {
            log.debug("기존 토큰 사용 (만료까지 {}초 남음)", 
                    tokenExpiryTime != null ? 
                        java.time.Duration.between(Instant.now(), tokenExpiryTime).getSeconds() : 
                        "알 수 없음");
        }
    }
    
    /**
     * 토큰 만료 임박 확인
     */
    private boolean isTokenExpiringSoon() {
        if (tokenExpiryTime == null) {
            return true;
        }
        // 만료 5분 전이면 갱신
        return Instant.now().plusSeconds(300).isAfter(tokenExpiryTime);
    }
    
    /**
     * Client Credentials 방식으로 Access Token 발급
     */
    private void authenticateClientCredentials() {
        try {
            log.info("Client Credentials 인증 시작");
            
            ClientCredentialsRequest clientCredentialsRequest = spotifyApi
                    .clientCredentials()
                    .build();
            
            ClientCredentials clientCredentials = clientCredentialsRequest.execute();
            
            spotifyApi.setAccessToken(clientCredentials.getAccessToken());
            
            // 만료 시간 계산 (현재 시간 + expiresIn - 60초 여유)
            Integer expiresIn = clientCredentials.getExpiresIn();
            if (expiresIn != null) {
                tokenExpiryTime = Instant.now().plusSeconds(expiresIn - 60);
            }
            
            log.info("✓ Client Credentials Token 발급 성공. 만료: {}초", expiresIn);
            
        } catch (IOException | SpotifyWebApiException | ParseException e) {
            log.error("✗ Client Credentials 인증 실패", e);
            throw new RuntimeException("Spotify 인증에 실패했습니다", e);
        }
    }
    
    /**
     * Spotify Track을 DTO로 변환
     */
    private TrackDto convertToTrackDto(se.michaelthelin.spotify.model_objects.specification.Track track) {
        return TrackDto.builder()
                .spotifyId(track.getId())
                .name(track.getName())
                .artist(track.getArtists().length > 0 ? track.getArtists()[0].getName() : "Unknown")
                .album(track.getAlbum().getName())
                .albumImageUrl(track.getAlbum().getImages().length > 0 ? 
                        track.getAlbum().getImages()[0].getUrl() : null)
                .durationMs(track.getDurationMs())
                .previewUrl(track.getPreviewUrl())
                .build();
    }
    
    /**
     * 트랙 저장 (DB에)
     */
    @Transactional
    public Track saveTrack(TrackDto trackDto) {
        return trackRepository.findBySpotifyId(trackDto.getSpotifyId())
                .orElseGet(() -> {
                    Track track = Track.builder()
                            .spotifyId(trackDto.getSpotifyId())
                            .name(trackDto.getName())
                            .artist(trackDto.getArtist())
                            .album(trackDto.getAlbum())
                            .albumImageUrl(trackDto.getAlbumImageUrl())
                            .durationMs(trackDto.getDurationMs())
                            .previewUrl(trackDto.getPreviewUrl())
                            .build();
                    
                    log.info("✓ 트랙 저장: {} - {}", track.getName(), track.getArtist());
                    return trackRepository.save(track);
                });
    }
    @PostConstruct
    public void initMockData() {
        // 이미 데이터가 있으면 스킵
        if (trackRepository.count() > 0) {
            log.info("트랙 데이터가 이미 존재합니다");
            return;
        }
        
        log.info("Mock 트랙 데이터 생성 중...");
        
        List<Track> mockTracks = Arrays.asList(
            Track.builder()
                .spotifyId("mock-1")
                .name("Dynamite")
                .artist("BTS")
                .album("Dynamite")
                .albumImageUrl("https://via.placeholder.com/300")
                .durationMs(199054)
                .build(),
            
            Track.builder()
                .spotifyId("mock-2")
                .name("Butter")
                .artist("BTS")
                .album("Butter")
                .albumImageUrl("https://via.placeholder.com/300")
                .durationMs(164442)
                .build(),
            
            Track.builder()
                .spotifyId("mock-3")
                .name("Boy With Luv (feat. Halsey)")
                .artist("BTS")
                .album("MAP OF THE SOUL : PERSONA")
                .albumImageUrl("https://via.placeholder.com/300")
                .durationMs(230000)
                .build()
        );
        
        trackRepository.saveAll(mockTracks);
        log.info("✓ Mock 트랙 {} 개 생성 완료", mockTracks.size());
    }
}