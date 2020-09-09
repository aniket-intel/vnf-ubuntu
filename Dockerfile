FROM ubuntu:16.04

RUN apt-get update

RUN apt-get install libusb-dev gcc linux-headers-4.15.0-112-generic libnuma-dev libarchive-dev libpcap-dev liblz4-dev liblz4-tool build-essential autoconf pciutils -y && \
apt-get install wget curl git vim unzip sudo python iputils-ping -y && \
git clone https://git.opnfv.org/samplevnf

WORKDIR /samplevnf

RUN wget http://dpdk.org/browse/dpdk/snapshot/dpdk-17.02.zip && \
unzip dpdk-17.02.zip && \
rm -rf /samplevnf/tools/vnf_build.sh


COPY dpdk-igb_uio.diff /samplevnf/dpdk-17.02/
COPY igb_uio.c /samplevnf/dpdk-17.02/lib/librte_eal/linuxapp/igb_uio/
COPY dpdk-kni.diff /samplevnf/dpdk-17.02/
COPY vnf_build.sh /samplevnf/tools/

ENV RTE_SDK=/samplevnf/dpdk-17.02
ENV RTE_TARGET=x86_64-native-linuxapp-gcc
ENV VNF_CORE=/samplevnf

WORKDIR /samplevnf/dpdk-17.02

RUN patch -p1 < /samplevnf/dpdk-17.02/dpdk-igb_uio.diff && \
patch -p1 < /samplevnf/dpdk-17.02/dpdk-kni.diff

#Build all
WORKDIR /samplevnf
RUN ./tools/vnf_build.sh -s -d=17.02

ENTRYPOINT ["/bin/bash"]
