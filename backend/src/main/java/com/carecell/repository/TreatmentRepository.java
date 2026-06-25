package com.carecell.repository;

import com.carecell.entity.Treatment;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TreatmentRepository extends MongoRepository<Treatment, String> {
    List<Treatment> findByUserId(String userId);
    List<Treatment> findByUserIdAndStatus(String userId, String status);
}
