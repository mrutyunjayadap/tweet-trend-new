pipeline {
    agent {
        node {
            label 'maven'
        }
    }
environment{
    PATH = "/opt/apache-maven-3.9.6/bin:$PATH"
}
    stages {
        stage('build') {
            steps {
                sh 'mvn clean deploy -DskipTests'
            }
        }
        stage('SonarQube analysis') {
            environment{
                scannerHome = tool 'jenkins-sonar-scanner';
            } 
            steps{
            withSonarQubeEnv('jenkins-sonar-server') { // If you have configured more than one global server connection, you can specify its name
            sh "${scannerHome}/bin/sonar-scanner"
            }
            }
    }
}
