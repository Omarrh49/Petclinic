pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven'
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
                sh "mvn clean package"
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
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Devops-1 \
                    -Dsonar.java.binaries=. \
                    -Dsonar.projectKey=Devops-1'''
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
                     sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"                    }
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    sh "docker build -t omarrh/petclinic ."
                }
            }
        }
        
        stage('Trivy') {
            steps {
                sh "trivy image --timeout 5m omarrh/petclinic:latest > trivy.txt"
            }
        }
        
        stage('Docker Push') {
            steps {
                script {
                    sh "docker tag omarrh/petclinic omarrh/petclinic:latest"
                    sh "docker push omarrh/petclinic:latest"
                }
            }
        }
        
       stage("Deploy To Tomcat"){
            steps{
                sh "cp  /var/lib/jenkins/workspace/DevSecOps/target/petclinic.war /opt/apache-tomcat-9.0.65/webapps/ "
            }
        }

        
         stage('Security Scan with ZAP') {
            steps {
                script {
                    sh "chmod +x zap.sh"
                    sh "./zap.sh"
                }
            }
        }

        stage('Publish ZAP Report') {
    steps {
        publishHTML(target: [
            reportName: 'ZAP Report', 
            reportDir: 'owasp-zap-report', 
            reportFiles: 'zap_report.html', 
            keepAll: true, 
            alwaysLinkToLastBuild: true, 
            allowMissing: false
        ])
    }
}
    }
}
