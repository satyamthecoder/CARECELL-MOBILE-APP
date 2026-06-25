package com.carecell.service;

import com.carecell.entity.BloodRequest;
import com.carecell.entity.User;
import com.carecell.enums.BloodGroup;
import com.carecell.repository.BloodRequestRepository;
import com.carecell.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class BloodMatchingService {

    private final UserRepository userRepository;
    private final BloodRequestRepository bloodRequestRepository;
    private final NotificationService notificationService;

    private static final double DEFAULT_RADIUS_METERS = 25_000; // 25 km

    @Async
    public void matchAndNotify(BloodRequest request) {
        List<BloodGroup> compatible = BloodGroup.compatibleDonorsFor(request.getRequiredBloodGroup());

        double lat = 0, lng = 0;
        if (request.getHospitalLocation() != null && request.getHospitalLocation().getCoordinates() != null) {
            lng = request.getHospitalLocation().getCoordinates()[0];
            lat = request.getHospitalLocation().getCoordinates()[1];
        }

        List<User> donors = userRepository.findEligibleDonorsNearby(compatible, lng, lat, DEFAULT_RADIUS_METERS);

        if (donors.isEmpty()) {
            // Expand to state-wide search
            donors = userRepository.findByRoleAndBloodGroupIn(
                com.carecell.enums.UserRole.DONOR, compatible);
            log.info("Expanded to state-wide search, found {} donors", donors.size());
        }

        List<String> donorIds = donors.stream().map(User::getId).collect(Collectors.toList());
        request.setMatchedDonorIds(donorIds);
        request.setNotifiedDonorIds(donorIds);
        bloodRequestRepository.save(request);

        // Push FCM + SMS notifications
        donors.forEach(donor -> {
            notificationService.sendBloodRequestNotification(donor, request);
        });

        log.info("Blood request {} matched with {} donors", request.getId(), donors.size());
    }
}
