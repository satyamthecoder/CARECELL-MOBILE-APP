package com.carecell.repository;

import com.carecell.entity.User;
import com.carecell.enums.BloodGroup;
import com.carecell.enums.UserRole;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends MongoRepository<User, String> {

    Optional<User> findByMobileNumber(String mobileNumber);

    Optional<User> findByHealthId(String healthId);

    boolean existsByMobileNumber(String mobileNumber);

    // Find eligible donors by blood group within a geographic radius
    @Query("{ 'role': 'DONOR', 'donorEligible': true, 'bloodGroup': { $in: ?0 }, 'active': true, " +
           "'location': { $near: { $geometry: { type: 'Point', coordinates: [?1, ?2] }, $maxDistance: ?3 } } }")
    List<User> findEligibleDonorsNearby(List<BloodGroup> compatibleGroups,
                                        double longitude, double latitude, double radiusMeters);

    List<User> findByRoleAndBloodGroupIn(UserRole role, List<BloodGroup> bloodGroups);
}
