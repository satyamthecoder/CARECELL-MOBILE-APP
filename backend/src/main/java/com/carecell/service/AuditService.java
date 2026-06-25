package com.carecell.service;

import com.carecell.entity.AuditLog;
import com.carecell.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
@RequiredArgsConstructor
public class AuditService {

    private final AuditLogRepository auditLogRepository;

    @Async
    public void log(String userId, String action, String resourceType, String resourceId,
                    String result, String ipAddress, String details) {
        auditLogRepository.save(AuditLog.builder()
            .userId(userId)
            .action(action)
            .resourceType(resourceType)
            .resourceId(resourceId)
            .result(result)
            .ipAddress(ipAddress)
            .details(details)
            .timestamp(Instant.now())
            .build());
    }
}
