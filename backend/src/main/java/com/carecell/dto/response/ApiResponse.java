package com.carecell.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Data;
import java.time.Instant;

@Data
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;
    private Instant timestamp;

    public static <T> ApiResponse<T> ok(T data) {
        return ApiResponse.<T>builder()
            .success(true).data(data).timestamp(Instant.now()).build();
    }

    public static <T> ApiResponse<T> ok(String message, T data) {
        return ApiResponse.<T>builder()
            .success(true).message(message).data(data).timestamp(Instant.now()).build();
    }

    public static <T> ApiResponse<T> message(String message) {
        return ApiResponse.<T>builder()
            .success(true).message(message).timestamp(Instant.now()).build();
    }
}
