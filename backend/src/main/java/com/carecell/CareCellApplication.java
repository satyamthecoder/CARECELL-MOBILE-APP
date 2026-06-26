package com.carecell;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.data.mongodb.config.EnableMongoAuditing;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * CareCell — AI-Powered Healthcare Assistance Platform
 * Production Backend Entry Point
 */
@SpringBootApplication
@EnableMongoAuditing
@EnableCaching
@EnableAsync
@EnableScheduling
public class CareCellApplication {

    public static void main(String[] args) {
        SpringApplication.run(CareCellApplication.class, args);
    }

    @Bean
    CommandLineRunner checkRedisConfiguration(
            @Value("${spring.redis.host:NOT_FOUND}") String springRedisHost,
            @Value("${spring.redis.port:-1}") String springRedisPort,
            @Value("${spring.data.redis.host:NOT_FOUND}") String springDataRedisHost,
            @Value("${spring.data.redis.port:-1}") String springDataRedisPort,
            @Value("${REDIS_HOST:ENV_NOT_FOUND}") String envRedisHost,
            @Value("${REDIS_PORT:ENV_NOT_FOUND}") String envRedisPort) {

        return args -> {
            System.out.println("\n==============================================");
            System.out.println(" REDIS CONFIGURATION DEBUG");
            System.out.println("==============================================");
            System.out.println("Environment REDIS_HOST      : " + envRedisHost);
            System.out.println("Environment REDIS_PORT      : " + envRedisPort);
            System.out.println("spring.redis.host           : " + springRedisHost);
            System.out.println("spring.redis.port           : " + springRedisPort);
            System.out.println("spring.data.redis.host      : " + springDataRedisHost);
            System.out.println("spring.data.redis.port      : " + springDataRedisPort);
            System.out.println("==============================================\n");
        };
    }
}