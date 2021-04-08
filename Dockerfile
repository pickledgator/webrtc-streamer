FROM arm64v8/ubuntu:18.04

COPY . /webrtc-streamer/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates wget git python2.7 python3 python3-distutils python-pkg-resources xz-utils cmake make pkg-config

RUN mkdir /webrtc && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /webrtc/depot_tools
RUN cd /webrtc/depot_tools && echo "linux-arm64" > .cipd_client_platform && export VPYTHON_BYPASS="manually managed python not supported by chrome operations"
RUN export VPYTHON_BYPASS="manually managed python not supported by chrome operations" && cd /webrtc && /webrtc/depot_tools/fetch --no-history --nohooks webrtc
#  && cd /webrtc sed -i -e "s|'src/resources'],|'src/resources'],'condition':'rtc_include_tests==true',|" src/DEPS \
#  && /webrtc/src/build/linux/sysroot_scripts/install-sysroot.py --arch=arm64 \
#  && cd /webrtc gclient sync \
#  && cd /webrtc-streamer && cmake -DCMAKE_SYSTEM_PROCESSOR=${ARCH} -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY -DWEBRTCDESKTOPCAPTURE=OFF . && make \
#RUN cd /webrtc-streamer && cmake . && make
#  && cd /webrtc-streamer cpack \
#  && mkdir /app && tar xvzf webrtc-streamer*.tar.gz --strip=1 -C /app/ \
#  && rm -rf /webrtc && rm -f *.a && rm -f src/*.o \
#RUN apt-get clean && rm -rf /var/lib/apt/lists/

#FROM $IMAGE
#WORKDIR /app
#COPY --from=builder /app/ /app/

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

#ENTRYPOINT [ "./webrtc-streamer" ]
#CMD [ "-a", "-C", "config.json" ]

