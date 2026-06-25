package com.carecell.entity;

import com.carecell.enums.BloodGroup;
import com.carecell.enums.DonationType;
import com.carecell.enums.MatchStatus;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.List;

/**
 * Blood / donation request created by a Patient.
 * AI matches against eligible Donors by blood group + HLA + location.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "blood_requests")
public class BloodRequest {

    @Id
    private String id;

    @Indexed
    private String patientUserId;

    private BloodGroup requiredBloodGroup;
    private DonationType donationType;          // WHOLE_BLOOD, PLATELETS, PLASMA
    private String hospitalName;
    private String hospitalCity;
    private User.GeoLocation hospitalLocation;

    private String urgencyLevel;               // CRITICAL, HIGH, NORMAL
    private String additionalNotes;

    // ── Match tracking ────────────────────────────
    private List<String> matchedDonorIds;
    private List<String> notifiedDonorIds;

    @Builder.Default
    private MatchStatus status = MatchStatus.PENDING;

    private Instant expiresAt;                 // Auto-expires after 48h

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}
