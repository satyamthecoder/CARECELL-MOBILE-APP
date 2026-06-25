package com.carecell.service;

import com.carecell.entity.BloodRequest;
import com.carecell.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.sns.SnsClient;
import software.amazon.awssdk.services.sns.model.PublishRequest;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final SnsClient snsClient;

    @Async
    public void sendBloodRequestNotification(User donor, BloodRequest request) {
        String msg = String.format(
            "URGENT: Blood needed! %s (%s) required at %s. Open CareCell to respond. -CareCell",
            request.getRequiredBloodGroup().getDisplay(),
            request.getDonationType().name().replace("_", " "),
            request.getHospitalName()
        );
        sendSms(donor.getMobileNumber(), msg);
        // TODO: Add FCM push notification via Firebase Admin SDK using donor.getFcmToken()
        log.info("Notified donor {} for blood request {}", donor.getId(), request.getId());
    }

    @Async
    public void sendSosAlert(User patient, User.EmergencyContact contact) {
        String msg = String.format(
            "EMERGENCY ALERT from CareCell: %s has triggered an SOS. " +
            "They may need immediate help. Contact them or call emergency services. -CareCell",
            patient.getName()
        );
        sendSms(contact.getMobileNumber(), msg);
    }

    private void sendSms(String mobile, String message) {
        try {
            snsClient.publish(PublishRequest.builder()
                .phoneNumber("+91" + mobile)
                .message(message)
                .build());
        } catch (Exception e) {
            log.error("SMS failed to +91{}: {}", mobile, e.getMessage());
        }
    }
}
