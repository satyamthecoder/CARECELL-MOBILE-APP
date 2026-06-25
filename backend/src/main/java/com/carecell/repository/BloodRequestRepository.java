package com.carecell.repository;

import com.carecell.entity.BloodRequest;
import com.carecell.enums.MatchStatus;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BloodRequestRepository extends MongoRepository<BloodRequest, String> {
    List<BloodRequest> findByPatientUserId(String patientUserId);
    List<BloodRequest> findByStatus(MatchStatus status);
    List<BloodRequest> findByPatientUserIdAndStatus(String patientUserId, MatchStatus status);
    List<BloodRequest> findByMatchedDonorIdsContaining(String donorId);
}
