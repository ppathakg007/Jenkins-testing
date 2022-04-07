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
              //echo env.nemo_images
              dockerImage = docker.build(nemo_images + ":${env.BUILD_ID}" )
              
           
            //sh 'imagever=`cat /mnt/img-ver`;cd Jenkins-testing;  docker build -t repository.usenemo.com:5000/nemo/nemo_engine:$imagever'
                    }
                
            }
        }
		stage('Publish Image') {
            steps {
                script {
                    
            def imagever = dockerImage
		    docker.withRegistry( 'http://repository.usenemo.com:5000' ) {
		    dockerImage.push()
            echo "$dockerImage"
            
            }
                }
            }
        }
		stage('Send Notification') {
            steps {
                sh 'ssh root@172.21.162.95 docker pull repository.usenemo.com:5000/nemo/nemo_engine:"${env.BUILD_ID""'
            }
        }
    }
}
