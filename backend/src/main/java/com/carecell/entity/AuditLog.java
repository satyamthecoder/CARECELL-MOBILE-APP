package com.carecell.entity;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

/**
 * Immutable audit trail for all sensitive actions.
 * Required for HIPAA-style compliance.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "audit_logs")
public class AuditLog {

    @Id
    private String id;

    @Indexed
    private String userId;

    private String action;          // e.g. "HEALTH_RECORD_UPLOAD", "SOS_TRIGGERED"
    private String resourceType;    // e.g. "HealthRecord", "BloodRequest"
    private String resourceId;

    private String ipAddress;
    private String userAgent;
    private String result;          // SUCCESS, FAILURE

    private String details;         // JSON string of relevant context

    @Indexed
    private Instant timestamp;
}
