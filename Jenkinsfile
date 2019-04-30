pipeline {
    environment {
        /* Public Docker Hub */
        dockerHubRegistry = 'https://registry.hub.docker.com'
        dockerHubRegistryCredential = 'docker-hub-credential'
        dockerHubRepository = 'zhaobingchen/test'
        dockerHubPrefix = 'registry.hub.docker.com/'

        /* Amazon ECR */
        amazonEcrRegistry = 'https://429302170673.dkr.ecr.us-east-2.amazonaws.com'
        amazonEcrRegistryCredential = 'ecr:us-east-2:ecr-credential'
        amazonEcrRepository = 'zchen-test'
        amazonEcrPrefix = '429302170673.dkr.ecr.us-east-2.amazonaws.com/'
        
        registry = ''
        registryCredential = ''
        repository = ''
        dockerImage = ''
        registryPrefix = ''
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
                        registryPrefix = dockerHubPrefix
                    } else {
                        registry = amazonEcrRegistry
                        registryCredential = amazonEcrRegistryCredential
                        repository = amazonEcrRepository
                        registryPrefix = amazonEcrPrefix
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

        stage('Deply docker image to beanstalk') {
            steps {
sh label: '', script: '''mkdir -p beanstalk-app
sed "s|DOCKER_IMAGE|$registryPrefix$repository:$BUILD_NUMBER|g" Dockerrun.aws.json > beanstalk-app/Dockerrun.aws.json
cd beanstalk-app
PATH=$PATH:/home/ec2-user/.local/bin
export PYTHONPATH=/home/ec2-user/.local/lib/python3.7/site-packages
eb init -p docker zchen-eb-docker
eb deploy ZchenEbDocker-env --region us-east-2 --label RealTimeChat:$BUILD_NUMBER
rm -rf beanstalk-app
'''
            }
        }
    }
}
