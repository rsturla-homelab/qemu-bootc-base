FROM quay.io/centos-bootc/centos-bootc:stream10@sha256:3765fecf1b46b686a139198f1a6a1da4f4daf33ff44ac05840bda1e09a8257e2 AS base

COPY files/base/ /

# Manage default packages
RUN --mount=type=cache,target=/var/cache/dnf <<EOF
  set -eux
  dnf -y install 'dnf-command(versionlock)'
  dnf versionlock add $(rpm -qa --queryformat '%{NAME}-%{VERSION}-%{RELEASE}\n' kernel*)
  dnf -y remove \
    subscription-manager*
  dnf -y install \
    cloud-init \
    nftables \
    epel-release
  systemctl enable cloud-init.service
  systemctl enable nftables.service
EOF

# Configure (harden) image
RUN --mount=type=cache,target=/var/cache/dnf <<EOF
  set -eux
  authselect select local with-faillock --force
  # Set umask for default permissions
  echo "umask 027" >> /etc/profile
  dnf install -y audit
  systemctl enable auditd.service
EOF

FROM base AS qemu

COPY files/qemu/ /

# Virtualization tools (KVM)
RUN --mount=type=cache,target=/var/cache/dnf <<EOF
  set -eux
  dnf install -y \
    qemu-guest-agent
  systemctl enable qemu-guest-agent.service
EOF
