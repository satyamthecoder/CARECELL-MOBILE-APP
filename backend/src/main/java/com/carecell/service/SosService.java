package com.carecell.service;

import com.carecell.entity.AuditLog;
import com.carecell.entity.User;
import com.carecell.exception.ResourceNotFoundException;
import com.carecell.repository.AuditLogRepository;
import com.carecell.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class SosService {

    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final AuditLogRepository auditLogRepository;

    public Map<String, Object> triggerSos(String userId, double lat, double lng) {
        User patient = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User", userId));

        // Alert all emergency contacts
        List<User.EmergencyContact> contacts =
            patient.getEmergencyContacts() != null ? patient.getEmergencyContacts() : Collections.emptyList();

        contacts.forEach(contact -> notificationService.sendSosAlert(patient, contact));

        // Audit log
        auditLogRepository.save(AuditLog.builder()
            .userId(userId)
            .action("SOS_TRIGGERED")
            .resourceType("User")
            .resourceId(userId)
            .result("SUCCESS")
            .details(String.format("{\"lat\":%.6f,\"lng\":%.6f,\"contactsAlerted\":%d}", lat, lng, contacts.size()))
            .timestamp(Instant.now())
            .build());

        log.warn("SOS triggered by user {} at lat={} lng={}", userId, lat, lng);

        return Map.of(
            "sosTriggered",     true,
            "contactsAlerted",  contacts.size(),
            "message",          "Emergency contacts have been notified",
            "location",         Map.of("lat", lat, "lng", lng)
        );
    }
}
