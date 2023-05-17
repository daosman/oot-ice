FROM quay.io/centos/centos:stream9 AS builder

LABEL maintainer="Dahir Osman <dosman@gmail.com>"

ARG DPDK_VERSION

ENV BUILDER_VERSION 0.1
ENV DPDK_VER ${DPDK_VERSION}
ENV DPDK_DIR /usr/src/dpdk-stable-${DPDK_VER}
ENV DESTDIR /usr/src/dpdk-stable-pkg-${DPDK_VER}
ENV RTE_TARGET=x86_64-native-linuxapp-gcc
ENV RTE_SDK=${DPDK_DIR}
ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig/

LABEL io.k8s.description="Platform for building DPDK workloads" \
      io.k8s.display-name="builder 0.1" \
      io.openshift.tags="builder,dpdk"

RUN yum groupinstall -y "Development Tools"

RUN yum install -y python3-pip

# The second yum install is here to overcome versions mismatch between rpms
RUN yum install -y wget python3\
 numactl \
 numactl-devel \
 make \
 logrotate \
 ethtool \
 patch \
 which \
 readline-devel \
 iproute \
 libibverbs \
 lua \
 git \
 procps \
 tmux \
 pciutils \
 gcc \
 expect && \
 yum install -y libibverbs-devel && \
 yum clean all

RUN pip3 install meson ninja pyelftools

RUN cd /usr/src/ && wget http://fast.dpdk.org/rel/dpdk-${DPDK_VER}.tar.xz && tar -xpvf dpdk-${DPDK_VER}.tar.xz && rm -f dpdk-${DPDK_VER}.tar.xz && \
    cd dpdk*-${DPDK_VER} && \
    meson setup build && \
    cd build  && \
    meson configure -Denable_docs=false && \
    ninja && \
    ninja install && \
    cd ${DESTDIR} && \
    tar -zcf dpdk-stable-pkg-${DPDK_VER}.tgz usr

FROM quay.io/centos/centos:stream9

ARG DPDK_VERSION

ENV DPDK_VER ${DPDK_VERSION}
ENV DPDK_DIR /usr/src/dpdk-stable-${DPDK_VER}
ENV DESTDIR /usr/src/dpdk-stable-pkg-${DPDK_VER}
ENV RTE_TARGET=x86_64-native-linuxapp-gcc
ENV RTE_SDK=${DPDK_DIR}

COPY ./run.sh /usr/bin/run.sh
COPY --from=builder ${DESTDIR}/dpdk-stable-pkg-${DPDK_VER}.tgz /opt/

RUN INSTALL_PKGS="bsdtar \
  findutils \
  util-linux \
  numactl \
  numactl-devel \
  tmux \
  tar \
  ethtool \
  patch \
  which \
  procps-ng \
  readline-devel \
  iproute \
  libatomic \
  xz \
  libibverbs" && \
  yum install -y $INSTALL_PKGS && \
  rpm -V $INSTALL_PKGS && \
  yum -y clean all

RUN tar xf /opt/dpdk-stable-pkg-${DPDK_VER}.tgz -C / && rm -rf /opt/dpdk-stable-pkg-${DPDK_VER}.tgz

RUN echo "/usr/local/lib64" > /etc/ld.so.conf.d/dpdk.conf && ldconfig

WORKDIR ${HOME}
 
RUN chmod +x /usr/bin/run.sh

ENTRYPOINT ["/usr/bin/run.sh"]
