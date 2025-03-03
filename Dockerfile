ARG IMAGE=arm64v8/ubuntu

# build
FROM ubuntu:20.04 as builder
LABEL maintainer=michel.promonet@free.fr

ARG ARCH=arm64 

WORKDIR /webrtc-streamer
COPY . /webrtc-streamer

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates wget git python python-pkg-resources xz-utils cmake make pkg-config gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
	&& mkdir /webrtc \
	&& git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /webrtc/depot_tools \
	&& export PATH=/webrtc/depot_tools:$PATH \
	&& cd /webrtc \
	&& fetch --no-history --nohooks webrtc \
	&& sed -i -e "s|'src/resources'],|'src/resources'],'condition':'rtc_include_tests==true',|" src/DEPS \
	&& /webrtc/src/build/linux/sysroot_scripts/install-sysroot.py --arch=arm64 \
	&& gclient sync \
	&& cd /webrtc-streamer \
	&& cmake -DCMAKE_SYSTEM_PROCESSOR=${ARCH} -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY -DWEBRTCDESKTOPCAPTURE=OFF . && make \
	&& cpack \
	&& mkdir /app && tar xvzf webrtc-streamer*.tar.gz --strip=1 -C /app/ \
	&& rm -rf /webrtc && rm -f *.a && rm -f src/*.o \
	&& apt-get clean && rm -rf /var/lib/apt/lists/

# run
FROM $IMAGE

WORKDIR /app
COPY --from=builder /app/ /app/

ENTRYPOINT [ "./webrtc-streamer" ]
CMD [ "-a", "-C", "config.json" ]
