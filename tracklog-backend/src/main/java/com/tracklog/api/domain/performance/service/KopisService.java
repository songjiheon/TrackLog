package com.tracklog.api.domain.performance.service;

import com.tracklog.api.domain.performance.entity.Performance;
import com.tracklog.api.domain.performance.repository.PerformanceRepository;
import jakarta.annotation.PostConstruct;  // ✅ jakarta 사용
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class KopisService {
    
    @Value("${kopis.api.key}")
    private String apiKey;
    
    @Value("${kopis.api.url:http://www.kopis.or.kr/openApi/restful}")
    private String apiUrl;
    
    private final PerformanceRepository performanceRepository;
    private RestTemplate restTemplate;
    
    /**
     * RestTemplate UTF-8 설정
     */
    @jakarta.annotation.PostConstruct
    public void init() {
        this.restTemplate = new RestTemplate();
        this.restTemplate.getMessageConverters()
                .add(0, new StringHttpMessageConverter(StandardCharsets.UTF_8));
    }
    
    /**
     * KOPIS API에서 공연 목록 가져와서 DB 저장
     */
    @Transactional
    public List<Performance> fetchAndSavePerformances(String startDate, String endDate, int rows) {
        log.info("=== KOPIS 공연 목록 조회 시작 ===");
        log.info("기간: {} ~ {}, 개수: {}", startDate, endDate, rows);
        
        try {
            // KOPIS API 호출
            String url = UriComponentsBuilder
                    .fromHttpUrl(apiUrl + "/pblprfr")
                    .queryParam("service", apiKey)
                    .queryParam("stdate", startDate)  // YYYYMMDD
                    .queryParam("eddate", endDate)
                    .queryParam("cpage", "1")
                    .queryParam("rows", String.valueOf(rows))
                    .queryParam("shcate", "CCCD")  // 콘서트만 (선택사항)
                    .toUriString();
            
            log.debug("API URL: {}", url.replace(apiKey, "****"));
            
            String xmlResponse = restTemplate.getForObject(url, String.class);
            
            // XML 파싱
            List<Performance> performances = parsePerformanceList(xmlResponse);
            
            // DB 저장 (중복 체크)
            List<Performance> savedPerformances = new ArrayList<>();
            for (Performance performance : performances) {
                if (!performanceRepository.existsByKopisId(performance.getKopisId())) {
                    Performance saved = performanceRepository.save(performance);
                    savedPerformances.add(saved);
                    log.debug("✓ 저장: {}", performance.getTitle());
                } else {
                    log.debug("중복: {}", performance.getTitle());
                }
            }
            
            log.info("✓ KOPIS 공연 {}개 조회, {}개 저장 완료", 
                    performances.size(), savedPerformances.size());
            
            return savedPerformances;
            
        } catch (Exception e) {
            log.error("✗ KOPIS API 호출 실패", e);
            throw new RuntimeException("KOPIS 공연 정보 조회 실패: " + e.getMessage(), e);
        }
    }
    
    /**
     * XML 응답 파싱 (UTF-8)
     */
    private List<Performance> parsePerformanceList(String xmlResponse) throws Exception {
        List<Performance> performances = new ArrayList<>();
        
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        
        // UTF-8로 명시적 파싱
        Document document = builder.parse(
            new ByteArrayInputStream(xmlResponse.getBytes(StandardCharsets.UTF_8))
        );
        
        NodeList dbList = document.getElementsByTagName("db");
        
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy.MM.dd");
        
        for (int i = 0; i < dbList.getLength(); i++) {
            Element db = (Element) dbList.item(i);
            
            Performance performance = Performance.builder()
                    .kopisId(getElementText(db, "mt20id"))
                    .title(getElementText(db, "prfnm"))
                    .startDate(parseDate(getElementText(db, "prfpdfrom"), formatter))
                    .endDate(parseDate(getElementText(db, "prfpdto"), formatter))
                    .place(getElementText(db, "fcltynm"))
                    .posterUrl(getElementText(db, "poster"))
                    .genre(getElementText(db, "genrenm"))
                    .state(getElementText(db, "prfstate"))
                    .area(getElementText(db, "area"))
                    .build();
            
            performances.add(performance);
        }
        
        return performances;
    }
    
    /**
     * XML 요소에서 텍스트 추출
     */
    private String getElementText(Element parent, String tagName) {
        NodeList nodeList = parent.getElementsByTagName(tagName);
        if (nodeList.getLength() > 0) {
            String text = nodeList.item(0).getTextContent();
            return text != null && !text.isEmpty() ? text : null;
        }
        return null;
    }
    
    /**
     * 날짜 파싱
     */
    private LocalDate parseDate(String dateStr, DateTimeFormatter formatter) {
        if (dateStr == null || dateStr.isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(dateStr, formatter);
        } catch (Exception e) {
            log.warn("날짜 파싱 실패: {}", dateStr);
            return null;
        }
    }
}