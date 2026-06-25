package com.carecell.controller;

import com.carecell.dto.response.ApiResponse;
import com.carecell.entity.*;
import com.carecell.enums.RecordType;
import com.carecell.service.S3StorageService;
import com.carecell.service.impl.DonorServiceImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/donor")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Donor", description = "Donor dashboard operations")
public class DonorController {

    private final DonorServiceImpl donorService;
    private final S3StorageService s3StorageService;

    @GetMapping("/dashboard")
    @Operation(summary = "Donor dashboard summary")
    public ResponseEntity<ApiResponse<Map<String, Object>>> dashboard(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.ok(donorService.getDashboardSummary(auth.getName())));
    }

    // ── Donor Profile ─────────────────────────────

    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<DonorProfile>> getProfile(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.ok(donorService.getOrCreateDonorProfile(auth.getName())));
    }

    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<DonorProfile>> updateProfile(
            Authentication auth, @RequestBody DonorProfile updates) {
        return ResponseEntity.ok(ApiResponse.ok(
            "Profile updated", donorService.updateDonorProfile(auth.getName(), updates)));
    }

    // ── Donor Card ────────────────────────────────

    @GetMapping("/donor-card")
    @Operation(summary = "Get Digital Donor Card with QR")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getDonorCard(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.ok(donorService.getDonorCard(auth.getName())));
    }

    // ── Match Requests ────────────────────────────

    @GetMapping("/match-requests")
    @Operation(summary = "Get all blood requests matched to this donor")
    public ResponseEntity<ApiResponse<List<BloodRequest>>> getMatchRequests(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.ok(donorService.getMatchRequests(auth.getName())));
    }

    @PostMapping("/match-requests/{id}/respond")
    @Operation(summary = "Accept or decline a blood request")
    public ResponseEntity<ApiResponse<Void>> respondToRequest(
            Authentication auth,
            @PathVariable String id,
            @RequestParam String action) { // ACCEPT or DECLINE
        donorService.respondToRequest(auth.getName(), id, action);
        return ResponseEntity.ok(ApiResponse.message("Response recorded"));
    }

    // ── Donation History ──────────────────────────

    @PostMapping("/donations/record")
    @Operation(summary = "Record a completed donation")
    public ResponseEntity<ApiResponse<DonorProfile>> recordDonation(
            Authentication auth,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate donationDate) {
        return ResponseEntity.ok(ApiResponse.ok(
            "Donation recorded", donorService.recordDonation(auth.getName(), donationDate)));
    }

    // ── Location ──────────────────────────────────

    @PutMapping("/location")
    @Operation(summary = "Update donor location for proximity matching")
    public ResponseEntity<ApiResponse<Void>> updateLocation(
            Authentication auth,
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String state,
            @RequestParam(required = false) String pincode) {
        donorService.updateLocation(auth.getName(), lat, lng, city, state, pincode);
        return ResponseEntity.ok(ApiResponse.message("Location updated"));
    }

    // ── Health Records ────────────────────────────

    @PostMapping(value = "/records", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload donor health record (HLA report, blood test)")
    public ResponseEntity<ApiResponse<HealthRecord>> uploadRecord(
            Authentication auth,
            @RequestParam("file") MultipartFile file,
            @RequestParam RecordType recordType,
            @RequestParam(required = false) String doctorName,
            @RequestParam(required = false) String hospitalName,
            @RequestParam(required = false) String notes,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate recordDate) {
        HealthRecord record = s3StorageService.uploadHealthRecord(
            auth.getName(), file, recordType, doctorName, hospitalName, notes, recordDate);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Record uploaded", record));
    }

    @GetMapping("/records")
    public ResponseEntity<ApiResponse<Page<HealthRecord>>> getRecords(
            Authentication auth,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ApiResponse.ok(donorService.getHealthRecords(auth.getName(), page, size)));
    }

    // ── Eligibility ───────────────────────────────

    @GetMapping("/eligibility")
    @Operation(summary = "Check current donation eligibility status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkEligibility(Authentication auth) {
        DonorProfile profile = donorService.getOrCreateDonorProfile(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(Map.of(
            "isEligible",         Boolean.TRUE.equals(profile.getIsEligible()),
            "reason",             profile.getIneligibilityReason() != null ? profile.getIneligibilityReason() : "Eligible to donate",
            "nextEligibleDate",   profile.getNextEligibleDate() != null ? profile.getNextEligibleDate() : "Now",
            "totalDonations",     profile.getTotalDonations() != null ? profile.getTotalDonations() : 0
        )));
    }
}
