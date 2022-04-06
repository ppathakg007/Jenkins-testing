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
	           dockerImage = docker.build(nemo_images + ":$env.imagever")
                echo env.imagever
           
           // sh 'docker build -t repository.usenemo.com:5000/nemo/nemo_engine:env.imagever'
                    }
                
            }
        }
		stage('Publish Image') {
            steps {
                script {
                    
                    def imagever = readFile(file: '/mnt/img-ver')
		    docker.withRegistry( 'http://repository.usenemo.com:5000' ) {
		    dockerImage.push()
            }
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
