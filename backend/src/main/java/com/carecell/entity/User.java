package com.carecell.entity;

import com.carecell.enums.BloodGroup;
import com.carecell.enums.Gender;
import com.carecell.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.GeoSpatialIndexType;
import org.springframework.data.mongodb.core.index.GeoSpatialIndexed;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.List;

/**
 * Core user entity — single collection, role differentiates Patient vs Donor.
 * Health ID is system-generated (CC-YYYY-XXXXXX).
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "users")
public class User {

    @Id
    private String id;

    // ── Identity ──────────────────────────────────
    @Indexed(unique = true)
    private String mobileNumber;        // Primary identifier, OTP-verified

    private String name;
    private Integer age;
    private Gender gender;
    private BloodGroup bloodGroup;
    private String state;               // For scheme matching

    private UserRole role;              // PATIENT or DONOR

    // ── Auth ──────────────────────────────────────
    private String passwordHash;        // BCrypt

    @Builder.Default
    private boolean mobileVerified = false;

    @Builder.Default
    private boolean active = true;

    // ── Health ID (patients only) ─────────────────
    @Indexed(unique = true, sparse = true)
    private String healthId;            // e.g. CC-2024-000123

    // ── Guardian (patients under 18) ──────────────
    private GuardianInfo guardian;

    // ── Donor-specific ────────────────────────────
    private Boolean donorEligible;
    private String donorCardId;

    // ── Emergency contacts ────────────────────────
    private List<EmergencyContact> emergencyContacts;

    // ── Location (for donor matching) ─────────────
    @GeoSpatialIndexed(type = GeoSpatialIndexType.GEO_2DSPHERE)
    private GeoLocation location;

    // ── Profile completeness ──────────────────────
    @Builder.Default
    private boolean profileComplete = false;

    // ── Push notification token (Flutter FCM) ─────
    private String fcmToken;

    // ── Audit ─────────────────────────────────────
    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;

    // ── Embedded documents ────────────────────────

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GuardianInfo {
        private String name;
        private String mobileNumber;
        private String relationship;    // e.g. "Father", "Mother", "Guardian"
        private boolean consentGiven;
        private String consentSignature; // base64 or S3 key
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EmergencyContact {
        private String name;
        private String mobileNumber;
        private String relationship;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GeoLocation {
        private String type;            // "Point"
        private double[] coordinates;  // [longitude, latitude]
        private String city;
        private String state;
        private String pincode;
    }
}
