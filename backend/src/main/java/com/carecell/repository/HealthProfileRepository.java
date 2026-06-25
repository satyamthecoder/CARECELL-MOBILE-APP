package com.carecell.repository;

import com.carecell.entity.HealthProfile;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface HealthProfileRepository extends MongoRepository<HealthProfile, String> {
    Optional<HealthProfile> findByUserId(String userId);
    boolean existsByUserId(String userId);
}
