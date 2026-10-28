# ==============================================================================
# Faculty of Engineering, University of Ruhuna
# Smart Energy Monitoring and Analytics System
# Multi-Stage Dockerfile for Render Cloud Deployment
# ==============================================================================

# ------------------------------------------------------------------------------
# Stage 1: Build Application and Package Frontend with Maven
# ------------------------------------------------------------------------------
FROM eclipse-temurin:21-jdk-jammy AS builder

WORKDIR /app

# Copy Maven wrapper configuration and dependencies definition first for layer caching
COPY backend/.mvn ./backend/.mvn
COPY backend/mvnw backend/mvnw.cmd backend/pom.xml ./backend/

# Copy frontend source assets (required by maven-resources-plugin)
COPY frontend ./frontend

# Copy backend application source and resources
COPY backend/src ./backend/src

WORKDIR /app/backend

# Make wrapper script executable and build the production executable JAR
# Maven copy-frontend-resources phase automatically packages frontend/ into target/classes/static/
RUN chmod +x ./mvnw && \
    ./mvnw clean package -DskipTests --no-transfer-progress

# ------------------------------------------------------------------------------
# Stage 2: Minimal Production JRE Runtime
# ------------------------------------------------------------------------------
FROM eclipse-temurin:21-jre-jammy AS runner

WORKDIR /app

# Create a non-privileged system user for container security
RUN groupadd -r spring && useradd -r -g spring spring

# Copy compiled executable JAR from builder stage
COPY --from=builder /app/backend/target/*.jar /app/app.jar

# Set ownership to non-root user
RUN chown -R spring:spring /app

USER spring:spring

# Default port expected by Render (dynamically overridden at runtime by $PORT)
ENV PORT=5001
EXPOSE 5001

# Efficient containerized JVM flags with dynamic port binding
ENTRYPOINT ["sh", "-c", "java -Djava.security.egd=file:/dev/./urandom -Dserver.port=${PORT:-5001} -Dserver.address=0.0.0.0 -jar /app/app.jar"]
