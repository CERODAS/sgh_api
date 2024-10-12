# Usar una imagen base de OpenJDK 17
FROM openjdk:17-jdk-slim

# Crear un directorio para la aplicación
WORKDIR /app

# Copiar el archivo JAR generado por el build de Spring Boot
COPY target/sgh-0.0.1-SNAPSHOT.jar app.jar

# Exponer el puerto en el que correrá tu aplicación (ejemplo: 8080)
EXPOSE 8081

# Ejecutar la aplicación Spring Boot
ENTRYPOINT ["java", "-jar", "app.jar"]