FROM debian:10

# Set arguments for usage during the build of this dockerfile
ARG DEBIAN_FRONTEND=noninteractive
ARG OPAMYES=1

# Copy the new sources.list to make use of the "buster" repositories instead of "stretch"
COPY sources.list /etc/apt/sources.list

# Install required system packages and dependencies
RUN apt update && \
	apt upgrade -y && \
	apt install -y \
	apt-utils \
	apt-transport-https \
	curl \
	wget \
	dirmngr \
	sudo \
	opam \
	git \
	automake

# Create the liquidsoap user and add it to the sudoers group
RUN useradd -m liquidsoap && \
	adduser liquidsoap sudo && \
	echo 'liquidsoap	ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Switch to liquidsoap user
USER liquidsoap
WORKDIR /home/liquidsoap

# Create the opam environment and install required packages
RUN opam init  --disable-sandboxing --bare && \
	opam switch create 4.08.0

# Can be removed once Liquidsoap 2.0 is officially released
RUN git clone https://github.com/savonet/ocaml-ffmpeg.git && \
	cd ocaml-ffmpeg && \
	opam pin add -n . && \
	cd ..

# Can be removed once Liquidsoap 2.0 is officially released
RUN opam pin add -n duppy https://github.com/savonet/ocaml-duppy.git#master && \
	opam pin add -n mm https://github.com/savonet/ocaml-mm.git#master && \
	opam pin add -n gstreamer https://github.com/savonet/ocaml-gstreamer.git#master && \
	opam pin add -n taglib https://github.com/savonet/ocaml-taglib.git#master && \
	opam pin add -n liquidsoap https://github.com/savonet/liquidsoap.git#d84c47e

RUN opam depext ao bjack cry fdkaac ffmpeg frei0r gavl gstreamer lo magic portaudio shine ssl taglib xmlplaylist duppy mm liquidsoap && \
	opam install ao bjack cry fdkaac ffmpeg frei0r gavl gstreamer lo magic portaudio shine ssl taglib xmlplaylist liquidsoap

RUN sudo apt install -y libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev gstreamer1.0-plugins-good gstreamer1.0-plugins-base gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly libx264-dev x264

RUN eval $(opam config env)

ENTRYPOINT ["opam", "config", "exec", "--"]
CMD ["liquidsoap", "/home/liquidsoap/app/main.liq"]