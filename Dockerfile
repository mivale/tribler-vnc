# The base image already builds the libtorrent dependency so only Python pip packages
# are necessary to be installed to run Tribler core process.
FROM triblercore/libtorrent:1.2.10-x

ENV TZ=Etc/UTC
ENV DEBIAN_FRONTEND=noninteractive

# Update the base system and install required libsodium and Python pip
# Install all packages required for vnc operation
# Install socat to expose 20100
RUN \
  apt-get update -y -qqq \
  && apt-get upgrade -y -qqq \
  && apt-get install -y -qqq libsodium23 python3-pip \
  libglib2.0-0 libgl1 \
  x11vnc xvfb fluxbox \
  libxcb-image0 \
  libxcb-icccm4 \
  libxcb-keysyms1 \
  libxcb-render-util0 \
  libxcb-xinerama0 \
  libxcb-xkb1 \
  libxkbcommon-x11-0 \
  apache2-utils \
  socat \
  && rm -rf /var/lib/apt/*

RUN useradd -ms /bin/bash user
USER user

# Then, install pip dependencies so that it can be cached and does not
# need to be built every time the source code changes.
# This reduces the docker build time.
COPY ./tribler/requirements-core.txt requirements-core.txt
COPY ./tribler/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

# Copy the source code and set the working directory
COPY --chown=user:user ./tribler/src /tribler/src
COPY --chown=user:user ./start-x11.sh /home/user

RUN rm -rf /home/user/.cache

WORKDIR /tribler

# Set the REST API port and expose it
ENV CORE_API_PORT=20100
EXPOSE 20100

# Expose VNC port
EXPOSE 5900

# Start xvfb/x11vnc/tribler
CMD ["/home/user/start-x11.sh"]
