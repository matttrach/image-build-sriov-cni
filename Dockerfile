ARG TAG="2.6.3"
ARG BCI_IMAGE=registry.suse.com/bci/bci-base:15.3.17.20.12
ARG GO_IMAGE=rancher/hardened-build-base:v1.18.5b7

# Build the project
FROM ${GO_IMAGE} as builder
RUN set -x \
 && apk --no-cache add \
    git \
    make
ARG TAG
RUN git clone --depth=1 https://github.com/k8snetworkplumbingwg/sriov-cni
WORKDIR sriov-cni
RUN git fetch --all --tags --prune
RUN git checkout tags/${TAG} -b ${TAG} 
RUN make clean && make build 

# Create the sriov-cni image
FROM ${BCI_IMAGE}
WORKDIR /
COPY --from=builder /go/sriov-cni/build/sriov /usr/bin/
COPY --from=builder /go/sriov-cni/images/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
