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
        stage('Build') {
            steps {
                echo "----------Build started-----------"
                sh 'mvn clean deploy -DskipTests'
                echo "----------Build completed-----------"
            }
        }
        /*stage("Test"){
            steps {
                echo "----------Unit Test started-----------"
                sh 'mvn surefire-report:report'
                echo "----------Unit Test completed-----------"
            }
        }*/
        stage('SonarQube analysis') {
            environment{
                scannerHome = tool 'jenkins-sonar-scanner';
            } 
            steps {
            withSonarQubeEnv('jenkins-sonar-server') { // If you have configured more than one global server connection, you can specify its name
            sh "${scannerHome}/bin/sonar-scanner"
            }
        }
    }
}
}