pipeline {
    environment {
        dockerImage = ''
    }

    parameters {
        string(name:'DockerImageName', defaultValue: params.DockerImageName ?:'docker.krasl.in/roundcube/roundcube', description: 'Name of image to build')
        string(name:'RepoCredentials', defaultValue: params.RepoCredentials ?:'', description: 'Repository credentials')
        booleanParam(name:'PushImage', defaultValue: params.PushImage ?:true, description: 'Push the image after building')
        booleanParam(name:'TagLatest', defaultValue: params.TagLatest ?:true, description: 'Tag the image as latest')
        string(name:'ComposeAgent', defaultValue: params.ComposeAgent ?:'cornerstone', description: 'The agent on which to run docker-compose')
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

        stage('Compose') {
            when {
                beforeAgent true
		expression { return params.ComposeAgent != "" }
            }
            agent { label "${params.ComposeAgent}" }
            steps {
                sh("docker-compose up -d")
            }
        }
    }
}

