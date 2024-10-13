pipeline {
    agent any  // Utiliza el agente predeterminado de Jenkins
    
    tools {
        maven 'maven-default'
        dockerTool docker-default'  // Aquí el nombre que le diste a Docker en Jenkins
    }

    environment {
        DOCKER_IMAGE = "cerodasv/sgh_api:V1.0"  // Reemplaza con tu usuario y nombre de imagen
        POSTMAN_COLLECTION = "tests/postman/Pruebas_API_SGH.postman_collection.json"  // Ruta a la colección
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/CERODAS/sgh_api.git'  // Reemplaza con la URL de tu repositorio
            }
        }

        stage('Build') {
            agent {
                docker { image 'maven:3.8.1-jdk-17' }  // Utiliza la imagen de Maven para construir
            }
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

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'  // Autentica en Docker Hub
                }
                script {
                    docker.image("${DOCKER_IMAGE}").push()  // Empuja la imagen a Docker Hub
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
            agent {
                docker { image 'postman/newman:latest' }  // Utiliza la imagen Docker de Newman
            }
            steps {
                sh "newman run ${POSTMAN_COLLECTION} --reporters cli,junit --reporter-junit-export newman-results.xml"  // Ejecuta las pruebas
            }
            post {
                always {
                    junit 'newman-results.xml'  // Publica los resultados de las pruebas
                }
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    sh 'docker stop springboot-app'  // Detiene el contenedor desplegado
                    sh 'docker rm springboot-app'  // Elimina el contenedor
                }
            }
        }
    }

    post {
        always {
            script {
                sh 'docker system prune -f'  // Limpia imágenes y contenedores no utilizados
            }
        }
    }
}
