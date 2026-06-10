package com.tracklog.api.domain.music.repository;

import com.tracklog.api.domain.music.entity.Track;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TrackRepository extends JpaRepository<Track, Long> {
    Optional<Track> findBySpotifyId(String spotifyId);
    boolean existsBySpotifyId(String spotifyId);
}