
FROM dorowu/ubuntu-desktop-lxde-vnc:bionic-lxqt as builder

RUN \
 echo "**** updating system packages ****" && \
 apt-get update && \
 apt-get install wget

RUN \
 echo "**** install build packages ****" && \
 echo "y" | apt-get install build-essential qt5-qmake qtdeclarative5-dev qt5-default qttools5-dev-tools libqt5concurrent5 libjack-jackd2-dev

WORKDIR /tmp
RUN \
 echo "**** getting source code ****" && \
   wget https://github.com/corrados/jamulus/archive/latest.tar.gz && \
   tar -xvf latest.tar.gz

WORKDIR /tmp/jamulus-latest
   RUN \
    echo "**** compiling source code ****" && \
      qmake Jamulus.pro && \
      make clean && \
      make && \
      cp Jamulus /usr/local/bin/

FROM dorowu/ubuntu-desktop-lxde-vnc:bionic-lxqt

RUN \
  echo "**** installing qjackctl ****" && \
  apt-get update && \
  echo "y" | apt-get install qjackctl

RUN \
  echo "**** enabling realtime scheduling ****" && \
  cp /etc/security/limits.d/audio.conf.disabled /etc/security/limits.d/audio.conf

RUN \
  echo "**** add uID root to audio group ****" && \
  usermod -a -G audio root

RUN \
  echo "***** set environmental variables ******" && \
  export XDG_RUNTIME_DIR=/tmp/runtime-root

COPY --from=builder /usr/local/bin/Jamulus /usr/local/bin/Jamulus

ENTRYPOINT ["/startup.sh"]
