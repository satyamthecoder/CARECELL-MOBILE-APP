package com.carecell.util;

import org.springframework.stereotype.Component;
import java.time.Year;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Generates unique Health IDs in format: CC-YYYY-XXXXXX
 * e.g. CC-2024-000001
 * In production, use a distributed counter (Redis INCR) for multi-instance safety.
 */
@Component
public class HealthIdGenerator {

    private final AtomicLong counter = new AtomicLong(0);

    public String generate() {
        long seq = counter.incrementAndGet();
        int year = Year.now().getValue();
        return String.format("CC-%d-%06d", year, seq);
    }
}
