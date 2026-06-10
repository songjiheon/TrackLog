package com.tracklog.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class TracklogApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(TracklogApiApplication.class, args);
	}

}
