# # Stage 1: Build the JAR file
# FROM gradle:8.8-jdk17 AS builder
# WORKDIR /app
# COPY . .
# RUN gradle clean build -x test

# # Stage 2: Extract the JAR file
# FROM amazoncorretto:17-alpine AS extractor
# WORKDIR extracted
# COPY --from=builder /app/build/libs/*.jar app.jar 
# RUN java -Djarmode=layertools -jar app.jar extract

# # Stage 3: Create the final image
# FROM amazoncorretto:17-alpine
# WORKDIR application
# COPY --from=extractor extracted/dependencies/ ./
# COPY --from=extractor extracted/spring-boot-loader/ ./
# COPY --from=extractor extracted/snapshot-dependencies/ ./
# COPY --from=extractor extracted/application/ ./

# EXPOSE 8080
# ENTRYPOINT ["java", "-Duser.timezone=UTC", "-Dlogstash.host.name=logstash", "-Dlogstash.port.number=9999", "org.springframework.boot.loader.launch.JarLauncher"]

# # Stage 1: Build the JAR file
# FROM gradle:8.8-jdk17 AS builder
# WORKDIR /app
# COPY . .
# RUN gradle clean build -x test

# # Stage 2: Extract the JAR file
# FROM amazoncorretto:17-alpine AS extractor
# WORKDIR extracted
# COPY --from=builder /app/build/libs/*.jar ./
# RUN java -Djarmode=layertools -jar /extracted/*.jar extract

# # Stage 3: Create the final image
# FROM amazoncorretto:17-alpine
# WORKDIR application
# COPY --from=extractor extracted/dependencies/ ./
# COPY --from=extractor extracted/spring-boot-loader/ ./
# COPY --from=extractor extracted/snapshot-dependencies/ ./
# COPY --from=extractor extracted/application/ ./

# # Установка дополнительных утилит (опционально)
# RUN apk add --no-cache bash curl postgresql-client

# # Expose порта для приложения
# EXPOSE 8080
# EXPOSE 5005 

# # Команда запуска
# ENTRYPOINT ["java", "-Duser.timezone=UTC", "-Dspring.profiles.active=dev", "-Dfile.encoding=UTF-8", "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005", "org.springframework.boot.loader.launch.JarLauncher"]

# Stage 1: Build the JAR file using Gradle
FROM gradle:8.8-jdk17 AS builder
WORKDIR /app
COPY . .
RUN gradle clean build -x test

# Stage 2: Extract the JAR file using Amazon Corretto
FROM amazoncorretto:17-alpine AS extractor
WORKDIR /app/extracted
# Копируем все JAR-файлы из /app/build/libs/ в директорию /app/
COPY --from=builder /app/build/libs/ /app/
# Извлекаем слои из JAR-файла
RUN java -Djarmode=layertools -jar /app/*.jar extract

# Stage 3: Create the final image
FROM amazoncorretto:17-alpine
WORKDIR /app/application
# Копируем извлеченные слои из предыдущего этапа
COPY --from=extractor /app/extracted/dependencies/ ./
COPY --from=extractor /app/extracted/spring-boot-loader/ ./
COPY --from=extractor /app/extracted/snapshot-dependencies/ ./
COPY --from=extractor /app/extracted/application/ ./

# Установка дополнительных утилит (опционально)
RUN apk add --no-cache bash curl postgresql-client

# Expose порт для приложения
EXPOSE 8080
EXPOSE 5005

# Команда запуска приложения
ENTRYPOINT ["java", "-Duser.timezone=UTC", "-Dspring.profiles.active=dev", "-Dfile.encoding=UTF-8", "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005", "org.springframework.boot.loader.launch.JarLauncher"]
