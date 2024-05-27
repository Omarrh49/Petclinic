pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven'
        zap 'ZAP'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/omarrh49/Petclinic.git'
            }
        }
        
        stage('Code Compile') {
            steps {
                sh "mvn clean compile"
            }
        }
        
        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --format XML', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
        stage('Sonar Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Devops- \
                    -Dsonar.java.binaries=. \
                    -Dsonar.projectKey=Devops-'''
                }
            }
        }
        
        stage('Trivy Scan') {
            steps {
                sh "trivy fs . > trivy-fs_report.txt"
            }
        }
        
        stage('Code Build') {
            steps {
                sh "mvn clean install"
            }
        }
        
        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    }
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    sh "docker build -t petclinic ."
                }
            }
        }
        
        stage('Trivy') {
            steps {
                sh "trivy image omarrh/petclinic:latest > trivy.txt"
            }
        }
        
        stage('Docker Push') {
            steps {
                script {
                    sh "docker tag petclinic omarrh/petclinic:latest"
                    sh "docker push omarrh/petclinic:latest"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh "docker run -d --name petclinica -p 5000:5000 omarrh/petclinic:latest"
            }
        }

        
        stage('Security Scan with ZAP') {
            steps {
                script {
                    def zapHome = tool 'ZAP'
                    sh "${zapHome}/zap.sh -daemon -host 0.0.0.0 -port 8082 > zap.log 2>&1 &"
                    sleep(time: 60, unit: 'SECONDS')
                    sh "curl http://localhost:8082/JSON/core/view/version"
                    sh "${zapHome}/zap.sh -quickurl http://localhost:5000 -quickout zap-report.html -htmlreport"
                }
            }
        }

        stage('Publish ZAP Report') {
            steps {
                publishHTML(reportDir: '', reportFiles: 'zap-report.html', reportName: 'ZAP Report')
            }
        }
    }
}
