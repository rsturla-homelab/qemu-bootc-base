FROM quay.io/centos-bootc/centos-bootc:stream10@sha256:3765fecf1b46b686a139198f1a6a1da4f4daf33ff44ac05840bda1e09a8257e2

COPY files/ /

# Lock kernel versions
RUN dnf -y install 'dnf-command(versionlock)' && \
    dnf versionlock add $(rpm -qa --queryformat '%{NAME}-%{VERSION}-%{RELEASE}\n' kernel*)

# Manage packages
RUN dnf -y remove \
        subscription-manager \
    && \
    dnf -y install \
        qemu-guest-agent \
        cloud-init \
        nftables \
        epel-release \
    && \
    systemctl enable qemu-guest-agent.service && \
    systemctl enable cloud-init.service && \
    systemctl enable nftables.service \
    && \
    dnf clean all && \
    rm -rf /var/{cache,dnf,log}/*

COPY files/ /
