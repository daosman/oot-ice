ARG IMAGE
ARG BUILD_IMAGE

FROM ${BUILD_IMAGE} AS builder
WORKDIR /build/

ARG DRIVER_VER
ARG KERNEL_VERSION

COPY ice-$DRIVER_VER.tar.gz .

RUN tar zxf ice-$DRIVER_VER.tar.gz
WORKDIR ice-$DRIVER_VER/src

RUN BUILD_KERNEL=$KERNEL_VERSION KSRC=/usr/src/kernels/$KERNEL_VERSION make

FROM ${IMAGE}

ARG DRIVER_VER
ARG KERNEL_VERSION

RUN rm /lib/modules/${KERNEL_VERSION}/kernel/drivers/net/ethernet/intel/ice/ice.ko.xz
RUN rm -rf /lib/firmware/intel/ice/ddp

COPY --from=builder /build/ice-$DRIVER_VER/src/ice.ko /lib/modules/${KERNEL_VERSION}/kernel/drivers/net/ethernet/intel/ice/
COPY --from=builder /build/ice-$DRIVER_VER/ddp/ /lib/firmware/intel/ice/ddp
RUN xz /lib/modules/${KERNEL_VERSION}/kernel/drivers/net/ethernet/intel/ice/ice.ko
