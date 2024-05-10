def registry = 'https://mrutyunjay.jfrog.io/'
def imageName = 'mrutyunjay.jfrog.io/docker-trial/tweet-app'
def version   = '2.1.3'
pipeline {
    agent {
        node {
            label 'maven'
        }
    }
    environment {
        PATH = "/opt/apache-maven-3.9.6/bin:$PATH"
    }
    stages {
        stage('Build') {
            steps {
                echo '----------Build started-----------'
                sh 'mvn clean deploy -DskipTests'
                echo '----------Build completed-----------'
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
            environment {
                scannerHome = tool 'jenkins-sonar-scanner'
            }
            steps {
                withSonarQubeEnv('jenkins-sonar-server') { // If you have configured more than one global server connection, you can specify its name
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }
/*
        stage('Quality Gate') {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }*/
        
        stage('Jar Publish') {
            steps {
                script {
                    echo '<--------------- Jar Publish Started --------------->'
                    def server = Artifactory.newServer url:registry + '/artifactory' ,  credentialsId:'Jfrog-login'
                    def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}"
                    def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "my-maven-libs-release-local/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                    def buildInfo = server.upload(uploadSpec)
                    buildInfo.env.collect()
                    server.publishBuildInfo(buildInfo)
                    echo '<--------------- Jar Publish Ended --------------->'
                }
            }
        }

        stage(' Docker Build ') {
            steps {
                script {
                    echo '<--------------- Docker Build Started --------------->'
                    app = docker.build(imageName + ':' + version)
                    echo '<--------------- Docker Build Ends --------------->'
                }
            }
        }

        stage(' Docker Publish ') {
            steps {
                script {
                    echo '<--------------- Docker Publish Started --------------->'
                    docker.withRegistry(registry, 'Jfrog-login') {
                        app.push()
                    }
                    echo '<--------------- Docker Publish Ended --------------->'
        }
            }
        }
    }
}
