package com.carecell.entity;

import com.carecell.enums.BloodGroup;
import com.carecell.enums.DonationType;
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
 * Detailed profile for DONOR users.
 * Eligibility calculated server-side after profile submission.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "donor_profiles")
public class DonorProfile {

    @Id
    private String id;

    @Indexed(unique = true)
    private String userId;

    // ── Personal Details ──────────────────────────
    private String fullName;
    private LocalDate dateOfBirth;
    private Gender gender;
    private BloodGroup bloodGroup;
    private String occupation;
    private String address;

    // ── Medical History ───────────────────────────
    private List<String> chronicConditions;
    private List<String> currentMedications;
    private List<String> allergies;

    // ── HLA Markers (for stem cell / bone marrow) ─
    private List<String> hlaMarkers;
    private String hlaReportS3Key;

    // ── Donation specifics ────────────────────────
    private List<DonationType> donationTypes;    // What they can donate
    private List<String> availableOrgans;        // e.g. "Kidney" (living donor)
    private LocalDate lastDonationDate;
    private Integer totalDonations;

    // ── Consent ───────────────────────────────────
    private boolean donationConsentGiven;
    private Instant consentTimestamp;

    // ── Gender-specific ───────────────────────────
    private Boolean isPregnant;
    private Boolean isBreastfeeding;
    private Boolean isOnPeriods;

    // ── Eligibility ───────────────────────────────
    private Boolean isEligible;
    private String ineligibilityReason;          // shown when temporarily not eligible
    private LocalDate eligibleFromDate;          // cooldown end date

    // ── Donation cooldown ─────────────────────────
    private LocalDate nextEligibleDate;          // 90 days after whole blood, etc.

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}
