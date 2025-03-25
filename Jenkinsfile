pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "hello-world:latest"
        NAMESPACE = "jenkins"
        KUBE_CONTEXT = "minikube"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image using the Dockerfile
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Start Minikube') {
            steps {
                script {
                    // Ensure Minikube is started
                    sh 'minikube start'
                }
            }
        }

        stage('Push Docker Image to Minikube') {
            steps {
                script {
                    // Use Docker within Minikube
                    sh "eval \$(minikube -p minikube docker-env)"
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    // Create a Kubernetes Deployment
                    sh """
                    kubectl apply -f - <<EOF
                    apiVersion: apps/v1
                    kind: Deployment
                    metadata:
                      name: hello-world-deployment
                    spec:
                      replicas: 1
                      selector:
                        matchLabels:
                          app: hello-world
                      template:
                        metadata:
                          labels:
                            app: hello-world
                        spec:
                          containers:
                          - name: hello-world-container
                            image: ${DOCKER_IMAGE}
                            ports:
                            - containerPort: 80
                    EOF
                    """
                }
            }
        }

        stage('Expose Service and Ingress') {
            steps {
                script {
                    // Expose the service to make it available
                    sh """
                    kubectl expose deployment hello-world-deployment --port=80 --target-port=80 --name=hello-world-service
                    kubectl expose deployment hello-world-deployment --port=80 --target-port=80 --name=hello-world-service --type=LoadBalancer
                    kubectl apply -f - <<EOF
                    apiVersion: networking.k8s.io/v1
                    kind: Ingress
                    metadata:
                      name: hello-world-ingress
                    spec:
                      rules:
                      - host: $(minikube ip).nip.io
                        http:
                          paths:
                          - path: /
                            pathType: Prefix
                            backend:
                              service:
                                name: hello-world-service
                                port:
                                  number: 80
                    EOF
                    """
                }
            }
        }
    }

    post {
        always {
            // Clean up after the pipeline if needed
            echo 'Pipeline completed.'
        }
    }
}
