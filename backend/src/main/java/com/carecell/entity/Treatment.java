package com.carecell.entity;

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
 * Tracks an ongoing treatment plan for a Patient user.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "treatments")
public class Treatment {

    @Id
    private String id;

    @Indexed
    private String userId;

    private String treatmentName;
    private String condition;          // What is being treated
    private String doctorName;
    private String hospitalName;

    private LocalDate startDate;
    private LocalDate endDate;

    private String status;             // ONGOING, COMPLETED, PAUSED

    private List<String> medications;
    private List<FollowUp> followUps;
    private String doctorNotes;
    private String progressNotes;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FollowUp {
        private LocalDate scheduledDate;
        private String purpose;
        private boolean completed;
        private String notes;
    }
}
