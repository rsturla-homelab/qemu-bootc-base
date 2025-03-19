FROM quay.io/centos-bootc/centos-bootc:stream10@sha256:ec0117b75a9bd8c47950ef722d74a0d6e84d311dd7744b5a1e68c022cecc1665

COPY files/ /

RUN dnf -y remove \
        subscription-manager \
    && \
    dnf -y install \
        qemu-guest-agent \
        cloud-init \
    && \
    systemctl enable qemu-guest-agent.service \
    && \
    dnf clean all
