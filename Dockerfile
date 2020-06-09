#For whatever reason debian 10 gives a lot of problems when compiling liquidsoap via opam
FROM debian:10

RUN useradd -m liquidsoap

ENV DEBIAN_FRONTEND=noninteractive

#Install required system packages and dependencies
RUN apt update && \
	apt install -y \
	apt-utils \
	apt-transport-https \
	curl \
	wget \
	dirmngr

# Copy the new sources.list to make use of the "buster" repositories instead of "stretch"
COPY sources.list /etc/apt/sources.list

# Update the package list, upgrade existing packages, and install opam
RUN apt update && \
	apt upgrade -y && \
	apt install -y \
	opam

ENV OPAMYES=1

RUN	opam init --disable-sandboxing && \
	opam switch create 4.10.0 && \
	opam update && \
	opam depext alsa ao bjack camlimages cry dssi faad fdkaac ffmpeg flac frei0r gavl gd graphics gstreamer ladspa lame lo mad magic ogg opus portaudio pulseaudio samplerate shine soundtouch ssl taglib theora vorbis xmlplaylist yojson liquidsoap

#Switch to liquidsoap user
USER liquidsoap

RUN opam init  --disable-sandboxing && \
	opam switch create 4.10.0 && \
	opam install -y alsa ao bjack camlimages cry dssi faad fdkaac ffmpeg flac frei0r gavl gd graphics gstreamer ladspa lame lo mad magic ogg opus portaudio pulseaudio samplerate shine soundtouch ssl taglib theora vorbis xmlplaylist yojson liquidsoap

RUN eval $(opam config env)

ENTRYPOINT ["opam", "config", "exec", "--"]
CMD ["liquidsoap", "/home/liquidsoap/app/main.liq"]