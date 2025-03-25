pipeline {
    agent any

    environment {
        KUBE_CONTEXT = "minikube"
        NAMESPACE = "jenkins"
    }

    stages {
        stage('Deploy Hello World Pod') {
            steps {
                script {
                    def podYaml = """
                    apiVersion: v1
                    kind: Pod
                    metadata:
                      name: hello-world-pod
                      namespace: ${env.NAMESPACE}
                      labels:
                        app: hello-world
                    spec:
                      containers:
                      - name: nginx
                        image: nginx:alpine
                        ports:
                        - containerPort: 80
                    """
                    writeFile file: 'hello-world-pod.yaml', text: podYaml

                    // Use bat instead of sh for Windows
                    bat "kubectl apply -f hello-world-pod.yaml -n ${env.NAMESPACE}"
                }
            }
        }

        stage('Expose Pod via LoadBalancer') {
            steps {
                script {
                    // Use bat instead of sh for Windows
                    bat "kubectl expose pod hello-world-pod --port=80 --type=LoadBalancer -n ${env.NAMESPACE}"

                    // Wait for a few seconds for the LoadBalancer to initialize
                    sleep(time: 5, unit: "SECONDS")
                }
            }
        }

        stage('Verify Pod and Service') {
            steps {
                script {
                    def podStatus = bat(script: "kubectl get pods hello-world-pod -n ${env.NAMESPACE} -o jsonpath='{.status.phase}'", returnStdout: true).trim()
                    if (podStatus == "Running") {
                        echo "Pod hello-world-pod is running in the ${env.NAMESPACE} namespace."
                    } else {
                        error "Pod hello-world-pod failed to start in the ${env.NAMESPACE} namespace."
                    }

                    def serviceStatus = bat(script: "kubectl get svc hello-world-pod -n ${env.NAMESPACE}", returnStdout: true).trim()
                    echo "Service Status: ${serviceStatus}"

                    def externalIP = bat(script: "kubectl get svc hello-world-pod -n ${env.NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'", returnStdout: true).trim()
                    if (externalIP) {
                        echo "Service is accessible at http://${externalIP}:80"
                    } else {
                        echo "EXTERNAL-IP is still pending, but you can try accessing via NodePort."
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished"
        }
    }
}
