package com.carecell.service.impl;

import com.carecell.entity.*;
import com.carecell.enums.MatchStatus;
import com.carecell.exception.BadRequestException;
import com.carecell.exception.ResourceNotFoundException;
import com.carecell.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class PatientServiceImpl {

    private final UserRepository userRepository;
    private final HealthProfileRepository healthProfileRepository;
    private final BloodRequestRepository bloodRequestRepository;
    private final HealthRecordRepository healthRecordRepository;
    private final TreatmentRepository treatmentRepository;

    // ── Dashboard Summary ─────────────────────────

    public Map<String, Object> getDashboardSummary(String userId) {
        User user = getUser(userId);
        long recordCount    = healthRecordRepository.countByUserId(userId);
        long activeRequests = bloodRequestRepository
            .findByPatientUserIdAndStatus(userId, MatchStatus.PENDING).size();
        List<Treatment> ongoing = treatmentRepository.findByUserIdAndStatus(userId, "ONGOING");

        return Map.of(
            "user",          buildUserSummary(user),
            "recordCount",   recordCount,
            "activeBloodRequests", activeRequests,
            "ongoingTreatments",   ongoing.size()
        );
    }

    // ── Health Profile ────────────────────────────

    public HealthProfile getOrCreateHealthProfile(String userId) {
        return healthProfileRepository.findByUserId(userId).orElseGet(() -> {
            User user = getUser(userId);
            HealthProfile profile = HealthProfile.builder()
                .userId(userId)
                .fullName(user.getName())
                .gender(user.getGender())
                .bloodGroup(user.getBloodGroup())
                .build();
            return healthProfileRepository.save(profile);
        });
    }

    @Transactional
    public HealthProfile updateHealthProfile(String userId, HealthProfile updates) {
        HealthProfile profile = getOrCreateHealthProfile(userId);
        // Patch non-null fields
        if (updates.getFullName()           != null) profile.setFullName(updates.getFullName());
        if (updates.getDateOfBirth()        != null) profile.setDateOfBirth(updates.getDateOfBirth());
        if (updates.getMaritalStatus()      != null) profile.setMaritalStatus(updates.getMaritalStatus());
        if (updates.getOccupation()         != null) profile.setOccupation(updates.getOccupation());
        if (updates.getAddress()            != null) profile.setAddress(updates.getAddress());
        if (updates.getChronicConditions()  != null) profile.setChronicConditions(updates.getChronicConditions());
        if (updates.getPastSurgeries()      != null) profile.setPastSurgeries(updates.getPastSurgeries());
        if (updates.getCurrentMedications() != null) profile.setCurrentMedications(updates.getCurrentMedications());
        if (updates.getAllergies()           != null) profile.setAllergies(updates.getAllergies());
        if (updates.getIsPregnant()         != null) profile.setIsPregnant(updates.getIsPregnant());
        if (updates.getIsCancerPatient()    != null) profile.setIsCancerPatient(updates.getIsCancerPatient());
        if (updates.getCancerType()         != null) profile.setCancerType(updates.getCancerType());
        if (updates.getCancerStage()        != null) profile.setCancerStage(updates.getCancerStage());
        if (updates.getNeedsOrganTransplant() != null) profile.setNeedsOrganTransplant(updates.getNeedsOrganTransplant());
        if (updates.getRequiredOrgans()     != null) profile.setRequiredOrgans(updates.getRequiredOrgans());

        HealthProfile saved = healthProfileRepository.save(profile);
        markProfileComplete(userId);
        return saved;
    }

    // ── Digital Health Card ───────────────────────

    public Map<String, Object> getHealthCard(String userId) {
        User user = getUser(userId);
        return Map.of(
            "healthId",        user.getHealthId(),
            "name",            user.getName(),
            "age",             user.getAge(),
            "gender",          user.getGender(),
            "bloodGroup",      user.getBloodGroup().getDisplay(),
            "state",           user.getState(),
            "emergencyContacts", user.getEmergencyContacts() != null ? user.getEmergencyContacts() : List.of(),
            "qrData",          buildQrData(user)
        );
    }

    // ── Blood Requests ────────────────────────────

    public BloodRequest createBloodRequest(String userId, BloodRequest req) {
        req.setPatientUserId(userId);
        req.setStatus(MatchStatus.PENDING);
        req.setExpiresAt(Instant.now().plusSeconds(48 * 3600));
        return bloodRequestRepository.save(req);
    }

    public List<BloodRequest> getMyBloodRequests(String userId) {
        return bloodRequestRepository.findByPatientUserId(userId);
    }

    @Transactional
    public void cancelBloodRequest(String userId, String requestId) {
        BloodRequest req = bloodRequestRepository.findById(requestId)
            .orElseThrow(() -> new ResourceNotFoundException("Blood request", requestId));
        if (!req.getPatientUserId().equals(userId)) {
            throw new BadRequestException("Not authorized to cancel this request");
        }
        req.setStatus(MatchStatus.CANCELLED);
        bloodRequestRepository.save(req);
    }

    // ── Health Records ────────────────────────────

    public Page<HealthRecord> getHealthRecords(String userId, int page, int size) {
        return healthRecordRepository.findByUserId(userId, PageRequest.of(page, size, Sort.by("uploadedAt").descending()));
    }

    // ── Treatments ────────────────────────────────

    public List<Treatment> getMyTreatments(String userId) {
        return treatmentRepository.findByUserId(userId);
    }

    public Treatment addTreatment(String userId, Treatment treatment) {
        treatment.setUserId(userId);
        return treatmentRepository.save(treatment);
    }

    @Transactional
    public Treatment updateTreatment(String userId, String treatmentId, Treatment updates) {
        Treatment existing = treatmentRepository.findById(treatmentId)
            .orElseThrow(() -> new ResourceNotFoundException("Treatment", treatmentId));
        if (!existing.getUserId().equals(userId)) throw new BadRequestException("Not authorized");

        if (updates.getStatus()        != null) existing.setStatus(updates.getStatus());
        if (updates.getProgressNotes() != null) existing.setProgressNotes(updates.getProgressNotes());
        if (updates.getDoctorNotes()   != null) existing.setDoctorNotes(updates.getDoctorNotes());
        if (updates.getFollowUps()     != null) existing.setFollowUps(updates.getFollowUps());
        if (updates.getMedications()   != null) existing.setMedications(updates.getMedications());
        return treatmentRepository.save(existing);
    }

    // ── Emergency Contacts ────────────────────────

    @Transactional
    public User updateEmergencyContacts(String userId, List<User.EmergencyContact> contacts) {
        User user = getUser(userId);
        if (contacts.size() > 3) throw new BadRequestException("Maximum 3 emergency contacts allowed");
        user.setEmergencyContacts(contacts);
        return userRepository.save(user);
    }

    // ── Helpers ───────────────────────────────────

    private User getUser(String userId) {
        return userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User", userId));
    }

    private void markProfileComplete(String userId) {
        userRepository.findById(userId).ifPresent(u -> {
            u.setProfileComplete(true);
            userRepository.save(u);
        });
    }

    private Map<String, String> buildUserSummary(User user) {
        return Map.of(
            "id",          user.getId(),
            "name",        user.getName(),
            "healthId",    user.getHealthId() != null ? user.getHealthId() : "",
            "bloodGroup",  user.getBloodGroup().getDisplay()
        );
    }

    private String buildQrData(User user) {
        return String.format("CARECELL|%s|%s|%s|%s",
            user.getHealthId(), user.getName(),
            user.getBloodGroup().getDisplay(), user.getMobileNumber());
    }
}
