package com.carecell.repository;

import com.carecell.entity.DonorProfile;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface DonorProfileRepository extends MongoRepository<DonorProfile, String> {
    Optional<DonorProfile> findByUserId(String userId);
    boolean existsByUserId(String userId);
}
