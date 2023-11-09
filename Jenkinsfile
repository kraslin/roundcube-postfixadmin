pipeline {
    environment {
        dockerImage = ''
    }

    parameters {
        string(name:'DockerImageName', defaultValue: params.DockerImageName ?:'docker.krasl.in/roundcube/roundcube', description: 'Name of image to build')
        string(name:'RepoCredentials', defaultValue: params.RepoCredentials ?:'', description: 'Repository credentials')
        booleanParam(name:'PushImage', defaultValue: params.PushImage ?:true, description: 'Push the image after building')
        booleanParam(name:'TagLatest', defaultValue: params.TagLatest ?:true, description: 'Tag the image as latest')
    }

    agent any;
    stages {
        stage('Build Image') {
            steps {
                script {
                    dockerImage = docker.build("${params.DockerImageName}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    if( params.PushImage ) {
                        docker.withRegistry('', params.RepoRepository) {
                            dockerImage.push()

                            if( params.TagLatest ) {
                                dockerImage.push('latest')
                            }
                        }
                    }
                }
            }
        }
    }
}

