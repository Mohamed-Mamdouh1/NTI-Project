pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '946486897686'
        AWS_REGION = 'eu-west-1'
        EKS_CLUSTER_NAME = 'nti-eks-cluster'
        REPO_NAME = 'web-app-example'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
    }

    stages {
        stage('Checkout Source') {
            steps {
                echo '📥 Cloning repository...'
                checkout scm
            }
        }

        stage('Build Docker Images') {
            steps {
                echo '🐳 Building Docker images...'
                sh '''
                    docker build -t $REPO_NAME-web ./web
                    docker build -t $REPO_NAME-api ./api
                    docker build -t $REPO_NAME-worker ./worker
                '''
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                echo '🔍 Running vulnerability scan with Trivy...'
                sh '''
                    trivy image $REPO_NAME-web || true
                    trivy image $REPO_NAME-api || true
                    trivy image $REPO_NAME-worker || true
                '''
            }
        }

        stage('Authenticate to AWS ECR') {
            steps {
                echo '🔐 Logging in to AWS ECR...'
                withAWS(region: "${AWS_REGION}", credentials: 'b6099f18-364e-4ac5-b366-3801c0bad854') {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Tag & Push to ECR') {
            steps {
                echo '📤 Pushing Docker images to ECR...'
                withAWS(region: "${AWS_REGION}", credentials: 'b6099f18-364e-4ac5-b366-3801c0bad854') {
                    sh '''
                        docker tag $REPO_NAME-web:latest $ECR_URL-web:$IMAGE_TAG
                        docker tag $REPO_NAME-api:latest $ECR_URL-api:$IMAGE_TAG
                        docker tag $REPO_NAME-worker:latest $ECR_URL-worker:$IMAGE_TAG

                        docker push $ECR_URL-web:$IMAGE_TAG
                        docker push $ECR_URL-api:$IMAGE_TAG
                        docker push $ECR_URL-worker:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                echo '📝 Updating Kubernetes manifests with new image tags...'
                sh '''
                    sed -i "s|image: .*/web:.*|image: $ECR_URL-web:$IMAGE_TAG|" ./web/manifests/deployment.yaml
                    sed -i "s|image: .*/api:.*|image: $ECR_URL-api:$IMAGE_TAG|" ./api/manifests/deployment.yaml
                    sed -i "s|image: .*/worker:.*|image: $ECR_URL-worker:$IMAGE_TAG|" ./worker/manifests/deployment.yaml
                '''
            }
        }

//         stage('Deploy to EKS') {
//             steps {
//                 echo '🚀 Deploying to EKS cluster...'
//                 withAWS(region: "${AWS_REGION}", credentials: 'b6099f18-364e-4ac5-b366-3801c0bad854') {
//                     sh '''
//                         aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME

//                         kubectl apply -f ./api/manifests/
//                         kubectl apply -f ./web/manifests/
//                         kubectl apply -f ./worker/manifests/

//                         kubectl get pods -A
//                     '''
//                 }
//             }
//         }
//     }

//     post {
//         success {
//             echo '✅ Deployment completed successfully!'
//         }
//         failure {
//             echo '❌ Deployment failed. Check Jenkins logs for details.'
//         }
//     }
// }

