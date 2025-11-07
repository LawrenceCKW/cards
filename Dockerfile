
# ---------- Build stage ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace

# Cache dependencies
COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline

# Build
COPY src ./src
RUN mvn -B -DskipTests clean package

# ---------- Runtime stage (multi-arch) ----------
# Use Debian-based image (multi-arch); Alpine variant often lacks arm64
FROM eclipse-temurin:17-jre-jammy AS runtime
WORKDIR /app

# Copy the fat jar without hard-coding its name
COPY --from=build /workspace/target/*.jar /app/app.jar

EXPOSE 9000
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app/app.jar"]





#FROM eclipse-temurin:17-jdk
#
#COPY target/cards-0.0.1-SNAPSHOT.jar cards-0.0.1-SNAPSHOT.jar
#
#ENTRYPOINT ["java", "-jar", "cards-0.0.1-SNAPSHOT.jar"]