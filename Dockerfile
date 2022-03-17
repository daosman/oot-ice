ARG IMAGE
ARG BUILD_IMAGE

FROM ${BUILD_IMAGE} AS builder
WORKDIR /build/

ARG DRIVER_VER

# TODO: Offline build (without wget)

RUN wget https://netix.dl.sourceforge.net/project/e1000/ice%20stable/$DRIVER_VER/ice-$DRIVER_VER.tar.gz
RUN tar zxf ice-$DRIVER_VER.tar.gz
WORKDIR ice-$DRIVER_VER/src

ARG KERNEL_VERSION
RUN BUILD_KERNEL=$KERNEL_VERSION KSRC=/lib/modules/$KERNEL_VERSION/build/ make

# TODO: Sign

FROM ${IMAGE}

ARG DRIVER_VER
ARG KERNEL_VERSION

RUN microdnf install --disablerepo=* --enablerepo=ubi-8-baseos -y kmod

COPY --from=builder /build/ice-$DRIVER_VER/src/ice.ko /ice-driver/
COPY scripts/load.sh scripts/unload.sh /usr/local/bin
RUN chmod +x /usr/local/bin/load.sh && chmod +x /usr/local/bin/unload.sh
