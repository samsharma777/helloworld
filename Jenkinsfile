pipeline {
    agent any

    environment {
        KUBE_CONTEXT = "minikube"  // Ensure the Minikube context is being used
        NAMESPACE = "jenkins"      // Specify the namespace where the pod will be deployed
    }

    stages {
        stage('Deploy Hello World Pod') {
            steps {
                script {
                    // Define the Pod YAML dynamically and include the namespace
                    def podYaml = """
                    apiVersion: v1
                    kind: Pod
                    metadata:
                      name: hello-world-pod
                      namespace: ${env.NAMESPACE}  // Specify the namespace here
                      labels:
                        app: hello-world
                    spec:
                      containers:
                      - name: nginx
                        image: nginx:alpine
                        ports:
                        - containerPort: 80
                    """

                    // Write the YAML content to a file
                    writeFile file: 'hello-world-pod.yaml', text: podYaml

                    // Apply the YAML file to the Minikube cluster in the specified namespace
                    sh "kubectl apply -f hello-world-pod.yaml -n ${env.NAMESPACE}"
                }
            }
        }

        stage('Expose Pod via LoadBalancer') {
            steps {
                script {
                    // Expose the pod as a LoadBalancer service on port 80 in the specified namespace
                    sh "kubectl expose pod hello-world-pod --port=80 --type=LoadBalancer -n ${env.NAMESPACE}"

                    // Wait a few seconds for the LoadBalancer to initialize (if necessary)
                    sleep(time: 5, unit: "SECONDS")
                }
            }
        }

        stage('Verify Pod and Service') {
            steps {
                script {
                    // Check if the pod is running in the specified namespace
                    def podStatus = sh(script: "kubectl get pods hello-world-pod -n ${env.NAMESPACE} -o jsonpath='{.status.phase}'", returnStdout: true).trim()
                    if (podStatus == "Running") {
                        echo "Pod hello-world-pod is running in the ${env.NAMESPACE} namespace."
                    } else {
                        error "Pod hello-world-pod failed to start in the ${env.NAMESPACE} namespace."
                    }

                    // Verify that the service is created in the specified namespace
                    def serviceStatus = sh(script: "kubectl get svc hello-world-pod -n ${env.NAMESPACE}", returnStdout: true).trim()
                    echo "Service Status: ${serviceStatus}"

                    // Check if EXTERNAL-IP is available for LoadBalancer
                    def externalIP = sh(script: "kubectl get svc hello-world-pod -n ${env.NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'", returnStdout: true).trim()
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
