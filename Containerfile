FROM quay.io/centos-bootc/centos-bootc:stream10@sha256:eec9efeec136ed18f8b9a7210ba0fab8cca3559f1d74edd17ca8e2264ef227a5

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
