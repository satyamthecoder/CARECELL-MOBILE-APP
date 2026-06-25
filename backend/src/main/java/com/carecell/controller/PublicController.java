package com.carecell.controller;

import com.carecell.dto.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/public")
@RequiredArgsConstructor
@Tag(name = "Public", description = "Hospital finder, scheme finder, AI assistant - no auth required")
public class PublicController {

    @Value("${google.maps.api-key}")
    private String googleMapsApiKey;

    @Value("${ai.service.base-url}")
    private String aiServiceUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    // ── Hospital Finder ───────────────────────────

    @GetMapping("/hospitals")
    @Operation(summary = "Find hospitals near a location")
    public ResponseEntity<ApiResponse<Object>> findHospitals(
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(defaultValue = "5000") int radiusMeters,
            @RequestParam(required = false) String type,     // government, private, specialty
            @RequestParam(required = false) String keyword   // e.g. "cancer", "maternity"
    ) {
        String keyword_param = keyword != null ? "&keyword=" + keyword : "";
        String type_param    = type != null ? "&type=" + type : "&type=hospital";

        String url = String.format(
            "https://maps.googleapis.com/maps/api/place/nearbysearch/json" +
            "?location=%f,%f&radius=%d%s%s&key=%s",
            lat, lng, radiusMeters, type_param, keyword_param, googleMapsApiKey
        );

        try {
            Object response = restTemplate.getForObject(url, Object.class);
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (Exception e) {
            log.error("Hospital finder failed: {}", e.getMessage());
            return ResponseEntity.ok(ApiResponse.ok(Map.of(
                "results", List.of(),
                "error", "Could not fetch hospitals at this time"
            )));
        }
    }

    // ── Government Scheme Finder ──────────────────

    @GetMapping("/schemes")
    @Operation(summary = "Find eligible government healthcare schemes")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> findSchemes(
            @RequestParam(required = false) String state,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Integer minAge,
            @RequestParam(required = false) Integer maxAge,
            @RequestParam(required = false) String bloodGroup) {
        // Static scheme data — in production connect to NHA / MyScheme API
        List<Map<String, Object>> schemes = List.of(
            Map.of("name", "Ayushman Bharat PM-JAY",
                   "description", "Health cover of Rs 5 lakh per family per year for secondary and tertiary hospitalization",
                   "eligibility", "BPL families", "link", "https://pmjay.gov.in"),
            Map.of("name", "Janani Suraksha Yojana",
                   "description", "Safe motherhood intervention — cash assistance to pregnant women",
                   "eligibility", "Pregnant women, especially BPL", "link", "https://nhm.gov.in/JSY"),
            Map.of("name", "Pradhan Mantri Matru Vandana Yojana",
                   "description", "Maternity benefit programme — Rs 5000 in installments",
                   "eligibility", "Pregnant and lactating mothers", "link", "https://pmmvy.wcd.gov.in"),
            Map.of("name", "Rashtriya Arogya Nidhi",
                   "description", "Financial assistance to BPL patients suffering from major life-threatening diseases",
                   "eligibility", "BPL patients with life-threatening disease", "link", "https://mohfw.gov.in"),
            Map.of("name", "CGHS",
                   "description", "Central Government Health Scheme for serving & retired central govt employees",
                   "eligibility", "Central govt employees and pensioners", "link", "https://cghs.gov.in"),
            Map.of("name", "Pradhan Mantri Surakshit Matritva Abhiyan",
                   "description", "Free antenatal care to pregnant women on 9th of every month",
                   "eligibility", "All pregnant women in 2nd/3rd trimester", "link", "https://pmsma.nhp.gov.in")
        );
        return ResponseEntity.ok(ApiResponse.ok(schemes));
    }

    // ── AI Assistant (proxy to Python FastAPI) ────

    @PostMapping("/ai/chat")
    @Operation(summary = "Chat with CareCell AI assistant")
    public ResponseEntity<ApiResponse<Object>> aiChat(@RequestBody Map<String, String> body) {
        try {
            String url = aiServiceUrl + "/chat";
            Object response = restTemplate.postForObject(url, body, Object.class);
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (Exception e) {
            log.error("AI service error: {}", e.getMessage());
            return ResponseEntity.ok(ApiResponse.ok(Map.of(
                "reply", "CareCell AI is temporarily unavailable. Please try again shortly.",
                "type",  "error"
            )));
        }
    }

    // ── Health Info ───────────────────────────────

    @GetMapping("/health-tips")
    @Operation(summary = "Get daily health tips")
    public ResponseEntity<ApiResponse<List<Map<String, String>>>> healthTips() {
        return ResponseEntity.ok(ApiResponse.ok(List.of(
            Map.of("title", "Stay Hydrated", "tip", "Drink at least 8 glasses of water daily"),
            Map.of("title", "Regular Checkups", "tip", "Schedule annual health checkups even when feeling well"),
            Map.of("title", "Donate Blood", "tip", "One blood donation can save up to 3 lives")
        )));
    }
}
