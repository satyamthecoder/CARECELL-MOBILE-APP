/*package com.carecell.service.impl;

import com.carecell.dto.request.AuthDTOs.*;
import com.carecell.dto.response.AuthResponse;
import com.carecell.entity.User;
import com.carecell.enums.UserRole;
import com.carecell.exception.BadRequestException;
import com.carecell.exception.ConflictException;
import com.carecell.exception.ResourceNotFoundException;
import com.carecell.repository.UserRepository;
import com.carecell.security.JwtTokenProvider;
import com.carecell.service.OtpService;
import com.carecell.util.HealthIdGenerator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final OtpService otpService;
    private final HealthIdGenerator healthIdGenerator;

    @Transactional
    public String register(RegisterRequest req) {
        if (userRepository.existsByMobileNumber(req.getMobileNumber())) {
            throw new ConflictException("Mobile number already registered");
        }

        // Donor must be 18+
        if (req.getRole() == UserRole.DONOR && req.getAge() < 18) {
            throw new BadRequestException("Donors must be 18 years or older");
        }

        // Minor patient needs guardian info
        if (req.getRole() == UserRole.PATIENT && req.getAge() < 18) {
            validateGuardianInfo(req);
        }

        User.UserBuilder builder = User.builder()
            .name(req.getName())
            .mobileNumber(req.getMobileNumber())
            .age(req.getAge())
            .gender(req.getGender())
            .bloodGroup(req.getBloodGroup())
            .state(req.getState())
            .role(req.getRole())
            .passwordHash(passwordEncoder.encode(req.getPassword()));

        // Assign Health ID for patients
        if (req.getRole() == UserRole.PATIENT) {
            builder.healthId(healthIdGenerator.generate());
        }

        // Attach guardian for minors
        if (req.getRole() == UserRole.PATIENT && req.getAge() < 18) {
            builder.guardian(User.GuardianInfo.builder()
                .name(req.getGuardianName())
                .mobileNumber(req.getGuardianMobile())
                .relationship(req.getGuardianRelationship())
                .consentGiven(Boolean.TRUE.equals(req.getGuardianConsent()))
                .build());
        }

        userRepository.save(builder.build());

        // Send OTP for verification
        otpService.sendOtp(req.getMobileNumber());
        return "Registration successful. OTP sent to +91" + req.getMobileNumber();
    }

    @Transactional
    public void verifyMobile(VerifyOtpRequest req) {
        otpService.verifyOtp(req.getMobileNumber(), req.getOtp());
        User user = findByMobile(req.getMobileNumber());
        user.setMobileVerified(true);
        userRepository.save(user);
    }

    public AuthResponse login(LoginRequest req) {
        User user = findByMobile(req.getMobileNumber());

        if (!user.isActive()) {
            throw new BadRequestException("Account is deactivated. Please contact support.");
        }
        if (!passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new BadRequestException("Invalid mobile number or password");
        }
        if (!user.isMobileVerified()) {
            // Resend OTP and ask them to verify
            otpService.sendOtp(req.getMobileNumber());
            throw new BadRequestException("Mobile not verified. A new OTP has been sent.");
        }

        return buildAuthResponse(user);
    }

    public AuthResponse refreshToken(RefreshTokenRequest req) {
        if (!jwtTokenProvider.validateToken(req.getRefreshToken())) {
            throw new BadRequestException("Invalid or expired refresh token");
        }
        String userId = jwtTokenProvider.getUserIdFromToken(req.getRefreshToken());
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("User", userId));
        return buildAuthResponse(user);
    }

    @Transactional
    public void forgotPassword(ForgotPasswordRequest req) {
        findByMobile(req.getMobileNumber()); // Validates user exists
        otpService.sendOtp(req.getMobileNumber());
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest req) {
        otpService.verifyOtp(req.getMobileNumber(), req.getOtp());
        User user = findByMobile(req.getMobileNumber());
        user.setPasswordHash(passwordEncoder.encode(req.getNewPassword()));
        userRepository.save(user);
    }

    // ── Helpers ───────────────────────────────────

    private User findByMobile(String mobile) {
        return userRepository.findByMobileNumber(mobile)
            .orElseThrow(() -> new ResourceNotFoundException("No account found with this mobile number"));
    }

    private AuthResponse buildAuthResponse(User user) {
        String access  = jwtTokenProvider.generateAccessToken(user.getId(), user.getRole().name());
        String refresh = jwtTokenProvider.generateRefreshToken(user.getId());

        return AuthResponse.builder()
            .accessToken(access)
            .refreshToken(refresh)
            .tokenType("Bearer")
            .expiresIn(86400)
            .user(AuthResponse.UserInfo.builder()
                .id(user.getId())
                .name(user.getName())
                .mobileNumber(user.getMobileNumber())
                .age(user.getAge())
                .gender(user.getGender())
                .bloodGroup(user.getBloodGroup())
                .state(user.getState())
                .role(user.getRole())
                .healthId(user.getHealthId())
                .mobileVerified(user.isMobileVerified())
                .profileComplete(user.isProfileComplete())
                .build())
            .build();
    }

    private void validateGuardianInfo(RegisterRequest req) {
        if (req.getGuardianName() == null || req.getGuardianName().isBlank()) {
            throw new BadRequestException("Guardian name required for patients under 18");
        }
        if (req.getGuardianMobile() == null || !req.getGuardianMobile().matches("^[6-9]\\d{9}$")) {
            throw new BadRequestException("Valid guardian mobile number required for patients under 18");
        }
        if (!Boolean.TRUE.equals(req.getGuardianConsent())) {
            throw new BadRequestException("Guardian consent is mandatory for patients under 18");
        }
    }
}
*/


// new code as per bypass otp services 

package com.carecell.service.impl;

import com.carecell.dto.request.AuthDTOs.*;
import com.carecell.dto.response.AuthResponse;
import com.carecell.entity.User;
import com.carecell.enums.UserRole;
import com.carecell.exception.BadRequestException;
import com.carecell.exception.ConflictException;
import com.carecell.exception.ResourceNotFoundException;
import com.carecell.repository.UserRepository;
import com.carecell.security.JwtTokenProvider;
import com.carecell.service.OtpService;
import com.carecell.util.HealthIdGenerator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final OtpService otpService;
    private final HealthIdGenerator healthIdGenerator;

    @Transactional
    public String register(RegisterRequest req) {

        if (userRepository.existsByMobileNumber(req.getMobileNumber())) {
            throw new ConflictException("Mobile number already registered");
        }

        if (req.getRole() == UserRole.DONOR && req.getAge() < 18) {
            throw new BadRequestException("Donors must be 18 years or older");
        }

        if (req.getRole() == UserRole.PATIENT && req.getAge() < 18) {
            validateGuardianInfo(req);
        }

        User.UserBuilder builder = User.builder()
                .name(req.getName())
                .mobileNumber(req.getMobileNumber())
                .age(req.getAge())
                .gender(req.getGender())
                .bloodGroup(req.getBloodGroup())
                .state(req.getState())
                .role(req.getRole())
                .passwordHash(passwordEncoder.encode(req.getPassword()))
                // TEMP: Auto verify mobile
                .mobileVerified(true);

        if (req.getRole() == UserRole.PATIENT) {
            builder.healthId(healthIdGenerator.generate());
        }

        if (req.getRole() == UserRole.PATIENT && req.getAge() < 18) {
            builder.guardian(
                    User.GuardianInfo.builder()
                            .name(req.getGuardianName())
                            .mobileNumber(req.getGuardianMobile())
                            .relationship(req.getGuardianRelationship())
                            .consentGiven(Boolean.TRUE.equals(req.getGuardianConsent()))
                            .build()
            );
        }

        userRepository.save(builder.build());

        // ===========================
        // OTP DISABLED FOR DEVELOPMENT
        // otpService.sendOtp(req.getMobileNumber());
        // ===========================

        return "Registration successful";
    }

    @Transactional
    public void verifyMobile(VerifyOtpRequest req) {

        // OTP verification disabled

        User user = findByMobile(req.getMobileNumber());
        user.setMobileVerified(true);
        userRepository.save(user);
    }

    public AuthResponse login(LoginRequest req) {

        User user = findByMobile(req.getMobileNumber());

        if (!user.isActive()) {
            throw new BadRequestException("Account is deactivated. Please contact support.");
        }

        if (!passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new BadRequestException("Invalid mobile number or password");
        }

        // OTP verification disabled

        return buildAuthResponse(user);
    }

    public AuthResponse refreshToken(RefreshTokenRequest req) {

        if (!jwtTokenProvider.validateToken(req.getRefreshToken())) {
            throw new BadRequestException("Invalid or expired refresh token");
        }

        String userId = jwtTokenProvider.getUserIdFromToken(req.getRefreshToken());

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));

        return buildAuthResponse(user);
    }

    @Transactional
    public void forgotPassword(ForgotPasswordRequest req) {

        findByMobile(req.getMobileNumber());

        // OTP disabled
        // otpService.sendOtp(req.getMobileNumber());
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest req) {

        // OTP disabled
        // otpService.verifyOtp(req.getMobileNumber(), req.getOtp());

        User user = findByMobile(req.getMobileNumber());

        user.setPasswordHash(passwordEncoder.encode(req.getNewPassword()));

        userRepository.save(user);
    }

    private User findByMobile(String mobile) {

        return userRepository.findByMobileNumber(mobile)
                .orElseThrow(() ->
                        new ResourceNotFoundException("No account found with this mobile number"));
    }

    private AuthResponse buildAuthResponse(User user) {

        String access = jwtTokenProvider.generateAccessToken(
                user.getId(),
                user.getRole().name());

        String refresh = jwtTokenProvider.generateRefreshToken(user.getId());

        return AuthResponse.builder()
                .accessToken(access)
                .refreshToken(refresh)
                .tokenType("Bearer")
                .expiresIn(86400)
                .user(
                        AuthResponse.UserInfo.builder()
                                .id(user.getId())
                                .name(user.getName())
                                .mobileNumber(user.getMobileNumber())
                                .age(user.getAge())
                                .gender(user.getGender())
                                .bloodGroup(user.getBloodGroup())
                                .state(user.getState())
                                .role(user.getRole())
                                .healthId(user.getHealthId())
                                .mobileVerified(user.isMobileVerified())
                                .profileComplete(user.isProfileComplete())
                                .build())
                .build();
    }

    private void validateGuardianInfo(RegisterRequest req) {

        if (req.getGuardianName() == null || req.getGuardianName().isBlank()) {
            throw new BadRequestException(
                    "Guardian name required for patients under 18");
        }

        if (req.getGuardianMobile() == null
                || !req.getGuardianMobile().matches("^[6-9]\\d{9}$")) {
            throw new BadRequestException(
                    "Valid guardian mobile number required for patients under 18");
        }

        if (!Boolean.TRUE.equals(req.getGuardianConsent())) {
            throw new BadRequestException(
                    "Guardian consent is mandatory for patients under 18");
        }
    }
}