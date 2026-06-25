package com.carecell;

import com.carecell.dto.request.AuthDTOs.RegisterRequest;
import com.carecell.enums.BloodGroup;
import com.carecell.enums.Gender;
import com.carecell.enums.UserRole;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.containers.MongoDBContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Integration test for registration flow.
 *
 * Uses Testcontainers to run a real MongoDB instance (the same mongo:7 image
 * used in docker-compose.yml) in a Docker container for the duration of this
 * test class. REQUIRES Docker to be running on the machine executing `mvn test`.
 *
 * @ServiceConnection (Spring Boot 3.1+) automatically wires the container's
 * connection details into the Spring context — no manual property
 * configuration needed.
 *
 * This replaces a previous Flapdoodle "embedded mongo" approach, which pulled
 * in a fragile, narrowly-versioned third-party artifact and is no longer
 * actively recommended — Testcontainers is the current standard for this.
 */
@Testcontainers
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AuthControllerIntegrationTest {

    @Container
    @ServiceConnection
    static MongoDBContainer mongoDBContainer = new MongoDBContainer("mongo:7");

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void registerPatient_withValidData_returns201() throws Exception {
        RegisterRequest req = new RegisterRequest();
        req.setName("Test Patient");
        req.setMobileNumber("9876543210");
        req.setAge(25);
        req.setGender(Gender.MALE);
        req.setBloodGroup(BloodGroup.O_POSITIVE);
        req.setState("Maharashtra");
        req.setRole(UserRole.PATIENT);
        req.setPassword("SecurePass123");

        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
            .andExpect(status().isCreated());
    }

    @Test
    void registerDonor_underage_returns400() throws Exception {
        RegisterRequest req = new RegisterRequest();
        req.setName("Minor Donor");
        req.setMobileNumber("9876543211");
        req.setAge(16);
        req.setGender(Gender.FEMALE);
        req.setBloodGroup(BloodGroup.A_POSITIVE);
        req.setState("Karnataka");
        req.setRole(UserRole.DONOR);
        req.setPassword("SecurePass123");

        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
            .andExpect(status().isBadRequest());
    }

    @Test
    void registerPatient_minorWithoutGuardianConsent_returns400() throws Exception {
        RegisterRequest req = new RegisterRequest();
        req.setName("Minor Patient");
        req.setMobileNumber("9876543212");
        req.setAge(15);
        req.setGender(Gender.MALE);
        req.setBloodGroup(BloodGroup.B_POSITIVE);
        req.setState("Delhi");
        req.setRole(UserRole.PATIENT);
        req.setPassword("SecurePass123");
        // Guardian consent intentionally omitted

        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
            .andExpect(status().isBadRequest());
    }
}
