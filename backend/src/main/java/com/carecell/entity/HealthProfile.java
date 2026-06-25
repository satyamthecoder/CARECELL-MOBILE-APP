package com.carecell.entity;

import com.carecell.enums.BloodGroup;
import com.carecell.enums.Gender;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

/**
 * Detailed health profile for PATIENT users.
 * Separate collection to keep user auth lean.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "health_profiles")
public class HealthProfile {

    @Id
    private String id;

    @Indexed(unique = true)
    private String userId;

    // ── Personal Details ──────────────────────────
    private String fullName;
    private LocalDate dateOfBirth;
    private Gender gender;
    private BloodGroup bloodGroup;
    private String maritalStatus;  // SINGLE, MARRIED, OTHER
    private String occupation;
    private String address;

    // ── Medical History ───────────────────────────
    private List<String> chronicConditions;     // e.g. "Diabetes Type 2"
    private List<String> pastSurgeries;
    private List<String> currentMedications;
    private List<String> allergies;             // Drug / food / environmental

    // ── Gender-specific (female) ──────────────────
    private Boolean isPregnant;
    private Boolean isBreastfeeding;
    private Boolean isOnPeriods;

    // ── Cancer details (if applicable) ───────────
    private Boolean isCancerPatient;
    private String cancerType;
    private String cancerStage;          // Stage I, II, III, IV
    private LocalDate cancerDiagnosisDate;

    // ── Organ transplant need ─────────────────────
    private Boolean needsOrganTransplant;
    private List<String> requiredOrgans;   // "Kidney", "Liver", "Bone Marrow", "Stem Cell"
    private String hlaReportS3Key;         // S3 key for uploaded HLA report

    // ── Donation eligibility score (AI-calculated) ─
    private Double donationEligibilityScore;
    private String eligibilityNotes;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}
