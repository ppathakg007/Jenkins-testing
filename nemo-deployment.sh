#!/bin/bash

startcont()
{	  
	if [ "$depenv" = "prd" ];  then
     	     rningcont=` ssh  root@$srvr " docker ps | grep -i nemo" | awk '{print $1}'`
       	 echo "$rningcont"
          if [ -z "$rningcont" ]
          then
            echo "There is no container running.Strating container with image version :- $nxtimgver"
             ssh root@$srvr "cd /deployment/nemo_engine.$nxtimgver;docker run -d --gpus all  --rm --shm-size=1g --env-file /deployment/.env --net=host --hostname=nemoengine --memory=14g --memory-reservation=14g --cpus=3 --name=nemoengine --privileged=true --entrypoint /home/agent/engine/engine_init.sh -i nemo_engine:$nxtimgver"
          else
            echo " There is a container running.Container id running :- $rningcont"
            echo "Stopping container :-  $rningcont"
            ssh root@$srvr " docker stop  $rningcont"
            sleep 1
            echo "Starting container"
             ssh root@$srvr "cd /deployment/nemo_engine.$nxtimgver;docker run -d --gpus all  --rm --shm-size=1g --env-file /deployment/.env --net=host --hostname=nemoengine --memory=14g --memory-reservation=14g --cpus=3 --name=nemoengine --privileged=true --entrypoint /home/agent/engine/engine_init.sh -i nemo_engine:$nxtimgver"
            sleep 1
            echo "Container started with image :- $nxtimgver"
	    ssh  root@$srvr " docker ps | grep -i nemo"
         fi
 else
	      rningcont=` ssh  root@$srvr " docker ps | grep -i nemo" | awk '{print $1}'`
         echo "$rningcont"
          if [ -z "$rningcont" ]
          then
            echo "There is no container running.Strating container with image version :- $nxtimgver"
             ssh root@$srvr "cd /deployment/nemo_engine.$nxtimgver;docker run -d --rm --shm-size=1g --env-file /deployment/.env --net=host --hostname=nemoengine --memory=14g --memory-reservation=14g --cpus=3 --name=nemoengine --privileged=true --entrypoint /home/agent/engine/engine_init.sh -i nemo_engine:$nxtimgver"
          else
            echo " There is a container running.Container id running :- $rningcont"
            echo "Stopping container :-  $rningcont"
            ssh root@$srvr " docker stop  $rningcont"
            sleep 1
            echo "Starting container"
             ssh root@$srvr "cd /deployment/nemo_engine.$nxtimgver;docker run -d  --rm --shm-size=1g --env-file /deployment/.env --net=host --hostname=nemoengine --memory=14g --memory-reservation=14g --cpus=3 --name=nemoengine --privileged=true --entrypoint /home/agent/engine/engine_init.sh -i nemo_engine:$nxtimgver"
            sleep 1
            echo "Container started with image :- $nxtimgver"
	    ssh  root@$srvr " docker ps | grep -i nemo"
         fi
	fi
 }
precheck()
{
echo "Checking the space in server"
spaceavail=`ssh  root@$srvr "df -h / " |grep -i dev | awk {'print $4'} | tr -d \G`

echo "Free space available in server:- $spaceavail GB"
spcavl=`echo $spaceavail | awk '{ printf "%d\n",$1 }'`
echo "Required free space to create image :- 38GB"
echo "Checking Requeired space availabe in server"
if [ $spcavl -gt 38 ]
    then
        echo "Required space is availabe in server."
	synccode
    else
        echo "Required space is not available in server"
	echo " Checking available Image in server"
	ssh  root@$srvr "docker images | grep nemo" > imgs
	sed -n '4,$p' imgs | awk {'print $3'} > imgtodele
	for imgid in `cat imgtodele`; do 
	echo "deleting image $imgid"
	ssh root@$srvr "docker rmi $imgid"
	done
	echo " Image are deleted now checing available Space in server"
	spaceavail=`ssh  root@$srvr "df -h / " |grep -i dev | awk {'print $4'} | tr -d \G`
	echo "Free space available in server:- $spaceavail GB"
	spcavl=`echo $spaceavail | awk '{ printf "%d\n",$1 }'`
	echo "Required free space to create image :- 38GB"
        echo "Checking Requeired space availabe in server"
	if [ $spcavl -gt 38 ]
    then
        echo "Required space is availabe in server."
        echo "Proceeding to create image"
        test
	synccode
    else
     echo "Required space is not available in server"
     echo "Please clearup some space before you proceed to create image: Goodbye"
     exit 1
	fi
fi
}
synccode () { 
	echo " You selected to sync code from git hub"   
#	if [ -d "./nemo_engine" ]; then
 	 # Take action if $DIR exists. #
	  mkdir -p ./archive
	  echo "Nemo Engine code existing archiving the existing code"
	  archivename=` date '+%s'`
	  echo "archiving the existing Code"
	  echo "archive name $archivename"
#	  mv nemo_engine $archivename
	  echo "cloning the Nemo Engine from github"
	  git clone --recurse-submodules --remote-submodules $nenggit__Url  
	  echo "Checking Latest image on server"
	  echo "Enter Image tag to start container..?";read

#	  srvr=`cat ./.conf/dev`
	  limage=` ssh  root@$srvr " docker images | grep -i nemo_engine | head -1  " | awk '{print $2}'`
#	  nxtimgver=`echo $limage .1 | awk '{print $1 + $2}'`
#	  echo "$(( $limage + .1 ))" 
#	  echo "$nxtimgver"
	  echo " Latest image version :- $limage"
	  echo " Recording Latest images version"
	  echo "$limage" > preimagever
	  nxtimgver=`echo $limage .1 | awk '{print $1 + $2}'`
	  echo "archive name $archivename"
	  mv nemo_engine nemo_engine.$nxtimgver
#	  cp ./.conf/.dev-env nemo_engine.$nxtimgver/.env
	  cp .conf/.nemo-conf nemo_engine.$nxtimgver/.env
	  echo " Pushing code to server $srvr"
	  rsync -avzh ./nemo_engine.$nxtimgver root@$srvr:/deployment
	  echo " Application has been push"
      	  echo "Creating the docker image on $sevr"
	  echo " Be patient!... this will take longer time"
	  sleep 3
	  if [ "$usecache" = "no" ]
		then
	  echo "Building image without Cache"
	  ssh  root@$srvr " cd /deployment/nemo_engine.$nxtimgver;docker build --pull --no-cache . -t nemo_engine:$nxtimgver"
          else
           echo "Building Image With Cache"
           ssh  root@$srvr " cd /deployment/nemo_engine.$nxtimgver;docker build . -t nemo_engine:$nxtimgver"
	  fi
	  mv nemo_engine.$nxtimgver $archivename.$nxtimgver
	 echo "checking Images created status"
	 imgstatus=`ssh  root@$srvr " docker images | grep -i nemo_engine | grep $nxtimgver"`
	  if [ -z "$imgstatus" ]
         then
                 echo " images is not created successfully. please check manually"
                 exit 1
        else
                echo "Image is created successfully!"
                echo "$imgstatus"
		date
	while true
 	do
		echo "Do want to start container with new image..? option y/n";read sartcont;
		if [ "$sartcont" = "y" ];  then
                echo "Proceeding to start container"
		startcont
		break
		elif [ "$sartcont" = "n" ];  then
		echo "Container is not being started"
		exit 0
		else
		echo " Please select correct option y/n"
		fi
	done

        fi
	 mv $archivename.$nxtimgver archive
	echo "git url : $nenggit__Url"
}

#echo "Do you want to pull code from github:(y/n)";read gitsync;echo "$gitsync"
echo "Exporting the configuration"
source ./.conf/.nemo-conf
depenv=$1
usecache=$2
echo "$usecache"
echo "You selected Environment to Deploy code:- $depenv"
if [ "$depenv" = "prd" ];  then
	echo " You are deploying in Production env"
srvr=`cat ./.conf/prd`
	precheck
elif [ "$depenv" = "dev" ];  then
	 echo "You are deploying in Development env"
	 srvr=`cat ./.conf/dev`
	 precheck
 elif [ "$depenv" = "crps" ];  then
         echo "You are deploying in Corpus env"
         srvr=`cat ./.conf/crps`
         precheck

else
	 echo "You are deploying in Invalid env :- $depenv"
	 echo -e "Please use Command: \n bash nemoenginedeploy.sh prd" 
	 echo -e "Please use Command: \n bash nemoenginedeploy.sh dev" 
fi
