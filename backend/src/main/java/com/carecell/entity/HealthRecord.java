package com.carecell.entity;

import com.carecell.enums.RecordType;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.time.LocalDate;

/**
 * A single uploaded health document (lab report, prescription, scan, etc.)
 * File stored in AWS S3; metadata stored here.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "health_records")
public class HealthRecord {

    @Id
    private String id;

    @Indexed
    private String userId;

    private String fileName;
    private String originalFileName;
    private RecordType recordType;
    private String s3Key;               // e.g. records/userId/uuid-filename.pdf
    private String contentType;         // application/pdf, image/jpeg, etc.
    private Long fileSizeBytes;

    private String uploadSource;        // MANUAL, GMAIL_SYNC, WHATSAPP
    private LocalDate recordDate;       // Date of the actual test/prescription
    private String doctorName;
    private String hospitalName;
    private String notes;

    // ── AI Analysis result ────────────────────────
    private String aiSummary;           // AI-extracted summary (optional, async)
    private boolean aiProcessed;

    @CreatedDate
    private Instant uploadedAt;
}
