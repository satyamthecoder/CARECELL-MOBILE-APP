package com.carecell.repository;

import com.carecell.entity.HealthRecord;
import com.carecell.enums.RecordType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface HealthRecordRepository extends MongoRepository<HealthRecord, String> {
    Page<HealthRecord> findByUserId(String userId, Pageable pageable);
    List<HealthRecord> findByUserIdAndRecordType(String userId, RecordType type);
    long countByUserId(String userId);
}
