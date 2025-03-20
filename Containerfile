FROM quay.io/centos-bootc/centos-bootc:stream10@sha256:ec0117b75a9bd8c47950ef722d74a0d6e84d311dd7744b5a1e68c022cecc1665

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
