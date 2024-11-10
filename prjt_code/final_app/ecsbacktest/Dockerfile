# Step 1: Build stage
FROM gradle:8.4.0-jdk17 AS build
WORKDIR /app

# Gradle 빌드를 위해 필요한 파일들을 복사
COPY build.gradle settings.gradle ./
COPY gradle ./gradle
COPY src ./src

# Build the application with detailed logs
RUN gradle clean bootJar --info

# Step 2: Run stage
FROM openjdk:17-jdk-slim

WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar

# 애플리케이션을 실행
ENTRYPOINT ["java", "-jar", "app.jar"]
