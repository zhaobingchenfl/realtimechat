pipeline {
    environment {
        /* Public Docker Hub */
        dockerHubRegistry = 'https://registry.hub.docker.com'
        dockerHubRegistryCredential = 'docker-hub-credential'
        dockerHubRepository = 'zhaobingchen/test'

        /* Amazon ECR */
        amazonEcrRegistry = 'https://429302170673.dkr.ecr.us-east-2.amazonaws.com'
        amazonEcrRegistryCredential = 'ecr:us-east-2:ecr-credential'
        amazonEcrRepository = 'zchen-test'
        
        registry = ''
        registryCredential = ''
        repository = ''
        dockerImage = ''
    }

    
    agent any

    stages {

        stage('Build') {

            agent {
                docker {
                   image 'node:10-alpine'
                   args '-u 0:0'
                }  
            }

            steps {
                sh 'npm install'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Tesing ...'
            }
        }

        stage("Choose Registry") {
 
            steps {
                script {
                    def userInput = 'Docker Hub'
                    try {
                        timeout(time: 30, unit: 'SECONDS') {
                            userInput = input( message: 'Choose registry to push image',
                                          parameters: [choice(name: 'Registry', choices: 'Docker Hub\nAmazon ECR', description: 'Which registry to use to push docker image')])
                        }
                    } catch( err ) {
                        /* Do nothing. Registry default to Docker Hub. */
                    }
                    
                    if ( userInput == 'Docker Hub' ) {
                        registry = dockerHubRegistry
                        registryCredential = dockerHubRegistryCredential
                        repository = dockerHubRepository
                    } else {
                        registry = amazonEcrRegistry
                        registryCredential = amazonEcrRegistryCredential
                        repository = amazonEcrRepository
                    }
                }
            }
        }
        
        stage('Build image') {
            steps {
                script {
                    /* This builds the actual image; synonymous to
                     * docker build on the command line */
                    dockerImage = docker.build(repository + ":$BUILD_NUMBER")
                }
            }
        }
        
        stage('Push image') {

            steps {
                script {
                    /* Finally, we'll push the image with two tags:
                     * First, the incremental build number from Jenkins
                     * Second, the 'latest' tag.
                     * Pushing multiple tags is cheap, as all the layers are reused. */
                    docker.withRegistry(registry, registryCredential) {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push("latest")
                    }
                }
            }
        }
        
        stage('Remove unused image') {
            steps {
               sh "docker rmi $repository:$BUILD_NUMBER"
            }
        }

        stage('Deply docker image to beanstalk')
            steps {
                sh 'cd ebapp'
                sh 'eb init -p docker zchen-eb-docker'
                sh 'eb deploy -region us-east-2 ZchenEbDocker-env'
            }
        }
    }
}
