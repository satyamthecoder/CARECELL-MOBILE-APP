package com.carecell.service;

import com.carecell.exception.BadRequestException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.sns.SnsClient;
import software.amazon.awssdk.services.sns.model.PublishRequest;

import java.security.SecureRandom;
import java.time.Duration;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class OtpService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final SnsClient snsClient;

    @Value("${otp.expiry-minutes:10}")
    private int otpExpiryMinutes;

    @Value("${otp.length:6}")
    private int otpLength;

    @Value("${otp.max-attempts:3}")
    private int maxAttempts;

    @Value("${aws.sns.sender-id:CareCell}")
    private String senderId;

    private static final String OTP_KEY_PREFIX     = "otp:";
    private static final String ATTEMPT_KEY_PREFIX = "otp_attempts:";

    private final SecureRandom random = new SecureRandom();

    /** Generate, store and send OTP via SMS (AWS SNS) */
    public void sendOtp(String mobileNumber) {
        String otp = generateOtp();
        String key = OTP_KEY_PREFIX + mobileNumber;

        redisTemplate.opsForValue().set(key, otp, Duration.ofMinutes(otpExpiryMinutes));
        // Reset attempt counter on fresh send
        redisTemplate.delete(ATTEMPT_KEY_PREFIX + mobileNumber);

        sendSms(mobileNumber, buildOtpMessage(otp));
        log.info("OTP sent to +91{}", mobileNumber);
    }

    /** Validate OTP — throws on failure, cleans up on success */
    public void verifyOtp(String mobileNumber, String otp) {
        String attemptsKey = ATTEMPT_KEY_PREFIX + mobileNumber;
        Long attempts = redisTemplate.opsForValue().increment(attemptsKey);
        redisTemplate.expire(attemptsKey, Duration.ofMinutes(otpExpiryMinutes));

        if (attempts != null && attempts > maxAttempts) {
            throw new BadRequestException("Too many failed attempts. Request a new OTP.");
        }

        String key = OTP_KEY_PREFIX + mobileNumber;
        Object stored = redisTemplate.opsForValue().get(key);

        if (stored == null) {
            throw new BadRequestException("OTP expired or not found. Please request a new one.");
        }
        if (!stored.toString().equals(otp)) {
            throw new BadRequestException("Incorrect OTP. " + (maxAttempts - attempts) + " attempts remaining.");
        }

        // Clean up after successful verification
        redisTemplate.delete(key);
        redisTemplate.delete(attemptsKey);
    }

    private String generateOtp() {
        int bound = (int) Math.pow(10, otpLength);
        int otpInt = random.nextInt(bound);
        return String.format("%0" + otpLength + "d", otpInt);
    }

    private String buildOtpMessage(String otp) {
        return String.format(
            "Your CareCell verification code is %s. Valid for %d minutes. Do not share this with anyone. -CareCell",
            otp, otpExpiryMinutes
        );
    }

    private void sendSms(String mobileNumber, String message) {
        try {
            String formattedNumber = "+91" + mobileNumber;
            snsClient.publish(PublishRequest.builder()
                .phoneNumber(formattedNumber)
                .message(message)
                .build());
        } catch (Exception e) {
            log.error("Failed to send SMS to {}: {}", mobileNumber, e.getMessage());
            // In production: queue for retry via SQS. Don't fail the request.
        }
    }
}
