package com.carecell.dto.response;

import com.carecell.enums.BloodGroup;
import com.carecell.enums.Gender;
import com.carecell.enums.UserRole;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private long expiresIn;
    private UserInfo user;

    @Data
    @Builder
    public static class UserInfo {
        private String id;
        private String name;
        private String mobileNumber;
        private Integer age;
        private Gender gender;
        private BloodGroup bloodGroup;
        private String state;
        private UserRole role;
        private String healthId;        // null for donors
        private boolean mobileVerified;
        private boolean profileComplete;
    }
}
