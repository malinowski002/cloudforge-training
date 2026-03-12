FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre
RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /app
COPY --from=build --chown=app:app /app/target/*.jar app.jar
USER app
EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.jar"]