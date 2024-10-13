pipeline {
    agent {
        docker {
            image 'maven:3.8.1-jdk-17'  // Imagen de Maven para construir
            args '-v /var/run/docker.sock:/var/run/docker.sock'  // Acceso a Docker del host
        }
    }
    environment {
        DOCKER_IMAGE = "cerodasv/sgh_api:v1.0"  // Reemplaza con tu usuario y nombre de imagen
        POSTMAN_COLLECTION = "tests/postman/Pruebas_API_SGH.postman_collection.json"  // Ruta a la colección
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/CERODAS/sgh_api.git'  // Reemplaza con la URL de tu repositorio
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean package'  // Construye el proyecto
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}")  // Construye la imagen Docker
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    docker.image("${DOCKER_IMAGE}").run('-d -p 8081:8081 --network=app-network springboot-app')  // Despliega el contenedor
                }
            }
        }
        stage('Run Tests with Newman') {
            steps {
                script {
                    // Ejecuta Newman usando su imagen Docker
                    docker.image('postman/newman:latest').inside('--network=app-network') {
                        sh "newman run ${POSTMAN_COLLECTION} --reporters cli,junit --reporter-junit-export newman-results.xml"
                    }
                }
            }
            post {
                always {
                    // Publica los resultados de las pruebas
                    junit 'newman-results.xml'
                }
            }
        }
        stage('Clean Up') {
            steps {
                script {
                    // Detiene y elimina el contenedor de la aplicación
                    sh 'docker stop springboot-app'
                    sh 'docker rm springboot-app'
                }
            }
        }
    }
    post {
        always {
            // Limpia imágenes y contenedores no utilizados
            sh 'docker system prune -f'
        }
    }
}
