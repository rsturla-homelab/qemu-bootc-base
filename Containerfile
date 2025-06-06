ARG BASE_IMAGE_REGISTRY=quay.io/centos-bootc/centos-bootc
ARG BASE_IMAGE_TAG=stream10
ARG BASE_IMAGE_DIGEST=sha256:b7f34ee291f76553e5b8ec5a57af84a2203e4a5fe53637bb0de4fb1d9c58c01d
FROM ${BASE_IMAGE_REGISTRY}:${BASE_IMAGE_TAG}@${BASE_IMAGE_DIGEST} AS base

COPY files/base/ /

# Manage default packages
RUN --mount=type=cache,target=/var/cache/dnf \
  dnf -y install 'dnf-command(versionlock)' && \
  dnf versionlock add $(rpm -qa --queryformat '%{NAME}-%{VERSION}-%{RELEASE}\n' kernel*) \
  && \
  dnf -y remove subscription-manager* \
  && \
  dnf -y install cloud-init nftables epel-release \
  && \
  systemctl enable cloud-init.service && \
  systemctl enable nftables.service

# Harden image
RUN --mount=type=cache,target=/var/cache/dnf \
  authselect select local with-faillock --force \
  && \
  echo "umask 027" >> /etc/profile \
  && \
  dnf install -y audit && \
  systemctl enable auditd.service


FROM base AS qemu

# Virtualization tools
RUN --mount=type=cache,target=/var/cache/dnf \
  dnf install -y qemu-guest-agent && \
  systemctl enable qemu-guest-agent.service
