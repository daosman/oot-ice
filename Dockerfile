ARG IMAGE
ARG BUILD_IMAGE

FROM ${BUILD_IMAGE} AS builder
WORKDIR /build/

ARG DRIVER_VER
ARG KERNEL_VERSION
ARG MIRROR

ARG GET_DEVEL_RPM
ENV GET_DEVEL_RPM=$GET_DEVEL_RPM
RUN if [[ ${GET_DEVEL_RPM} == "yes" ]]; then \
wget http://${MIRROR}/kernel-devel-${KERNEL_VERSION}.rpm && rpm -Uvh kernel-devel-${KERNEL_VERSION}.rpm; \
fi

RUN wget https://netix.dl.sourceforge.net/project/e1000/ice%20stable/$DRIVER_VER/ice-$DRIVER_VER.tar.gz
RUN tar zxf ice-$DRIVER_VER.tar.gz
WORKDIR ice-$DRIVER_VER/src

RUN BUILD_KERNEL=$KERNEL_VERSION KSRC=/usr/src/kernels/$KERNEL_VERSION make

FROM ${IMAGE}

ARG DRIVER_VER
ARG KERNEL_VERSION

RUN microdnf install --disablerepo=* --enablerepo=ubi-8-baseos -y kmod

COPY --from=builder /build/ice-$DRIVER_VER/src/ice.ko /ice-driver/
COPY --from=builder /build/ice-$DRIVER_VER/ddp/ /ddp/
COPY scripts/load.sh scripts/unload.sh /usr/local/bin
RUN chmod +x /usr/local/bin/load.sh && chmod +x /usr/local/bin/unload.sh
