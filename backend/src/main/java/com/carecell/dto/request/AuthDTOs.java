package com.carecell.dto.request;

import com.carecell.enums.BloodGroup;
import com.carecell.enums.Gender;
import com.carecell.enums.UserRole;
import jakarta.validation.constraints.*;
import lombok.Data;

public class AuthDTOs {

    @Data
    public static class RegisterRequest {
        @NotBlank(message = "Name is required")
        @Size(min = 2, max = 100)
        private String name;

        @NotBlank(message = "Mobile number is required")
        @Pattern(regexp = "^[6-9]\\d{9}$", message = "Enter a valid 10-digit Indian mobile number")
        private String mobileNumber;

        @NotNull(message = "Age is required")
        @Min(value = 1) @Max(value = 120)
        private Integer age;

        @NotNull(message = "Gender is required")
        private Gender gender;

        @NotNull(message = "Blood group is required")
        private BloodGroup bloodGroup;

        @NotBlank(message = "State is required")
        private String state;

        @NotNull(message = "Role is required")
        private UserRole role;

        @NotBlank(message = "Password is required")
        @Size(min = 8, message = "Password must be at least 8 characters")
        private String password;

        // Guardian fields — required only when age < 18 and role = PATIENT
        private String guardianName;
        private String guardianMobile;
        private String guardianRelationship;
        private Boolean guardianConsent;
    }

    @Data
    public static class SendOtpRequest {
        @NotBlank
        @Pattern(regexp = "^[6-9]\\d{9}$")
        private String mobileNumber;
    }

    @Data
    public static class VerifyOtpRequest {
        @NotBlank
        private String mobileNumber;

        @NotBlank
        @Size(min = 6, max = 6, message = "OTP must be 6 digits")
        private String otp;
    }

    @Data
    public static class LoginRequest {
        @NotBlank
        @Pattern(regexp = "^[6-9]\\d{9}$")
        private String mobileNumber;

        @NotBlank
        private String password;
    }

    @Data
    public static class RefreshTokenRequest {
        @NotBlank
        private String refreshToken;
    }

    @Data
    public static class ForgotPasswordRequest {
        @NotBlank
        @Pattern(regexp = "^[6-9]\\d{9}$")
        private String mobileNumber;
    }

    @Data
    public static class ResetPasswordRequest {
        @NotBlank
        private String mobileNumber;

        @NotBlank
        @Size(min = 6, max = 6)
        private String otp;

        @NotBlank
        @Size(min = 8)
        private String newPassword;
    }
}
