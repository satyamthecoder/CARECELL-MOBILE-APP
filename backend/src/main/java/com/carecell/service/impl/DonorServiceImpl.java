package com.carecell.service.impl;

import com.carecell.entity.*;
import com.carecell.enums.BloodGroup;
import com.carecell.enums.MatchStatus;
import com.carecell.exception.BadRequestException;
import com.carecell.exception.ResourceNotFoundException;
import com.carecell.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class DonorServiceImpl {

    private final UserRepository userRepository;
    private final DonorProfileRepository donorProfileRepository;
    private final BloodRequestRepository bloodRequestRepository;
    private final HealthRecordRepository healthRecordRepository;

    // ── Dashboard ─────────────────────────────────

    public Map<String, Object> getDashboardSummary(String userId) {
        User user = getUser(userId);
        DonorProfile profile = donorProfileRepository.findByUserId(userId).orElse(null);
        List<BloodRequest> matched = bloodRequestRepository.findByMatchedDonorIdsContaining(userId);
        long pending = matched.stream().filter(r -> r.getStatus() == MatchStatus.PENDING).count();

        return Map.of(
            "user",            buildUserSummary(user),
            "isEligible",      profile != null && Boolean.TRUE.equals(profile.getIsEligible()),
            "totalDonations",  profile != null && profile.getTotalDonations() != null ? profile.getTotalDonations() : 0,
            "pendingRequests", pending,
            "nextEligibleDate", profile != null && profile.getNextEligibleDate() != null
                ? profile.getNextEligibleDate().toString() : "Eligible Now"
        );
    }

    // ── Donor Profile ─────────────────────────────

    public DonorProfile getOrCreateDonorProfile(String userId) {
        return donorProfileRepository.findByUserId(userId).orElseGet(() -> {
            User user = getUser(userId);
            DonorProfile profile = DonorProfile.builder()
                .userId(userId)
                .fullName(user.getName())
                .gender(user.getGender())
                .bloodGroup(user.getBloodGroup())
                .totalDonations(0)
                .build();
            return donorProfileRepository.save(profile);
        });
    }

    @Transactional
    public DonorProfile updateDonorProfile(String userId, DonorProfile updates) {
        DonorProfile profile = getOrCreateDonorProfile(userId);

        if (updates.getFullName()            != null) profile.setFullName(updates.getFullName());
        if (updates.getDateOfBirth()         != null) profile.setDateOfBirth(updates.getDateOfBirth());
        if (updates.getOccupation()          != null) profile.setOccupation(updates.getOccupation());
        if (updates.getAddress()             != null) profile.setAddress(updates.getAddress());
        if (updates.getDonationTypes()       != null) profile.setDonationTypes(updates.getDonationTypes());
        if (updates.getAvailableOrgans()     != null) profile.setAvailableOrgans(updates.getAvailableOrgans());
        if (updates.getChronicConditions()   != null) profile.setChronicConditions(updates.getChronicConditions());
        if (updates.getCurrentMedications()  != null) profile.setCurrentMedications(updates.getCurrentMedications());
        if (updates.getHlaMarkers()          != null) profile.setHlaMarkers(updates.getHlaMarkers());
       // if (updates.getDonationConsentGiven())        profile.setDonationConsentGiven(true);
        if (updates.isDonationConsentGiven())
    profile.setDonationConsentGiven(true);
        // Auto-calculate eligibility
        profile.setIsEligible(calculateEligibility(profile));
        if (!profile.getIsEligible()) {
            profile.setIneligibilityReason(getIneligibilityReason(profile));
        }

        DonorProfile saved = donorProfileRepository.save(profile);
        markUserEligible(userId, profile.getIsEligible());
        return saved;
    }

    // ── Donor Card ────────────────────────────────

    public Map<String, Object> getDonorCard(String userId) {
        User user = getUser(userId);
        DonorProfile profile = donorProfileRepository.findByUserId(userId).orElse(null);
        return Map.of(
            "donorId",      user.getId(),
            "name",         user.getName(),
            "bloodGroup",   user.getBloodGroup().getDisplay(),
            "donationTypes", profile != null && profile.getDonationTypes() != null
                ? profile.getDonationTypes() : List.of(),
            "totalDonations", profile != null && profile.getTotalDonations() != null
                ? profile.getTotalDonations() : 0,
            "isEligible",   profile != null && Boolean.TRUE.equals(profile.getIsEligible()),
            "qrData",       "CARECELL-DONOR|" + user.getId() + "|" + user.getBloodGroup().getDisplay()
        );
    }

    // ── Match Requests ────────────────────────────

    public List<BloodRequest> getMatchRequests(String userId) {
        return bloodRequestRepository.findByMatchedDonorIdsContaining(userId);
    }

    @Transactional
    public void respondToRequest(String userId, String requestId, String action) {
        BloodRequest req = bloodRequestRepository.findById(requestId)
            .orElseThrow(() -> new ResourceNotFoundException("Blood request", requestId));

        if (!req.getMatchedDonorIds().contains(userId)) {
            throw new BadRequestException("You are not matched to this request");
        }

        if ("ACCEPT".equalsIgnoreCase(action)) {
            req.setStatus(MatchStatus.ACCEPTED);
        } else if ("DECLINE".equalsIgnoreCase(action)) {
            req.getMatchedDonorIds().remove(userId);
        } else {
            throw new BadRequestException("Action must be ACCEPT or DECLINE");
        }
        bloodRequestRepository.save(req);
    }

    // ── Donation History ──────────────────────────

    @Transactional
    public DonorProfile recordDonation(String userId, LocalDate donationDate) {
        DonorProfile profile = getOrCreateDonorProfile(userId);
        profile.setLastDonationDate(donationDate);
        profile.setTotalDonations((profile.getTotalDonations() == null ? 0 : profile.getTotalDonations()) + 1);
        // Cooldown: 90 days for whole blood
        profile.setNextEligibleDate(donationDate.plusDays(90));
        profile.setIsEligible(false);
        profile.setIneligibilityReason("Cooldown period: 90 days after donation");
        return donorProfileRepository.save(profile);
    }

    // ── Health Records (Donor) ────────────────────

    public Page<HealthRecord> getHealthRecords(String userId, int page, int size) {
        return healthRecordRepository.findByUserId(userId,
            PageRequest.of(page, size, Sort.by("uploadedAt").descending()));
    }

    // ── Location Update ───────────────────────────

    @Transactional
    public void updateLocation(String userId, double lat, double lng, String city, String state, String pincode) {
        User user = getUser(userId);
        user.setLocation(User.GeoLocation.builder()
            .type("Point")
            .coordinates(new double[]{lng, lat})
            .city(city).state(state).pincode(pincode)
            .build());
        userRepository.save(user);
    }

    // ── Helpers ───────────────────────────────────

    private User getUser(String userId) {
        return userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User", userId));
    }

    private boolean calculateEligibility(DonorProfile profile) {
        if (!profile.isDonationConsentGiven()) return false;
        if (Boolean.TRUE.equals(profile.getIsPregnant()))      return false;
        if (Boolean.TRUE.equals(profile.getIsBreastfeeding())) return false;
        if (profile.getNextEligibleDate() != null
                && profile.getNextEligibleDate().isAfter(LocalDate.now())) return false;
        return true;
    }

    private String getIneligibilityReason(DonorProfile profile) {
        if (!profile.isDonationConsentGiven())             return "Consent not given";
        if (Boolean.TRUE.equals(profile.getIsPregnant()))  return "Pregnant donors cannot donate";
        if (Boolean.TRUE.equals(profile.getIsBreastfeeding())) return "Breastfeeding donors cannot donate";
        if (profile.getNextEligibleDate() != null
                && profile.getNextEligibleDate().isAfter(LocalDate.now()))
            return "Cooldown period until " + profile.getNextEligibleDate();
        return null;
    }

    private void markUserEligible(String userId, boolean eligible) {
        userRepository.findById(userId).ifPresent(u -> {
            u.setDonorEligible(eligible);
            u.setProfileComplete(true);
            userRepository.save(u);
        });
    }

    private Map<String, Object> buildUserSummary(User user) {
        return Map.of("id", user.getId(), "name", user.getName(),
            "bloodGroup", user.getBloodGroup().getDisplay());
    }
}
