package com.carecell.service;

import com.carecell.entity.HealthRecord;
import com.carecell.enums.RecordType;
import com.carecell.exception.BadRequestException;
import com.carecell.repository.HealthRecordRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class S3StorageService {

    private final S3Client s3Client;
    private final S3Presigner s3Presigner;
    private final HealthRecordRepository healthRecordRepository;

    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    @Value("${aws.s3.url-expiry-minutes:60}")
    private int urlExpiryMinutes;

    private static final List<String> ALLOWED_TYPES = List.of(
        "application/pdf", "image/jpeg", "image/png", "image/jpg"
    );
    private static final long MAX_SIZE = 20 * 1024 * 1024; // 20 MB

    public HealthRecord uploadHealthRecord(String userId, MultipartFile file,
                                           RecordType recordType, String doctorName,
                                           String hospitalName, String notes,
                                           LocalDate recordDate) {
        validateFile(file);

        String ext    = getExtension(file.getOriginalFilename());
        String s3Key  = String.format("records/%s/%s.%s", userId, UUID.randomUUID(), ext);

        try {
            s3Client.putObject(
                PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(s3Key)
                    .contentType(file.getContentType())
                    .serverSideEncryption(ServerSideEncryption.AES256)
                    .build(),
                RequestBody.fromBytes(file.getBytes())
            );
        } catch (IOException e) {
            throw new RuntimeException("Failed to upload file: " + e.getMessage());
        }

        HealthRecord record = HealthRecord.builder()
            .userId(userId)
            .fileName(s3Key)
            .originalFileName(file.getOriginalFilename())
            .recordType(recordType)
            .s3Key(s3Key)
            .contentType(file.getContentType())
            .fileSizeBytes(file.getSize())
            .uploadSource("MANUAL")
            .recordDate(recordDate)
            .doctorName(doctorName)
            .hospitalName(hospitalName)
            .notes(notes)
            .aiProcessed(false)
            .build();

        return healthRecordRepository.save(record);
    }

    public String generatePresignedUrl(String s3Key) {
        GetObjectPresignRequest presignRequest = GetObjectPresignRequest.builder()
            .signatureDuration(Duration.ofMinutes(urlExpiryMinutes))
            .getObjectRequest(r -> r.bucket(bucketName).key(s3Key))
            .build();
        return s3Presigner.presignGetObject(presignRequest).url().toString();
    }

    public void deleteRecord(String s3Key) {
        s3Client.deleteObject(DeleteObjectRequest.builder()
            .bucket(bucketName).key(s3Key).build());
    }

    private void validateFile(MultipartFile file) {
        if (file.isEmpty()) throw new BadRequestException("File is empty");
        if (file.getSize() > MAX_SIZE) throw new BadRequestException("File exceeds 20MB limit");
        if (!ALLOWED_TYPES.contains(file.getContentType()))
            throw new BadRequestException("Only PDF, JPG, PNG files are allowed");
    }

    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) return "bin";
        return filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();
    }
}
