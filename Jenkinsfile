pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        REGISTRY    = "ghcr.io"
        IMAGE_NAME  = "gutamurr/devops-lab-app"
        GHCR_EMAIL  = "gutamurr@gmail.com"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Prepare') {
            steps {
                script {
                    env.IMAGE_TAG = env.GIT_COMMIT.take(7)
                    env.FULL_IMAGE = "${env.REGISTRY}/${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build') {
            steps {
                sh "docker build -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -t ${REGISTRY}/${IMAGE_NAME}:latest ."
            }
        }

        stage('Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'ghcr-creds',
                        usernameVariable: 'GHCR_USER',
                        passwordVariable: 'GHCR_TOKEN'
                    )
                ]) {
                    sh """
                        echo "\$GHCR_TOKEN" | docker login ${REGISTRY} -u "\$GHCR_USER" --password-stdin
                        docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${REGISTRY}/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([
                    file(credentialsId: 'k3s-kubeconfig', variable: 'KUBECONFIG'),
                    usernamePassword(
                        credentialsId: 'ghcr-creds',
                        usernameVariable: 'GHCR_USER',
                        passwordVariable: 'GHCR_TOKEN'
                    )
                ]) {
                    sh """
                        export NODE_IP=\$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

                        kubectl create secret docker-registry ghcr-auth \
                            --namespace devops-lab \
                            --docker-server=${REGISTRY} \
                            --docker-username="\$GHCR_USER" \
                            --docker-password="\$GHCR_TOKEN" \
                            --docker-email="${GHCR_EMAIL}" \
                            --dry-run=client -o yaml | kubectl apply -f -

                        envsubst '\${FULL_IMAGE}' < k8s/deployment.yaml.template | kubectl apply -f -
                        kubectl apply -f k8s/service.yaml
                        envsubst '\${NODE_IP}' < k8s/ingress.yaml.template | kubectl apply -f -
                        
                        kubectl rollout status deployment/app -n devops-lab
                    """
                }
            }
        }
    }
}