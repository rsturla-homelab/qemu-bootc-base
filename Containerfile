FROM quay.io/centos-bootc/centos-bootc:stream10@sha256:7cb699402d5caa104e6770498dc26ea44bf5b3305700ba11d475a90e320b7f82

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
