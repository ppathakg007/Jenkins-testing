pipeline { 
	environment {
	dockerImage = ''
	registryCredential = 'gitlab_id'
    def imagever = readFile(file: '/mnt/img-ver')
	nemo_images = "repository.usenemo.com:5000/nemo/nemo_engine:$imagever"
   
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
	          dockerImage = docker.build(nemo_images )
              echo env.nemo_images
           
            //sh 'imagever=`cat /mnt/img-ver`;cd Jenkins-testing;  docker build -t repository.usenemo.com:5000/nemo/nemo_engine:$imagever'
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
