FROM debian:10

ENV DEBIAN_FRONTEND=noninteractive

#Install required system packages and dependencies
RUN apt update && \
	apt install -y \
	apt-utils \
	apt-transport-https \
	curl \
	wget \
	dirmngr \
	sudo

# Create the liquidsoap user and add it to the sudoers group
RUN useradd -m liquidsoap && \
	adduser liquidsoap sudo && \
	echo 'liquidsoap	ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Copy the new sources.list to make use of the "buster" repositories instead of "stretch"
COPY sources.list /etc/apt/sources.list

# Update the package list, upgrade existing packages, and install opam
RUN apt update && \
	apt upgrade -y && \
	apt install -y \
	opam

#Switch to liquidsoap user
USER liquidsoap

ENV OPAMYES=1

#Create the opam environment and install required packages
RUN opam init  --disable-sandboxing && \
	opam switch create 4.10.0 && \
	opam depext alsa ao bjack camlimages cry dssi faad fdkaac ffmpeg flac frei0r gavl gd graphics gstreamer ladspa lame lo mad magic ogg opus portaudio pulseaudio samplerate shine soundtouch ssl taglib theora vorbis xmlplaylist yojson liquidsoap && \
	opam install -y alsa ao bjack camlimages cry dssi faad fdkaac ffmpeg flac frei0r gavl gd graphics gstreamer ladspa lame lo mad magic ogg opus portaudio pulseaudio samplerate shine soundtouch ssl taglib theora vorbis xmlplaylist yojson liquidsoap

RUN sudo apt install -y \
	gstreamer1.0-plugins-good \
	gstreamer1.0-plugins-base \
	gstreamer1.0-plugins-bad

RUN eval $(opam config env)

ENTRYPOINT ["opam", "config", "exec", "--"]
CMD ["liquidsoap", "/home/liquidsoap/app/main.liq"]