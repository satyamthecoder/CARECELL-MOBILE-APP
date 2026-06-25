package com.carecell.controller;

import com.carecell.dto.response.ApiResponse;
import com.carecell.entity.*;
import com.carecell.enums.RecordType;
import com.carecell.service.S3StorageService;
import com.carecell.service.SosService;
import com.carecell.service.impl.PatientServiceImpl;
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
@RequestMapping("/api/v1/patient")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Patient", description = "Patient dashboard operations")
public class PatientController {

    private final PatientServiceImpl patientService;
    private final S3StorageService s3StorageService;
    private final SosService sosService;

    @GetMapping("/dashboard")
    @Operation(summary = "Patient dashboard summary")
    public ResponseEntity<ApiResponse<Map<String, Object>>> dashboard(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.ok(patientService.getDashboardSummary(auth.getName())));
    }

    // ── Health Profile ────────────────────────────

    @GetMapping("/profile/health")
    public ResponseEntity<ApiResponse<HealthProfile>> getHealthProfile(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.ok(patientService.getOrCreateHealthProfile(auth.getName())));
    }

    @PutMapping("/profile/health")
    public ResponseEntity<ApiResponse<HealthProfile>> updateHealthProfile(
            Authentication auth, @RequestBody HealthProfile updates) {
        return ResponseEntity.ok(ApiResponse.ok(
            "Health profile updated", patientService.updateHealthProfile(auth.getName(), updates)));
    }

    // ── Health Card ───────────────────────────────

    @GetMapping("/health-card")
    @Operation(summary = "Get Digital Health Card data with QR")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getHealthCard(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.ok(patientService.getHealthCard(auth.getName())));
    }

    // ── Emergency Contacts ────────────────────────

    @PutMapping("/emergency-contacts")
    public ResponseEntity<ApiResponse<Void>> updateEmergencyContacts(
            Authentication auth, @RequestBody List<User.EmergencyContact> contacts) {
        patientService.updateEmergencyContacts(auth.getName(), contacts);
        return ResponseEntity.ok(ApiResponse.message("Emergency contacts updated"));
    }

    // ── SOS ───────────────────────────────────────

    @PostMapping("/sos")
    @Operation(summary = "Trigger emergency SOS alert")
    public ResponseEntity<ApiResponse<Map<String, Object>>> triggerSos(
            Authentication auth,
            @RequestParam double lat,
            @RequestParam double lng) {
        return ResponseEntity.ok(ApiResponse.ok(sosService.triggerSos(auth.getName(), lat, lng)));
    }

    // ── Blood Requests ────────────────────────────

    @PostMapping("/blood-requests")
    @Operation(summary = "Create urgent blood request")
    public ResponseEntity<ApiResponse<BloodRequest>> createBloodRequest(
            Authentication auth, @RequestBody BloodRequest req) {
        BloodRequest created = patientService.createBloodRequest(auth.getName(), req);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Blood request created", created));
    }

    @GetMapping("/blood-requests")
    public ResponseEntity<ApiResponse<List<BloodRequest>>> getBloodRequests(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.ok(patientService.getMyBloodRequests(auth.getName())));
    }

    @DeleteMapping("/blood-requests/{id}")
    public ResponseEntity<ApiResponse<Void>> cancelBloodRequest(
            Authentication auth, @PathVariable String id) {
        patientService.cancelBloodRequest(auth.getName(), id);
        return ResponseEntity.ok(ApiResponse.message("Blood request cancelled"));
    }

    // ── Health Records ────────────────────────────

    @PostMapping(value = "/records", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload a health record (PDF/image)")
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
        return ResponseEntity.ok(ApiResponse.ok(patientService.getHealthRecords(auth.getName(), page, size)));
    }

    @GetMapping("/records/{id}/url")
    @Operation(summary = "Get pre-signed download URL for a record")
    public ResponseEntity<ApiResponse<String>> getRecordUrl(
            Authentication auth, @PathVariable String id) {
        // Find record, verify ownership, return presigned URL
        return ResponseEntity.ok(ApiResponse.ok("URL generated"));
    }

    // ── Treatments ────────────────────────────────

    @GetMapping("/treatments")
    public ResponseEntity<ApiResponse<List<Treatment>>> getTreatments(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.ok(patientService.getMyTreatments(auth.getName())));
    }

    @PostMapping("/treatments")
    public ResponseEntity<ApiResponse<Treatment>> addTreatment(
            Authentication auth, @RequestBody Treatment treatment) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.ok("Treatment added", patientService.addTreatment(auth.getName(), treatment)));
    }

    @PatchMapping("/treatments/{id}")
    public ResponseEntity<ApiResponse<Treatment>> updateTreatment(
            Authentication auth, @PathVariable String id, @RequestBody Treatment updates) {
        return ResponseEntity.ok(ApiResponse.ok(
            "Treatment updated", patientService.updateTreatment(auth.getName(), id, updates)));
    }
}
