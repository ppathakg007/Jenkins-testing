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
         stage('checking') { 
            steps { 
                sh ' pwd ' 
		sh ' ls -ltr '
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
           
	    docker.withRegistry( 'http://repository.usenemo.com:5000' ) {
//		    dockerImage.push()
          
        }
           }
               }
            
        }
	
        
    
    } 
    post {
        
        success {
            echo 'I succeeded!'
         sh  ' /mnt/build-notify/jenkins-notification.sh ' 
        }
      
        failure {
            echo 'I failed :('
            sh ' /mnt/build-notify/jenkins-failed-notification.sh '
        }
        
    }
}
