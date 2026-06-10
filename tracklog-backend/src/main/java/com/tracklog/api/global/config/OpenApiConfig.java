package com.tracklog.api.global.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {
    
    @Bean
    public OpenAPI openAPI() {
        // JWT 보안 스키마
        SecurityScheme securityScheme = new SecurityScheme()
                .type(SecurityScheme.Type.HTTP)
                .scheme("bearer")
                .bearerFormat("JWT")
                .in(SecurityScheme.In.HEADER)
                .name("Authorization");
        
        SecurityRequirement securityRequirement = new SecurityRequirement()
                .addList("bearerAuth");
        
        return new OpenAPI()
                .info(apiInfo())
                .servers(List.of(
                        new Server().url("http://localhost:8080").description("개발 서버")
                ))
                .components(new Components().addSecuritySchemes("bearerAuth", securityScheme))
                .addSecurityItem(securityRequirement);
    }
    
    private Info apiInfo() {
        return new Info()
                .title("TrackLog API")
                .description("운동하면서 음악을 듣고 기록하는 앱의 REST API 문서")
                .version("1.0.0")
                .contact(new Contact()
                        .name("TrackLog Team")
                        .email("support@tracklog.com")
                        .url("https://github.com/songjiheon/TrackLog"))
                .license(new License()
                        .name("MIT License")
                        .url("https://opensource.org/licenses/MIT"));
    }
}