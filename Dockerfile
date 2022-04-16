FROM nvidia/cuda:11.1.1-base-ubuntu20.04
EXPOSE 5000

# Set working directory and configure TimeZone
WORKDIR /root
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update packages and install requirements
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get update && apt-get install -y \
    software-properties-common

RUN apt-get install -y tzdata ffmpeg python3 python3-pip python3-venv python3-tk python3-dev python3-dbg \
	unzip npm nodejs x11-apps xvfb vim jq curl wget alsa alsa-utils \
	pulseaudio pulseaudio-utils dbus-x11 sudo pavucontrol paprefs \
	build-essential ffmpeg libsm6 libxext6 tesseract-ocr libcurl4-openssl-dev libssl-dev
RUN apt update

RUN apt install -y git
RUN add-apt-repository universe
#RUN add-apt-repository universe
RUN apt-get update && apt-get install -y \
    python3.4 \
    python3-pip

RUN pip install awscli


# Prepare user - agent
RUN groupadd docker
RUN groupadd -g 2000 agent
RUN useradd -d /home/agent -s /bin/bash -m agent -u 2000 -g 2000
RUN usermod -aG docker agent
RUN usermod -aG audio agent
RUN usermod -aG pulse agent
RUN usermod -aG pulse-access agent
RUN echo "agent:mtagnt" | chpasswd
RUN echo "root:mtagnt" | chpasswd
RUN echo "agent ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
     chmod 0440 /etc/sudoers.d/user

RUN ln -s /usr/bin/python3 /usr/bin/python

# switch
USER agent
WORKDIR /home/agent

# create engine folder in root and copy files
RUN mkdir engine/
COPY --chown=agent:agent ./* engine/