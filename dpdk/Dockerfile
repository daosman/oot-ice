FROM quay.io/centos/centos:stream9

LABEL maintainer="Sebastian Scheinkman <sebassch@gmail.com>"
LABEL io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"
LABEL io.s2i.scripts-url="image:///usr/libexec/s2i"

ARG DPDK_VERSION

ENV BUILDER_VERSION 0.1
ENV DPDK_VER ${DPDK_VERSION}
ENV DPDK_DIR /usr/src/dpdk-stable-${DPDK_VER}
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

RUN cd /usr/src/ && wget http://fast.dpdk.org/rel/dpdk-${DPDK_VER}.tar.xz && tar -xpvf dpdk-${DPDK_VER}.tar.xz && rm dpdk-${DPDK_VER}.tar.xz && \
    cd dpdk*-${DPDK_VER} && \
    meson build && \
    cd build  && \
    meson configure -Denable_docs=false && \
    ninja && \
    ninja install && \
    echo "/usr/local/lib64" > /etc/ld.so.conf.d/dpdk.conf && \
    ldconfig

RUN ln -s ${DPDK_DIR}/build/app/dpdk-testpmd /usr/bin/testpmd


RUN mkdir -p /opt/app-root/src

WORKDIR /opt/app-root/src

RUN chmod -R 777 /opt/app-root

COPY ./run.sh /usr/bin/run.sh

RUN chmod +x /usr/bin/run.sh

ENTRYPOINT ["/usr/bin/run.sh"]
