pipeline { 
	environment {
	dockerImage = ''
	registryCredential = 'gitlab_id'
	nemo_images = "repository.usenemo.com:5000/nemo/nemo_engine"
	}
    agent any 
    
    stages {
        stage('Precheck') { 
            steps { 
                sh 'rm -rf Jenkins*' 
		sh ' bash /mnt/jenkins_precheck_space.sh '
            }
        }
        stage('Code checkout'){
            steps {
                sh 'git clone --recurse-submodules git@github.com:unmeeting/Jenkins-teting.git'
            }
        }
        stage('Build_image') {
            steps {
                script {
                   def imagever = readFile(file: '/mnt/img-ver')
                   println(imagever)
		           echo "$imagever"
	               dockerImage = docker.build(nemo_images + ":imagever")
               }
                
            }
        }
		stage('Publish Image') {
            steps {
                script {
                    
                    def imagever = readFile(file: '/mnt/img-ver')
		    docker.withRegistry( 'repository.usenemo.com:5000', registryCredential ) 
		    dockerImage.push()
                }
            }
        }
		stage('Send Notification') {
            steps {
                sh 'echo done'
            }
        }
    }
}
